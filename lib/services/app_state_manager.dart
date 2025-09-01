import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/services/firebase_service.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppStateManager {
  static const int MAX_INACTIVE_HOURS = 16;

  // Restore app state on startup
  static Future<void> restoreAppState(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final firestoreService = FirestoreService();
    final userId = ref.watch(userNameProvider);

    // Check if too much time has elapsed
    final autoOffline = await shouldAutoSetOffline();

    if (autoOffline) {
      // More than 16 hours have passed - set user to offline
      await firestoreService.setStatusOffline(
        DateTime.now().second,
        userId,
        "Automatic offline after 16+ hours of inactivity",
        '',
      );

      // Reset all states
      ref.read(onlinestatus.notifier).state = false;
      ref.read(pausedstatus.notifier).state = false;
      ref.read(onlineTimeProvider.notifier).state = null;
      ref.read(stopwatchProvider.notifier).reset();

      // Clear stored pause state
      await prefs.remove('pause_date');
      await prefs.remove('was_running');
      await prefs.remove('was_online');
      await prefs.remove('was_paused');
      await prefs.remove('last_time_spent');
      await prefs.remove('start_time');

      return;
    }

    // Normal state restoration
    final wasOnline = prefs.getBool('was_online') ?? false;
    final wasPaused = prefs.getBool('was_paused') ?? false;
    final seconds = prefs.getInt('last_time_spent') ?? 0;

    // Restore online status
    ref.read(onlinestatus.notifier).state = wasOnline;

    // Restore pause status
    ref.read(pausedstatus.notifier).state = wasPaused;

    // Restore start time if was online
    final startTimeStr = prefs.getString('start_time');
    if (wasOnline && startTimeStr != null) {
      // Format the timestamp for display
      final startDate = DateTime.parse(startTimeStr);
      final formattedTime = DateFormat('h:mm a').format(startDate);
      ref.read(onlineTimeProvider.notifier).state = formattedTime;
    }

    // Restore elapsed time
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

      return difference.inHours > MAX_INACTIVE_HOURS;
    }

    final pauseDate = DateTime.parse(pauseDateStr);
    final now = DateTime.now();
    final difference = now.difference(pauseDate);

    // If more than MAX_INACTIVE_HOURS hours have passed
    return difference.inHours > MAX_INACTIVE_HOURS;
  }
}
