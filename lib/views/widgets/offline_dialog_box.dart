import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';

void offlineAlert(
  BuildContext context,
  WidgetRef ref,
  String formattedTime,
  bool isOnline,
  stopwatchState,
  stopwatchNotifier,
  Duration total_time,
) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent accidental close
    builder: (BuildContext context) {
      final FirestoreService _firestoreService = FirestoreService();
      // final String _userId = "faizan@scrapbye.com";
      final _userId = ref.watch(userNameProvider);
      final TextEditingController _titleController = TextEditingController();
      final TextEditingController _descriptionController =
          TextEditingController();
      String username = ref.watch(userNameProvider);
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.power_settings_new,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Go Offline',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Please provide a title and description to proceed offline.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // Title Input
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter title...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description Input
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter description...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTitleEmpty || isDescriptionEmpty
                              ? Colors.grey[400]
                              : Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: (isTitleEmpty || isDescriptionEmpty)
                            ? null
                            : () async {
                                final String title = _titleController.text
                                    .trim();
                                final String description =
                                    _descriptionController.text.trim();

                                await _firestoreService.setStatusOffline(
                                  total_time.inSeconds,
                                  _userId,
                                  title,
                                  description.isNotEmpty
                                      ? description
                                      : 'No description',
                                );

                                ref.read(onlineTimeProvider.notifier).state =
                                    formattedTime;
                                stopwatchNotifier.reset();
                                ref.read(pausedstatus.notifier).state = false;
                                ref.read(onlinestatus.notifier).state = false;

                                await _firestoreService
                                    .getAllStatusHistoryAndSaveToJson(username);

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('pause_reason');
                                await prefs.remove('is_paused');
                                await prefs.remove('elapsed_time');
                                await prefs.remove('last_time_spent');
                                await prefs.remove('was_running');
                                await prefs.remove('was_online');
                                await prefs.remove('was_paused');
                                await prefs.remove('pause_date');
                                await prefs.remove('start_time');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status set to Offline'),
                                  ),
                                );
                                ref.read(onlineTimeProvider.notifier).state =
                                    null;

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
