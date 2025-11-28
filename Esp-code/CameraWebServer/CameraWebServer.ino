#include "esp_camera.h"
#include "base64.h"   // Biblioteca padrão do ESP32 para codificação base64

// FIREBASE REALTIME
#include <WiFi.h>         
#include <IOXhop_FirebaseESP32.h>                           
#include <ArduinoJson.h>   

#define WIFI_SSID "Lux"                   
#define WIFI_PASSWORD "luizluiz"         
#define FIREBASE_HOST "https://pandora32-6f15b-default-rtdb.firebaseio.com/"    
#define FIREBASE_AUTH "lVHUJg6EGWwHfTCahUSUnjD6oGirqOpozNbf5Whf" 
// FIREBASE REALTIME

//config.buffer_size = 80000;      // aumenta buffer de envio
//config.response_size = 80000;    // aumenta buffer de resposta

#define FLASH_PIN 4
// ====== CONFIGURAÇÃO DO PINOUT DA CÂMERA ESP32-CAM (AI-Thinker) ======
#include "board_config.h"

String numCaixa = "1";
int id_acess = 0;
int idProd = 0;
int frame = 0;
int numFrame = 10;
String Frames[10];


// ====== CONFIGURAÇÃO DA CÂMERA ======
int setupCamera() {
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  /*
  | Constante         | Resolução (pixels) | Tamanho aproximado (JPEG) | Observações                                                        |
  | ----------------- | ------------------ | ------------------------- | ------------------------------------------------------------------ |
  | `FRAMESIZE_96X96` | 96 × 96            | ~2–4 KB                   | Muito pequeno; útil para testes rápidos                            |
  | `FRAMESIZE_QQVGA` | 160 × 120          | ~5 KB                     | Muito leve, ideal para stream rápido                               |
  | `FRAMESIZE_QCIF`  | 176 × 144          | ~6 KB                     | Similar ao QQVGA                                                   |
  | `FRAMESIZE_HQVGA` | 240 × 176          | ~8 KB                     | Raro, pouco usado                                                  |
  | `FRAMESIZE_QVGA`  | 320 × 240          | ~15 KB                    | Boa qualidade e leveza — **ótimo equilíbrio**                      |
  | `FRAMESIZE_CIF`   | 352 × 288          | ~18 KB                    | Um pouco melhor que QVGA                                           |
  | `FRAMESIZE_VGA`   | 640 × 480          | ~40–50 KB                 | **Qualidade razoável**, ainda leve                                 |
  | `FRAMESIZE_SVGA`  | 800 × 600          | ~80 KB                    | Boa nitidez; pode pesar para base64 longa                          |
  | `FRAMESIZE_XGA`   | 1024 × 768         | ~120 KB                   | Mais detalhado; exige mais memória                                 |
  | `FRAMESIZE_SXGA`  | 1280 × 1024        | ~160 KB                   | Alto detalhe; pode causar “out of memory” se `fb_count=2`          |
  | `FRAMESIZE_UXGA`  | 1600 × 1200        | ~200 KB+                  | **Máximo suportado pela maioria das ESP32-CAMs**                   |
  | `FRAMESIZE_QXGA`  | 2048 × 1536        | ~300 KB+                  | Suportado apenas por alguns sensores (OV5640, não o OV2640 padrão) |

  */

  //config.frame_size = FRAMESIZE_XGA;   // QVGA, VGA, SVGA, XGA, etc.
  //config.jpeg_quality = 12;            // 10 = melhor qualidade
  config.fb_count = 1;

  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Erro ao iniciar a câmera: 0x%x", err);
    
    delay(300);
    ESP.restart();  // Reinicia o dispositivo automaticamente
    return 1;
  }
  Serial.println("Câmera iniciada com sucesso!");
  sensor_t * s = esp_camera_sensor_get();

  // ====== Configurações baseadas na imagem enviada ======

  // Clock
  //s->set_xclk(s, 20);                  // 20 MHz (padrão já é 20)

  // Resolução
  s->set_framesize(s, FRAMESIZE_VGA);

  // Qualidade (quanto menor o número, melhor a qualidade)
  s->set_quality(s, 2);                

  // Ajustes de imagem
  s->set_brightness(s, 2);            // brilho mínimo
  s->set_contrast(s, -2);              // contraste mínimo
  s->set_saturation(s, -2);            // saturação mínima
  s->set_special_effect(s, 0);         // sem efeito

  // Balanço de branco
  s->set_whitebal(s, 1);               // AWB ativado
  s->set_awb_gain(s, 1);               // AWB Gain ativado
  s->set_wb_mode(s, 0);                // 0 = Auto

  // Controle de exposição
  s->set_aec2(s, 0);                   // AEC DSP desligado
  s->set_aec_value(s, 0);              // Nível de exposição (não afeta se AEC ativo)
  s->set_aec2(s, 0);                   // AEC DSP off
  s->set_ae_level(s, -2);              // AE Level = -2
  s->set_aec_value(s, 300);            // Valor AEC base (pode ajustar depois)
  s->set_aec2(s, 0);                   // Desliga o AEC DSP (como na imagem)
  //s->set_aec(s, 1);                    // AEC SENSOR ligado

  // Ganho automático
  //s->set_agc(s, 1);                    // AGC ligado
  s->set_gainceiling(s, (gainceiling_t)0); // 2x (nível mínimo)

  // Correções
  s->set_bpc(s, 0);                    // BPC off
  s->set_wpc(s, 1);                    // WPC on
  s->set_raw_gma(s, 1);                // Raw GMA on
  s->set_lenc(s, 1);                   // Lens Correction on

  // Espelhamento
  s->set_hmirror(s, 0);                // H-Mirror off
  s->set_vflip(s, 0);                  // V-Flip off

  // Downsize / DCW
  s->set_dcw(s, 1);                    // DCW ligado

  // Color bar
  s->set_colorbar(s, 0);               // Color bar off

  // LED (flash)
  analogWrite(4, 0);                   // Intensidade = 0 (desligado)

  return 0;
}

