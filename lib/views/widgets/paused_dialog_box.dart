import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';

void pausedAlert(
  BuildContext context,
  WidgetRef ref,
  String formattedTime,
  bool isOnline,
  stopwatchState,
  stopwatchNotifier,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final FirestoreService _firestoreService = FirestoreService();
      final stopwatchState = ref.watch(stopwatchProvider);
      final stopwatchNotifier = ref.read(stopwatchProvider.notifier);
      final TextEditingController _textFieldController =
          TextEditingController();
      final username = ref.watch(userNameProvider);

      return StatefulBuilder(
        builder: (context, setState) {
          bool isTextEmpty = _textFieldController.text.trim().isEmpty;

          _textFieldController.addListener(() {
            setState(() {});
          });

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.white,
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Do you want to proceed?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    'Please enter reason and press OK to Pause the tracker.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),

                  // Input Field
                  TextField(
                    controller: _textFieldController,
                    decoration: InputDecoration(
                      hintText: 'Enter reason',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('Cancel'),
                      ),

                      const SizedBox(width: 10),

                      // OK
                      ElevatedButton(
                        onPressed: isTextEmpty
                            ? null
                            : () async {
                                final wasRunning = stopwatchState.isRunning;

                                try {
                                  stopwatchNotifier.pause();
                                  DateTime pauseTime = DateTime.now();

                                  await _firestoreService.setStatusPaused(
                                    pauseTime,
                                    username,
                                    _textFieldController.text.trim(),
                                  );

                                  ref.read(pausedstatus.notifier).state = true;

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    'pause_date',
                                    pauseTime.toIso8601String(),
                                  );
                                  await prefs.setString(
                                    'pause_reason',
                                    _textFieldController.text.trim(),
                                  );
                                  await prefs.setBool('is_paused', true);
                                  await prefs.setBool('was_running', false);
                                  await prefs.setBool('was_paused', true);
                                  await prefs.setString(
                                    'elapsed_time',
                                    stopwatchState.elapsed.inMilliseconds
                                        .toString(),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Timer paused successfully',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error pausing timer. Please try again.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );

                                  if (wasRunning) {
                                    stopwatchNotifier.start();
                                    ref.read(pausedstatus.notifier).state =
                                        false;
                                  }
                                }

                                Navigator.of(context).pop();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
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
    },
  );
}
