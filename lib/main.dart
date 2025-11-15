// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'models/package_model.dart';
import 'models/user_model.dart';
import 'services/database_service.dart';

import 'package:flutter/material.dart';
import 'firebase_options.dart'; // gerado automaticamente

void main() async {
  // Garante que o binding está pronto para chamadas de plugin (como sqflite)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PandoraApp());
}

String idBox = "";

class PandoraApp extends StatelessWidget {
  const PandoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pandora Smart Box',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: const Color(0xFFF59E0B),
        useMaterial3: true,
      ),
      // Remove a bandeira vermelha de debug
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // 1. Estados de Autenticação e Dados
  bool _isAuthenticated = false;
  String _userEmail = '';
  bool _isLoginView = true;
  User? _currentUser;

  List<Package> _packages = [];

  final DatabaseService _databaseService = DatabaseService();

  // 2. Funções de Navegação
  void _showRegisterView() {
    setState(() {
      _isLoginView = false;
    });
  }

  void _showLoginView() {
    setState(() {
      _isLoginView = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
      _userEmail = '';
      _currentUser = null;
      _packages = [];
    });
  }

  // 3. Funções de Autenticação e Dados (SQLite)

  // Calcula o número de pacotes pendentes (para a tela de controle)
  int get _pendingPackagesCount {
    return _packages.where((pkg) => pkg.status == PackageStatus.pending).length;
  }

  // Função interna para carregar dados após o login/cadastro
  Future<void> _loadUserData(String email) async {
    final user = await _databaseService.getUserByEmail(email);
    final packages = await _databaseService.getPackagesByUser(email);

    setState(() {
      _userEmail = email;
      _isAuthenticated = true;
      _currentUser = user;
      _packages = packages;
    });
  }

  // Lógica de REGISTRO
  Future<void> _handleRegistration(
    String email,
    String password,
    String boxId,
    String? phone,
  ) async {
    final newUser = User(
      email: email,
      password: password,
      boxId: boxId,
      phone: phone,
    );

    try {
      await _databaseService.insertUser(newUser);

      await _loadUserData(email);
      _isLoginView = true;
    } catch (e) {
      if (mounted) {
        /*ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erro: E-mail, Celular ou ID da Caixa já cadastrado.',
            ),
          ),
        );*/
      }
    }
  }

  void minhaFuncao() {
    print("Função chamada!");
  }

  // Lógica de LOGIN
  Future<void> _handleLogin(String email, String password) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    await _handleRegistration("as", "as", "as", "as"); //pre-sequel

    //_databaseService.lerDados();
    //print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n Descrição do produto: \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

    //final storedUser = await _databaseService.getUserByEmail(cleanEmail);
    String realSenha = "p";
    realSenha = await _databaseService.getSenhaRegsReal(cleanEmail);
    if ( /*storedUser != null &&*/ realSenha.trim() == cleanPassword) {
      idBox = cleanEmail;
      final User u = User(email: "as", password: "as", boxId: idBox);
      await _databaseService.updateUser(u);
      await _loadUserData("as");
      await _loadRealPackge(); //encomendas
      //print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n ACESS: \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Não achamos seu cadastro!')));
      //print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n NEGADO: \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
      /*if (mounted) {
        // Mensagem de erro ao falhar o login
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Não achamos seu cadastro!')));
      }*/
    }
  }

  Future<void> _loadRealPackge() async {
    await _databaseService.clearPackages();
    Map pacRealProds = await _databaseService.getProd(idBox);
    //final pacProds = await _databaseService.getPackagesByUser("as");
    //print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n NEGADO: \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n",);

    pacRealProds.forEach((key, value) async {
      final PackageStatus p;
      final String dateT = value['data_da_chegada'],
          horaT = value['hora_da_chegada'];
      if (value['entregue'] == false) {
        p = PackageStatus.pending;
      } else {
        p = PackageStatus.arrived;
      }
      Package newPackage = new Package(
        id: key.toString(),
        userEmail: "as",
        sender: value['sender'],
        description: value['descricao'],
        status: p,
        estimatedDelivery: "$dateT - $horaT",
        trackingCode: key.toString(),
      );
      await _handleAddPackage(newPackage);
    });
  }

  // Lógica para ADICIONAR ENCOMENDA
  Future<void> _handleAddPackage(Package newPackage) async {
    await _databaseService.insertPackage(newPackage);
    await _loadUserData(_userEmail); // Recarrega a lista para atualizar a UI
  }

  // Lógica para ATUALIZAR DADOS DO USUÁRIO
  Future<void> _handleUserUpdate(User updatedUser) async {
    try {
      await _databaseService.updateUser(updatedUser);
      await _loadUserData(_userEmail); // Recarrega os dados do usuário atual
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erro: ID da Caixa ou Celular já em uso por outro usuário.',
            ),
          ),
        );
      }
    }
  }

  // A função _handleUpdatePhoto original (mantida)
  void _handleUpdatePhoto(String packageId, String photo) {
    setState(() {
      _packages = _packages.map((pkg) {
        if (pkg.id == packageId) {
          return pkg.copyWith(photo: photo);
        }
        return pkg;
      }).toList();
    });
  }

  // 💡 NOVO: Wrapper para recarregar dados
  Future<void> _handleReloadData() async {
    await _loadRealPackge();
    // Chamamos _loadUserData com o email armazenado
    await _loadUserData(_userEmail);
  }

  @override
  Widget build(BuildContext context) {
    // Se AUTENTICADO E DADOS CARREGADOS
    if (_isAuthenticated && _currentUser != null) {
      return HomeScreen(
        userEmail: _userEmail,
        onLogout: _handleLogout,
        packages: _packages,
        onAddPackage: _handleAddPackage,
        onUpdatePhoto: _handleUpdatePhoto,

        // Afirma que o usuário não é nulo neste ponto
        currentUser: _currentUser!,
        onUserUpdated: _handleUserUpdate,

        // Passa a contagem de pendentes
        pendingPackagesCount: _pendingPackagesCount,

        // 💡 NOVO: Passar o callback aqui
        onReloadData: _handleReloadData,
        idBox: idBox,
      );
    }

    // Se NÃO AUTENTICADO, alterna entre Login e Cadastro
    if (_isLoginView) {
      return LoginScreen(
        onLogin: (email, password) => _handleLogin(email, password),
        onRegisterRequested: _showRegisterView,
      );
    } else {
      return RegisterScreen(
        onRegistered: (email, password, boxId, phone) =>
            _handleRegistration(email, password, boxId, phone),
        onBackToLogin: _showLoginView,
      );
    }
  }
}
