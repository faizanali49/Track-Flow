import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';

void offlineAlert(
  BuildContext context,
  // Using generic `ref` but expecting a WidgetRef context inside the dialog
  // If this function is called from a provider, ensure the provider passes the correct ref type.
  ref,
  String formattedTime,
  bool isOnline,
  // We use `dynamic` here since the actual type depends on how it's passed from home_controller
  dynamic stopwatchState,
  dynamic stopwatchNotifier,
  Duration total_time,
) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent accidental close
    builder: (BuildContext context) {
      final FirestoreService _firestoreService = FirestoreService();
      final TextEditingController _titleController = TextEditingController();
      final TextEditingController _descriptionController =
          TextEditingController();
      // Use ref.watch inside the builder for correct dependency tracking
      final String username = ref.watch(employeeEmailProvider) ?? 'user';
      final onlineTime = ref.watch(onlineTimeProvider);

      return StatefulBuilder(
        builder: (BuildContext context, setState) {
          _titleController.addListener(() => setState(() {}));
          _descriptionController.addListener(() => setState(() {}));

          final isPaused = ref.watch(pausedstatus);
          final bool isTitleEmpty = _titleController.text.trim().isEmpty;
          final bool isDescriptionEmpty = _descriptionController.text
              .trim()
              .isEmpty;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            child: Container(
              width: 450,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Text(
                    'Go Offline',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // title for going offline
                  TextField(
                    controller: _titleController,
                    maxLength: 25,
                    decoration: InputDecoration(
                      labelText: 'title for offline',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      suffixIcon: _titleController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _titleController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 60,
                    decoration: InputDecoration(
                      labelText: 'Description (optional)',
                      labelStyle: const TextStyle(color: Colors.black54),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      suffixIcon: _descriptionController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _descriptionController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTitleEmpty
                              ? Colors.grey
                              : Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: isTitleEmpty
                            ? null
                            : () async {
                                // Pause the timer if it's running
                                if (stopwatchState.isRunning) {
                                  stopwatchNotifier.pause();
                                }

                                // Stop the time tracking and reset everything
                                stopwatchNotifier.reset();
                                ref.read(onlinestatus.notifier).state = false;

                                // reset paused status if it was paused
                                if (isPaused) {
                                  ref.read(pausedstatus.notifier).state = false;
                                }

                                // Log the activity to Firestore
                                await _firestoreService.setStatus(
                                  status: 'Offline',
                                  offlineTime: total_time.inMinutes,
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                );

                                // Clear ALL relevant SharedPreferences for a clean offline state
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove(
                                  's_employee_email',
                                ); // ADDED: Clear email/company info
                                await prefs.remove(
                                  's_company_email',
                                ); // ADDED: Clear email/company info
                                await prefs.remove('elapsed_time');
                                await prefs.remove('was_online');
                                await prefs.remove('was_paused');
                                await prefs.remove('was_running');
                                await prefs.remove('start_time');
                                await prefs.remove(
                                  'last_closed',
                                ); // ADDED: Clear last closed timestamp

                                // These were present in the old list, keeping them for compatibility
                                await prefs.remove('pause_reason');
                                await prefs.remove('is_paused');
                                await prefs.remove('last_time_spent');
                                await prefs.remove('pause_date');

                                // Reset the Riverpod provider state
                                ref.read(onlineTimeProvider.notifier).state =
                                    null;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status set to Offline'),
                                  ),
                                );
                                Navigator.of(context).pop();
                              },
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
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
