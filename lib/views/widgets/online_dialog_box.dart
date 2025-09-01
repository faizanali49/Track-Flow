import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';

void onlineAlert(
  BuildContext context,
  WidgetRef ref,
  // String formattedTime,
  bool isOnline,
  stopwatchState,
  stopwatchNotifier,
) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent accidental closing
    builder: (BuildContext context) {
      final FirestoreService _firestoreService = FirestoreService();
      final String _userId = ref.watch(userNameProvider);
      final TextEditingController _textFieldController =
          TextEditingController();

      return StatefulBuilder(
        builder: (BuildContext context, setState) {
          final bool isTextEmpty = _textFieldController.text.trim().isEmpty;

          _textFieldController.addListener(() => setState(() {}));

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 12,
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      const Icon(
                        Icons.wifi,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Go Online',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  const Text(
                    'Please enter a task title and press OK to go online.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Input field
                  TextField(
                    controller: _textFieldController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Enter task title...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTextEmpty
                              ? Colors.grey[400]
                              : Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          elevation: 3,
                        ),
                        onPressed: isTextEmpty
                            ? null
                            : () async {
                                await _firestoreService.setStatusOnline(
                                  _userId,
                                  _textFieldController.text.trim(),
                                );
                                String formattedTime = DateFormat(
                                  'h:mm a',
                                ).format(DateTime.now());
                                ref.read(onlineTimeProvider.notifier).state =
                                    formattedTime;

                                if (!stopwatchState.isRunning) {
                                  stopwatchNotifier.start();
                                }

                                ref.read(onlinestatus.notifier).state = true;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Status set to Online'),
                                  ),
                                );

                                Navigator.of(context).pop();
                              },
                        child: const Text(
                          'OK',
                          style: TextStyle(fontWeight: FontWeight.w500),
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
