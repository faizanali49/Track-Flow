import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/services/firebase_service.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:intl/intl.dart';

class AppStateManager {
  static const int maxInactiveHours = 16;

  // Restore app state on startup
  static Future<void> restoreAppState(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final firestoreService = FirestoreService();
    final userId = ref.watch(userNameProvider);
    if (userId! == null || userId.isEmpty) {
      return;
    }

    // Check if too much time has elapsed
    final autoOffline = await shouldAutoSetOffline();

    if (autoOffline) {
      // More than 16 hours have passed - set user to offline
      // The userId is now fetched internally by the FirestoreService,
      // so we remove it from the method call.
      await firestoreService.setStatus(
        status: 'Offline',
        offlineTime: DateTime.now().second,
        title: "Automatic offline after 16+ hours of inactivity",
      );

      // Reset all states
      ref.read(onlinestatus.notifier).state = false;
      ref.read(pausedstatus.notifier).state = false;
      ref.read(onlineTimeProvider.notifier).state = null;
      ref.read(stopwatchProvider.notifier).reset();

      // Clear stored pause state
      await prefs.remove('pause_date');
      await prefs.remove('start_time');
      await prefs.remove('elapsed_time');
      await prefs.remove('is_online');
      await prefs.remove('is_paused');
    } else {
      // Restore the state based on what was saved
      final wasOnline = prefs.getBool('is_online') ?? false;
      final wasPaused = prefs.getBool('is_paused') ?? false;
      final seconds = prefs.getInt('elapsed_time') ?? 0;
      final onlineStartTime = prefs.getString('start_time');
      final employeeEmail = prefs.getString('employee_email');

      // Update state providers
      if (onlineStartTime != null) {
        ref.read(onlineTimeProvider.notifier).state =
            DateFormat('h:mm:ss a').format(DateTime.parse(onlineStartTime));
      }
      ref.read(onlinestatus.notifier).state = wasOnline;
      ref.read(pausedstatus.notifier).state = wasPaused;

      final stopwatchNotifier = ref.read(stopwatchProvider.notifier);
      if (seconds > 0) {
        // Set the elapsed time
        final elapsed = Duration(seconds: seconds);
        stopwatchNotifier.setTime(elapsed);

        // Start the timer if needed (user was online and not paused)
        if (wasOnline && !wasPaused) {
          stopwatchNotifier.start();
        }
      }

      // If user was online but paused, just restore the UI state
      if (wasOnline && wasPaused) {
        // Don't start the timer, but make sure UI shows paused state
        ref.read(pausedstatus.notifier).state = true;
      }
    }
  }

  // Check if user should be automatically set to offline
  static Future<bool> shouldAutoSetOffline() async {
    final prefs = await SharedPreferences.getInstance();
    final pauseDateStr = prefs.getString('pause_date');

    // If no pause date saved, check the last activity time
    if (pauseDateStr == null) {
      final lastActiveStr = prefs.getString('start_time');
      if (lastActiveStr == null) {
        return false;
      }

      final lastActive = DateTime.parse(lastActiveStr);
      final now = DateTime.now();
      final difference = now.difference(lastActive);

      return difference.inHours > maxInactiveHours;
    }

    final pauseDate = DateTime.parse(pauseDateStr);
    final now = DateTime.now();
    final difference = now.difference(pauseDate);

    return difference.inHours > maxInactiveHours;
  }
}
