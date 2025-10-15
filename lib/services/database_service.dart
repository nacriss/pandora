// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/package_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  final String userTableName = 'users';
  final String packageTableName = 'packages';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pandora_smartbox.db');

    // IMPORTANTE: Zere a versão ou desinstale o app para recriar com as novas colunas UNIQUE
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabela de Usuários
    await db.execute('''
      CREATE TABLE $userTableName (
        email TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        boxId TEXT NOT NULL UNIQUE,      
        phone TEXT UNIQUE               
      )
    ''');

    // 2. Tabela de Encomendas (Linkada ao email do usuário)
    await db.execute('''
      CREATE TABLE $packageTableName (
        id TEXT PRIMARY KEY,
        userEmail TEXT NOT NULL,
        sender TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        estimatedDelivery TEXT NOT NULL,
        trackingCode TEXT NOT NULL,
        photo TEXT,
        FOREIGN KEY (userEmail) REFERENCES $userTableName (email) ON DELETE CASCADE
      )
    ''');
  }

  // ------------------------------------
  // --- Operações CRUD (Usuários) ---
  // ------------------------------------

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      userTableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      userTableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      userTableName,
      user.toMap(),
      where: 'email = ?',
      whereArgs: [user.email],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ------------------------------------
  // --- Operações CRUD (Encomendas) ---
  // ------------------------------------

  Future<void> insertPackage(Package package) async {
    final db = await database;
    await db.insert(
      packageTableName,
      package.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Package>> getPackagesByUser(String userEmail) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      packageTableName,
      where: 'userEmail = ?',
      whereArgs: [userEmail],
      orderBy: 'estimatedDelivery ASC', // Ordena por data
    );

    return List.generate(maps.length, (i) {
      return Package.fromMap(maps[i]);
    });
  }

  Future<void> updatePackageStatus(
    String packageId,
    PackageStatus status,
  ) async {
    final db = await database;
    await db.update(
      packageTableName,
      {'status': status.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [packageId],
    );
  }
}
