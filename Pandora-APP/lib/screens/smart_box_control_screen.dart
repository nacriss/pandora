// lib/screens/smart_box_control_screen.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pandora/main.dart';
import '../widgets/pandora_icon.dart';

class SmartBoxControlScreen extends StatefulWidget {
  // CORREÇÃO: O parâmetro 'pendingPackagesCount' é definido no construtor.
  final int pendingPackagesCount;
  final String idBox;

  const SmartBoxControlScreen({
    super.key,
    this.pendingPackagesCount = 0, // Definido como opcional com valor padrão
    required this.idBox,
  });

  @override
  State<SmartBoxControlScreen> createState() => _SmartBoxControlScreenState();
}

class _SmartBoxControlScreenState extends State<SmartBoxControlScreen> {
  // Estados simulados
  final _real = FirebaseDatabase.instance;
  bool _isLocked = true;
  bool _autoLock = true;
  bool _notifications = true;
  bool _isConnected = true;

  Future<void> initLocker() async {
    DataSnapshot dataSnap = (await _real.ref("caixa:$idBox/estado").get());
    String s = dataSnap.value as String;
    setState(() {
      if (s == "aberto") {
        _isLocked = false;
      } else {
        _isLocked = true;
      }
    });
  }

  void _handleEmergencyOpen() {
    setState(() {
      _isLocked = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comando de Abertura de Emergência enviado!'),
      ),
    );
  }

  Widget _buildStatusTile(
    IconData icon,
    Color color,
    String label,
    String value,
  ) {
    final Color chipBackgroundColor = color.withOpacity(0.2);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        Chip(
          label: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color == Colors.red ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: chipBackgroundColor,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        ),
      ],
    );
  }

  void _handleLockToggle() {
    setState(() async {
      _isLocked = !_isLocked;
      if (_isLocked) {
        await _real.ref("caixa:$idBox").update({"estado": "fechado"});
        await _real.ref("caixa:$idBox/user").update({"porta": false});
      } else {
        await _real.ref("caixa:$idBox").update({"estado": "aberto"});
        await _real.ref("caixa:$idBox/user").update({"porta": true});
      }
    });
    /*
  void _handleLockToggle() {
    setState(() async {
      _isLocked = !_isLocked;
      if (_isLocked) {
        await _real.ref("caixa:$idBox").update({"estado": "fechado"});
      } else {
        await _real.ref("caixa:$idBox").update({"estado": "aberto"});
      }
    });*/
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLocked
              ? 'Comando de Fechar enviado!'
              : 'Comando de Abrir enviado!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initLocker();
    // Lógica para contagem de encomendas pendentes
    final int count = widget.pendingPackagesCount;
    final String packageStatusText = count == 0 ? 'Nenhuma' : count.toString();
    final String packageLabel = count == 1
        ? 'Encomenda Pendente'
        : 'Encomendas Pendentes';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Controle da Caixa',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),

          // Status da Caixa
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const PandoraIcon(size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Status da Pandora',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      /*
                      _buildStatusTile(
                        LucideIcons.wifi,
                        _isConnected ? Colors.green : Colors.red,
                        'Conexão',
                        _isConnected ? 'Online' : 'Offline',
                      ),
                      _buildStatusTile(
                        LucideIcons.battery,
                        Colors.green,
                        'Bateria',
                        '85%',
                      ),*/
                      _buildStatusTile(
                        _isLocked ? LucideIcons.lock : LucideIcons.unlock,
                        _isLocked ? Colors.red : Colors.green,
                        'Status',
                        _isLocked ? 'Trancada' : 'Aberta',
                      ),
                      _buildStatusTile(
                        LucideIcons.package,
                        /*count > 0 ?*/ Colors.blue, // : Colors.grey,
                        "Box",
                        widget.idBox,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Controles Principais
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Controle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _handleLockToggle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLocked ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(30),
                        elevation: 6,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isLocked ? LucideIcons.lock : LucideIcons.unlock,
                            size: 40,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLocked ? 'Abrir' : 'Fechar',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      /*
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              print("Verificar Encomendas Clicado");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(LucideIcons.package, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  'Verificar Encomendas',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: _handleEmergencyOpen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  LucideIcons.alertTriangle,
                                  size: 24,
                                  color: Colors.orange,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Abertura Emergência',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Configurações (Switches)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurações',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 24),
                  /*
                  _buildSwitchTile(
                    'Travamento Automático',
                    _autoLock,
                    (val) => setState(() => _autoLock = val),
                  ),*/
                  _buildSwitchTile(
                    'Notificações',
                    _notifications,
                    (val) => setState(() => _notifications = val),
                  ) /*
                  _buildSwitchTile(
                    'Conexão Wi-Fi',
                    _isConnected,
                    (val) => setState(() => _isConnected = val),
                  ),*/,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final Color primaryColor = Theme.of(context).primaryColor;
    const int alpha50Percent = 128; // 50% de opacidade

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor.withAlpha(alpha50Percent),
            activeThumbColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
