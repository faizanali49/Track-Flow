import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/services/firebase_service.dart';
import 'package:trackerdesktop/views/widgets/paused_logic.dart';

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
      final logger = Logger();
      // We no longer need to get the username here as FirestoreService fetches it internally.
      // final username = ref.watch(userNameProvider);

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
                    controller: _textFieldController,
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
                        onPressed: () async {
                          final bool wasRunning = stopwatchState.isRunning;
                          stopwatchNotifier.pause();
                          ref.read(pausedstatus.notifier).state = true;
                          final result = await pausedStatus(
                            _textFieldController.text,
                            stopwatchState,
                            context,
                            wasRunning,
                            stopwatchNotifier,
                            ref,
                          );
                          if (result != 'success') {
                            logger.e("❌ Failed to pause status.");
                          }
                          context.pop();
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
