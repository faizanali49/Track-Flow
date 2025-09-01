// lib/services/firestore_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setStatusOnline(String userId, String onlineComment) async {
    final currentTime = DateTime.now();

    try {
      await _db
          .collection('employee_status')
          .doc(userId)
          .collection('history')
          .add({
            'user': userId,
            'status': 'online',
            'date': currentTime.toString(),
            'online_comment': onlineComment,
          });
      print("Status updated successfully!");
    } catch (e) {
      print("Error saving status: $e");
    }
  }

  Future<void> setStatusPaused(
    DateTime pauseTime,
    String userId,
    String pausedComment,
  ) async {
    try {
      // Add to activities collection (same as offline)
      // await _db.collection('users').doc(userId).collection('activities').add({
      //   'timestamp': pauseTime,
      //   'action': 'paused',
      //   'reason': pausedComment,
      // });

      // Update main status document (same as offline)
      await _db
          .collection('employee_status')
          .doc(userId)
          .collection('history')
          .add({
            'status': 'paused',
            'last_paused': pauseTime,
            'pause_reason': pausedComment,
          });

      print("Status updated successfully!");
    } catch (e) {
      print("Error saving status: $e");
      throw e; // Re-throw to be caught by the caller
    }
  }

  Future<void> setStatusResumed(String userId) async {
    final currentTime = DateTime.now();

    try {
      await _db
          .collection('employee_status')
          .doc(userId)
          .collection('history')
          .add({'status': 'resumed', 'date': currentTime.toIso8601String()});
      print("Status resumed updated successfully!");
    } catch (e) {
      print("Error saving status: $e");
    }
  }

  Future<void> setStatusOffline(
    int offlineTime,
    String userId,
    String reason,
    String description,
  ) async {
    try {
      await _db
          .collection('employee_status')
          .doc(userId)
          .collection('history')
          .add({
            'timestamp': offlineTime,
            'action': 'offline',
            'reason': reason,
            'description': description,
          });

      // await FirebaseFirestore.instance.collection('users').doc(userId).update({
      //   'status': 'offline',
      //   'last_offline': offlineTime,
      // });
      print('Status set to offline successfully');
    } catch (e) {
      print('Error setting offline status: $e');
    }
  }

  Future<void> getAllStatusHistoryAndSaveToJson(String userId) async {
    try {
      final snapshot = await _db
          .collection('employee_status')
          .doc(userId)
          .collection('history')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> statusHistoryList = [];

        // Loop through all documents and extract the data
        for (var document in snapshot.docs) {
          statusHistoryList.add(document.data());
        }

        // Convert the list of status history to JSON
        String jsonString = jsonEncode(statusHistoryList);

        // Save the JSON data to a file
        File file = File('status_history_$userId.json');
        await file.writeAsString(jsonString);

        print('Status history saved to status_history_$userId.json');
      } else {
        print('No status history found for user: $userId');
      }
    } catch (e) {
      print("Error fetching status history: $e");
    }
  }
}