// ====== FUNÇÃO QUE CAPTURA A IMAGEM E RETORNA EM BASE64 ======
String captureImageBase64() {
  camera_fb_t *fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Falha ao capturar a imagem");
    return "";
  }

  // Converte a imagem JPEG para base64
  String imageBase64 = base64::encode(fb->buf, fb->len);

  // Libera o frame buffer
  esp_camera_fb_return(fb);

  return imageBase64;
}

// ====== Take fotos ======
void take(){
  

  analogWrite(4, 3);
  //delay(500);
  Serial.println("Capturando imagem...");
  Frames[frame] = captureImageBase64();

  if (Frames[frame].length() > 0) {
    //Serial.printf("Imagem convertida em Base64 (%d caracteres):\n", img.length());
    //Serial.println(img); 
    frame = frame + 1;
    //Serial.println(Frames[frame]);
    Serial.println("Captura feita");
  } else {
    Serial.println("Erro ao gerar Base64.");
  }
  //digitalWrite(FLASH_PIN, LOW);
  analogWrite(4, 0);
  delay(1300);
}

void connectWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.println("Conectando ao Wi-Fi...");

  unsigned long startAttemptTime = millis();
  const unsigned long timeout = 10000; // 10 segundos de limite

  while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < timeout) {
    Serial.print(".");
    delay(500);
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ Wi-Fi conectado com sucesso!");
    Serial.print("Endereço IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("\n❌ Falha ao conectar ao Wi-Fi!");
    Serial.println("Reiniciando o ESP32...");
    delay(2000);
    ESP.restart();  // Reinicia o dispositivo automaticamente
  }
}

void dataBase(){
  //String ss = "";
  Firebase.setString("/caixa:" + String(numCaixa) + "/produtos/id_" + String(idProd) + "/gravacao/", "ss");
  //ss = Frames[0];
  for(int i = 0; i < numFrame; i++){
    //Serial.println("IMG --- " + Frames[i] + " --- IMG");
    Firebase.setString("/caixa:" + String(numCaixa) + "/produtos/id_" + String(idProd) + "/frame/" + String(i), Frames[i]);
    //ss = ss + ";" + Frames[i];
  }
  //Serial.println("IMG --- " + ss + " --- IMG");
  //Firebase.setString("/caixa:" + String(numCaixa) + "/produtos/id_" + String(idProd) + "/gravacao/", ss);
  delay(300);
  Serial.println("As IMGs subiram para o banco");
  
}

// ====== SETUP E LOOP ======
void setup() {
  Serial.begin(115200);
  delay(2500);
  pinMode(FLASH_PIN, OUTPUT);
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  setupCamera(); // inicia a camera
  
  connectWiFi();
  Serial.println("Conectado");
}

void loop() {
  bool gravacao = false;
  id_acess = Firebase.getInt("/caixa:" + String(numCaixa) + "/id_acess");
  Serial.print("Firebase: ");
  Serial.println(id_acess);
  Serial.println("RedFlag: ");


  
  if(id_acess != 0){
    gravacao = Firebase.getBool("/caixa:" + String(numCaixa) + "/produtos/id_" + String(id_acess) + "/gravando/");
    //Firebase.setInt("/caixa:" + numCaixa + "/id_acess", 0);
    idProd = id_acess;
    //id_acess = 0;
    Serial.print("gravacao: ");
    Serial.println(gravacao);
  }

  while(gravacao){
    if (gravacao && frame < numFrame){
      Serial.print("gravando: ");
      Serial.println(frame);
      take();
    }
    if(gravacao && frame >= numFrame){
      Firebase.setBool("/caixa:" + String(numCaixa) + "/produtos/id_" + String(id_acess) + "/gravando/", false);
      gravacao = false;
      dataBase();
    }
  }
  delay(1000);
  Serial.println("Loop");
  // Nada no loop — apenas captura única
}
