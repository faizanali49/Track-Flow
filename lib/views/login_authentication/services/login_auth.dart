// lib/services/windows_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/states.dart' as AppStateManager;

class WindowsAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SharedPreferences keys - Define them as constants for consistency
  static const String _prefsKeyUserId = 'userId';
  static const String _prefsKeyCompanyEmail = 'companyEmail';
  static const String _prefsKeyEmployeeEmail = 'employeeEmail'; // Add this key
  // Optional: Store company name if fetched
  static const String _prefsKeyCompanyName = 'companyName';

  /// Signs in an employee using company and employee credentials.
  /// Stores relevant session data (companyEmail, employeeEmail, userId) upon successful login.
  Future<void> signInWithEmployeeCredentials({
    required String companyEmail,
    required String employeeEmail,
    required String password,
    required WidgetRef ref, // <-- add this so we can restore state
  }) async {
    try {
      // 🔑 Authenticate with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: employeeEmail,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Authenticated user object is null.',
        );
      }

      // 🔑 Validate company + employee exist in Firestore
      final companyDoc = await _firestore
          .collection('companies')
          .doc(companyEmail.toLowerCase())
          .get();
      if (!companyDoc.exists) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'company-not-found',
          message: 'The specified company does not exist.',
        );
      }

      final employeeDoc = await _firestore
          .collection('companies')
          .doc(companyEmail.toLowerCase())
          .collection('employees')
          .doc(employeeEmail.toLowerCase())
          .get();
      if (!employeeDoc.exists) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'employee-not-found',
          message: 'Employee record not found for this company.',
        );
      }

      // 🔑 Store session in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyUserId, user.uid);
      await prefs.setString(_prefsKeyCompanyEmail, companyEmail.toLowerCase());
      await prefs.setString(
        _prefsKeyEmployeeEmail,
        employeeEmail.toLowerCase(),
      );
      await prefs.setString(
        _prefsKeyCompanyName,
        companyDoc.data()?['company'] as String? ?? 'Unknown Company',
      );

      // 🔥 Restore previous app state (stopwatch, pause, online)
      await AppStateManager.restoreAppState(ref);

      print(
        'Native employee login successful for ${user.email} under company $companyEmail',
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      throw Exception('An unexpected error occurred during login: $e');
    }
  }

  /// Checks if a user is currently authenticated.
  Future<bool> isAuthenticated() async {
    final currentUser = _auth.currentUser;
    return currentUser != null;
  }

  /// Gets the current authenticated user's Firebase UID.
  Future<String?> getUserId() async {
    // Try to get from Firebase Auth first (most reliable if online)
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }
    // Fallback to SharedPreferences (useful if offline and data was stored)
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyUserId);
  }

  /// Gets the current authenticated user's email.
  Future<String?> getUserEmail() async {
    // Try to get from Firebase Auth first
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser.email;
    }
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      _prefsKeyEmployeeEmail,
    ); // Use the stored employee email
  }

  /// Gets the company email associated with the current session.
  Future<String?> getCompanyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyCompanyEmail);
  }

  /// Gets the company name associated with the current session (if stored).
  Future<String?> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyCompanyName);
  }

  /// Signs out the user and clears stored session data.
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    // Clear only the specific keys related to this service, or clear all if preferred
    // Clearing specific keys is generally safer if other parts of the app use shared prefs
    await prefs.remove(_prefsKeyUserId);
    await prefs.remove(_prefsKeyCompanyEmail);
    await prefs.remove(_prefsKeyEmployeeEmail);
    await prefs.remove(_prefsKeyCompanyName);
    // Or, if this service manages all auth-related prefs: await prefs.clear();
  }
}
