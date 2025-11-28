// lib/services/fcm_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user_model.dart';
import 'database_service.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _setupToken();
    await _listenTokenRefresh();
  }

  Future<void> _setupToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveToken(token);
    }
  }

  Future<void> _listenTokenRefresh() async {
    _fcm.onTokenRefresh.listen((newToken) async {
      await _saveToken(newToken);
    });
  }

  Future<void> _saveToken(String token) async {
    final DatabaseService databaseService = DatabaseService();
    //User? user = await databaseService.getUserByEmail("as");
    print(token);

    await databaseService.saveTokenFCM(token, "1");
  }
}
