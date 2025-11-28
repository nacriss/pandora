#include <WiFi.h>         
#include <IOXhop_FirebaseESP32.h>                           
#include <ArduinoJson.h>      

#include <ESP32Servo.h>
Servo servoMotor;  // Cria o objeto servo
int pinoServo = 14;  // Pino conectado ao sinal do servo
const int pinoBotao = 12;     // Pino do botão (OUT)
bool estadoBotao = false;          // Guarda o estado do botão
bool trava = false;

#define LED_PIN 2
#define BUTTON_PIN 4  // D4 = GPIO 4
#define WIFI_SSID "Lux"                   
#define WIFI_PASSWORD "luizluiz"         
#define FIREBASE_HOST "https://pandora32-6f15b-default-rtdb.firebaseio.com/"    
#define FIREBASE_AUTH "lVHUJg6EGWwHfTCahUSUnjD6oGirqOpozNbf5Whf"   

int id_acess = 0;
int numCaixa = 1;

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

void setup() {
  Serial.begin(115200);
  servoMotor.attach(pinoServo); // Liga o servo ao pino definido
  servoMotor.write(0);          // Inicia o servo em 0 graus
  pinMode(LED_PIN, OUTPUT);  

  connectWiFi();
  Serial.println("Conectado");
  

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  /*
  digitalWrite(LED_PIN, HIGH);
  Serial.println();
  Serial.print("Pandora-1: ");
  Serial.print(Firebase.getString("/caixa:1/produtos/id_128894"));
  Serial.println();
  Serial.print(Firebase.getString("/caixa:1/produtos/id_1447"));
  Serial.println();
  Serial.println("Status" + Firebase.getString("/caixa:1/status"));
  Serial.println();
  digitalWrite(LED_PIN, LOW);
  delay(3000);
  
  void setup() {
    Serial.begin(115200);
    Serial.println("init");
    pinMode(LED_PIN, OUTPUT);
    pinMode(BUTTON_PIN, INPUT_PULLUP);  // usa resistor pull-up interno
  }

  void loop() {
    
    if (digitalRead(BUTTON_PIN) == LOW) {
      digitalWrite(LED_PIN, HIGH);
      Serial.println("HIGH");
    } else {
      digitalWrite(LED_PIN, LOW);
      Serial.println("else");
    }
    delay(1000);
  }


  */
}

void loop() {

  estadoBotao = digitalRead(pinoBotao);
  

  if (estadoBotao == HIGH) {

    id_acess = Firebase.getInt("/caixa:" + String(numCaixa) + "/id_acess");
    Serial.println("id_acess: " + String(id_acess));
    bool entregue = Firebase.getBool("/caixa:" + String(numCaixa) + "/produtos/id_" + String(id_acess) + "/entregue/");
    

   
       
    


      if(!entregue && id_acess != 0){
        Serial.println("bbbbbbbbbb do bbbbbb");
      digitalWrite(LED_PIN, HIGH);
      Firebase.setBool("/caixa:" + String(numCaixa) + "/produtos/id_" + String(id_acess) + "/gravando/", true);

      // open box --
      trava = false;
      Firebase.setString("/caixa:" + String(numCaixa) + "/estado/", "aberto");
      servoMotor.write(360);
      Serial.println("Botão pressionado → Servo a 360 graus");
      // open box --

      Firebase.setBool("/caixa:" + String(numCaixa) + "/produtos/id_" + String(id_acess) + "/entregue/", true);
      digitalWrite(LED_PIN, LOW);
    }else if(!trava){
      

      bool userButton = Firebase.getBool("/caixa:" + String(numCaixa) + "/user/porta/");
      if(userButton == true){
        Serial.println("ahhhhhhhhhhhhhh");
        Firebase.setString("/caixa:" + String(numCaixa) + "/estado/", "aberto");
        servoMotor.write(360);
        Serial.println("MAnual → Servo a 360 graus");
      }else{
        Serial.println("ccccccccccccccccc uaiccc");
        servoMotor.write(0);
        Firebase.setString("/caixa:" + String(numCaixa) + "/estado/", "fechado");
        Serial.println("Botão pressionado → Servo voltou a 0 graus");
        Firebase.setBool("/caixa:" + String(numCaixa) + "/user" + "/porta/", false);
      }

      
    }
    
    
    
    


  }


  delay(300);
  
//Exemplo da função Get

  


//Exemplo da função Set

/*
  Firebase.setString("/quarto/dono", "Rebeca");
  Firebase.setInt("/quarto/luminosidade", 300);
  Firebase.setBool("/quarto/ocupado", false);
  Firebase.setFloat("/quarto/temperatura", 24.7);
  Firebase.setInt("/sala/luminosidade", 200);
  delay(3000);
  Firebase.setString("/quarto/dono", "Matteo");
  Firebase.setInt("/quarto/luminosidade", 500);
  Firebase.setBool("/quarto/ocupado", true);
  Firebase.setFloat("/quarto/temperatura", 35.3);
  Firebase.setInt("/sala/luminosidade", 500);
  delay(3000);
*/

//Exemplo da função Push

/*
  Firebase.pushString("/quarto/registro", "Matteo");
  delay(3000);
  Firebase.pushString("/quarto/registro", "Rebeca");
  delay(3000);
  Firebase.pushString("/quarto/registro", "Vanderson");
  delay(3000);
  Firebase.pushString("/quarto/registro", "Raquel");
  delay(3000);
*/

}
