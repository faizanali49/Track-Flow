import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';

void onlineAlert(
  BuildContext context,
  WidgetRef ref,
  bool isOnline,
  stopwatchState,
  stopwatchNotifier,
) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent accidental closing
    builder: (BuildContext context) {
      final FirestoreService _firestoreService = FirestoreService();
      final TextEditingController _textFieldController =
          TextEditingController();
      final logger = Logger();

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
                  const Text(
                    'Go Online',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'What are you working on?',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _textFieldController,
                    maxLines: 2,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: 'e.g., Designing dashboard layout',
                      labelStyle: const TextStyle(color: Colors.black45),
                      border: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      suffixIcon: _textFieldController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _textFieldController.clear();
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTextEmpty
                              ? Colors.grey
                              : Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: isTextEmpty
                            ? null
                            : () async {
                                try {
                                  await _firestoreService.setStatus(
                                    status: 'Online',
                                    comment: _textFieldController.text,
                                  );

                                  // Update states
                                  ref
                                      .read(onlineTimeProvider.notifier)
                                      .state = DateFormat(
                                    'h:mm a',
                                  ).format(DateTime.now());
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
                                } catch (e) {
                                  logger.e(" Error in online dialog: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error setting status: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
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
