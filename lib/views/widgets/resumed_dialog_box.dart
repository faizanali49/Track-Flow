import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';

int resumeAlert(
  BuildContext context,
  WidgetRef ref,
  String formattedTime,
  bool isOnline,
  stopwatchState,
  stopwatchNotifier,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final FirestoreService _firestoreService = FirestoreService();
      final _username = ref.watch(userNameProvider);
      final stopwatchState = ref.watch(stopwatchProvider);
      final stopwatchNotifier = ref.read(stopwatchProvider.notifier);

      return Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Confirm Action',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent[100],
                ),
              ),
              const SizedBox(height: 12),

              // Message
              const Text(
                'Please press OK to pause or resume the tracker.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      // Toggle pause or resume
                      stopwatchState.isRunning
                          ? stopwatchNotifier.pause()
                          : stopwatchNotifier.start();

                      ref.read(pausedstatus.notifier).state = false;

                      await _firestoreService.setStatusResumed(_username);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Status set to ${stopwatchState.isRunning ? "Paused" : "Running"}',
                          ),
                        ),
                      );

                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return 0;
}
