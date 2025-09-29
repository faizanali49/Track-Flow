import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';
  
    Widget displayTimer(BuildContext context, WidgetRef ref) {
    final stopwatchState = ref.watch(stopwatchProvider);
    final stopwatchNotifier = ref.read(stopwatchProvider.notifier);
    final isOnline = ref.watch(onlinestatus);
    final isPaused = ref.watch(pausedstatus);
    final _firestoreService = FirestoreService();
    final logger = Logger();

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$hours:$minutes:$seconds';
    }

    if (!isOnline) {
      return const Text(
        '00:00:00',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (isPaused) {
          // Resume confirmation - using adapted logic from resumed_dialog_box.dart
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resume Task',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Are you ready to resume your task?',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
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
                          onPressed: () async {
                            try {
                              // Update Riverpod state
                              stopwatchNotifier.start();
                              ref.read(pausedstatus.notifier).state = false;

                              // Call Firestore
                              await _firestoreService.setStatus(
                                status: 'resumed',
                                comment: 'Resumed working task',
                              );

                              // Show success message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status set to Resumed'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }

                              // Close dialog
                              Navigator.pop(context);
                            } catch (e) {
                              logger.e("❌ Error resuming task: $e");
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error resuming task: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
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
                          child: const Text('Resume'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Pause confirmation - using adapted logic from paused_dialog_box.dart
          final reasonController = TextEditingController();

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) {
                final isTextEmpty = reasonController.text.trim().isEmpty;

                reasonController.addListener(() => setState(() {}));

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pause Task',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Why are you pausing?',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: reasonController,
                          maxLines: 2,
                          maxLength: 30,
                          decoration: InputDecoration(
                            labelText: 'e.g., Quick break, meeting, etc.',
                            labelStyle: const TextStyle(color: Colors.black45),
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                            suffixIcon: reasonController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      reasonController.clear();
                                    },
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                              onPressed: isTextEmpty
                                  ? null
                                  : () async {
                                      try {
                                        // Update local state
                                        final bool wasRunning =
                                            stopwatchState.isRunning;
                                        stopwatchNotifier.pause();
                                        ref.read(pausedstatus.notifier).state =
                                            true;

                                        // Update Firestore
                                        await _firestoreService.setStatus(
                                          status: 'paused',
                                          timestamp: DateTime.now(),
                                          title: reasonController.text.trim(),
                                        );

                                        // Save to SharedPreferences
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setString(
                                          'pause_reason',
                                          reasonController.text.trim(),
                                        );
                                        await prefs.setBool('is_paused', true);
                                        await prefs.setString(
                                          'pause_date',
                                          DateTime.now().toString(),
                                        );
                                        await prefs.setInt(
                                          'elapsed_time',
                                          stopwatchState.elapsed.inSeconds,
                                        );

                                        // Show success message
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Status set to Paused',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }

                                        // Close dialog
                                        Navigator.pop(context);
                                      } catch (e) {
                                        logger.e("❌ Error pausing task: $e");
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error pausing task: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Pause'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
      child: Text(
        formatDuration(stopwatchState.elapsed),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isPaused ? Colors.orange : Colors.green,
          letterSpacing: 1.2,
        ),
      ),
    );
  }