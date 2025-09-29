import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';

final FirestoreService _firestoreService = FirestoreService();
final logger = Logger(); // Add this line

Future<String> pausedStatus(
  String textFieldController,
  dynamic stopwatchState,
  BuildContext context,
  bool wasRunning,
  dynamic stopwatchNotifier,
  dynamic ref,
) async {
  try {
    await _firestoreService.setStatus(
      status: 'paused',
      timestamp: DateTime.now(),
      title: textFieldController,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pause_reason', textFieldController);
    await prefs.setBool('is_paused', true);
    await prefs.setString('pause_date', DateTime.now().toString());
    await prefs.setInt('elapsed_time', stopwatchState.elapsed.inSeconds);

    // Check if context is still valid before using it
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status set to Paused')),
      );
    }

    return 'success';
  } catch (e) {
    logger.e("Error in paused dialog: $e");
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error pausing timer. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (wasRunning) {
      stopwatchNotifier.start();
      ref.read(pausedstatus.notifier).state = false;
    }
    
    return 'error';
  }
}