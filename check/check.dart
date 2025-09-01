import 'dart:convert'; // For JSON encoding
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart'; // For file operations

final FirebaseFirestore _db = FirebaseFirestore.instance;

// void main() async {
//   await getStatusHistoryAndSaveToJson('faizan@scrapbye.com');
// }

Future<void> getStatusHistoryAndSaveToJson(String userId) async {
  try {
    final doc = await _db
        .collection('employee_status')
        .doc(userId)
        .collection('history')
        .get();

    // Check if there are documents in the collection
    if (doc.docs.isNotEmpty) {
      // Map to store the status history data
      List<Map<String, dynamic>> statusHistoryList = [];

      // Loop through all documents and extract the data
      for (var document in doc.docs) {
        statusHistoryList.add(document.data());
      }

      // Convert the list of maps to a JSON string
      String jsonString = jsonEncode(statusHistoryList);

      // Save the JSON string to a file
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
