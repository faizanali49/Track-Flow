// lib/services/windows_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WindowsAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User not found');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', user.uid);
      await prefs.setString('email', user.email ?? '');


      print('Native login successful for ${user.email}');
      return true;
    } catch (e) {
      print('WindowsAuthService error: $e');
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    final currentUser = _auth.currentUser;
    return currentUser != null;
  }
  Future<String?> getUserId() async {
    return _auth.currentUser?.uid;
  }
  Future<String?> getUserEmail() async {
    return _auth.currentUser?.email;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🚪 User signed out.');
  }
}
