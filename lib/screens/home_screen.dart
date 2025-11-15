// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/package_model.dart';
import '../models/user_model.dart';
import 'package_list_screen.dart';
import 'smart_box_control_screen.dart';
import 'profile_screen.dart';
import 'add_package_screen.dart'; // Necessário para a navegação do FAB

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final Function() onLogout;
  final List<Package> packages;
  final Future<void> Function(Package) onAddPackage;
  final void Function(String, String) onUpdatePhoto;
  final User
  currentUser; // Corrigido para ser não nulo, pois só acessa aqui se estiver logado
  final Future<void> Function(User) onUserUpdated;
  // 💡 NOVO: Adicione o callback para recarregar dados
  final Future<void> Function() onReloadData;
  // 💡 NOVO: Adicione o callback para recarregar dados
  final String idBox;

  const HomeScreen({
    super.key,
    required this.userEmail,
    required this.onLogout,
    required this.packages,
    required this.onAddPackage,
    required this.onUpdatePhoto,
    required this.currentUser, // Deve ser não nulo
    required this.onUserUpdated,
    required int pendingPackagesCount,
    // 💡 NOVO: Adicione o callback ao construtor
    required this.onReloadData,
    required this.idBox,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Função para navegar para a tela de Adicionar Encomenda (chamada pelo FAB da lista)
  void _navigateToAddPackageScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddPackageScreen(
          userEmail: widget.userEmail,
          onPackageAdded: widget.onAddPackage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Definição das Telas de Conteúdo
    final List<Widget> widgetOptions = <Widget>[
      // 0. Controle (Primeira aba)
      SmartBoxControlScreen(idBox: widget.idBox),

      // 1. Encomendas (Aba do meio)
      PackageListScreen(
        packages: widget.packages,
        onUpdatePhoto: widget.onUpdatePhoto,
        onAddPackageRequested: () =>
            _navigateToAddPackageScreen(context), // FAB chama esta função
      ),

      // 2. Perfil (Última aba)
      /*ProfileScreen(
        currentUser: widget.currentUser,
        onUserUpdated: widget.onUserUpdated,
      ),*/
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pandora Smart Box'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.repeat),
            /*onPressed: widget.onLogout,
            tooltip: 'Sair',*/
            onPressed: widget.onReloadData, // Chama o callback
            tooltip: 'Recarregar Dados',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),

      // 2. BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.box),
            label: 'Controle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Encomendas',
          ),
          //BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors
            .grey, // Corrigido para evitar erro de Theme.of(context).primaryColor com unselected
        onTap: _onItemTapped,
      ),
    );
  }
}
