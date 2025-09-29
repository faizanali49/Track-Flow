import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:trackerdesktop/views/login_authentication/services/login_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WindowsAuthService _authService = WindowsAuthService();
  final logger = Logger();

  /// Get employee email from FirebaseAuth
  String? get _employeeEmail => _auth.currentUser?.email;

  /// Helper: Get current user ID and company ID from WindowsAuthService
  Future<Map<String, String?>> _getAuthData() async {
    final employeeEmail = await _authService.getUserId();
    final companyId = await _authService.getCompanyEmail();

    if (employeeEmail == null) {
      logger.e("❌ Error: No employee email id found.");
    }
    if (companyId == null) {
      logger.e("❌ Error: No company email id found.");
    }

    return {'employeeEmail': employeeEmail, 'companyId': companyId};
  }

  /// General-purpose status setter
  Future<void> setStatus({
    required String status,
    String? comment,
    String? title,
    String? description,
    int? offlineTime,
    DateTime? timestamp,
    bool isAutomatic = false, // Add this param for auto-pause
  }) async {
    final authData = await _getAuthData();
    final companyId = authData['companyId'];
    final time = timestamp ?? DateTime.now();

    if (_employeeEmail == null || companyId == null) {
      logger.e("❌ Cannot update status: Missing auth data.");
      return;
    }

    try {
      final employeeDoc = _db
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(_employeeEmail);

      final activitiesCollection = _db
          .collection('companies')
          .doc(companyId)
          .collection('employees')
          .doc(_employeeEmail) // log activity under the email
          .collection('activities');

      // Activity history entry with automatic flag if needed
      final activityData = {
        'timestamp': time,
        'status': status,
        if (comment != null) 'comment': comment,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (offlineTime != null) 'spended_time': offlineTime,
        if (isAutomatic) 'automatic': true,
      };

      // Update map for current status
      final statusUpdateData = {
        'status': status,
        if (status == 'online') 'last_online': time,
        if (status == 'online' && comment != null) 'current_task': comment,
        if (status == 'paused') ...{
          'last_paused': time,
          if (title != null) 'pause_reason': title,
        },
        if (status == 'resumed') 'last_resumed': time,
        if (status == 'offline') ...{
          'last_offline': time,
          if (title != null) 'offline_reason': title,
        },
      };

      // Write activity log
      await activitiesCollection.add(activityData);

      // Update current status
      await employeeDoc.update(statusUpdateData);

      logger.i("✅ Status '$status' updated successfully!");
    } catch (e) {
      logger.e("❌ Error updating status '$status': $e");
    }
  }
}