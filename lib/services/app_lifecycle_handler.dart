import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/services/firebase_service.dart';
import 'package:window_manager/window_manager.dart';

/// Handles application lifecycle events to manage timer state
/// when app loses focus, is minimized, or system sleeps
class AppLifecycleHandler with WidgetsBindingObserver, WindowListener {
  final Duration Function() getCurrentTime;
  final bool Function() isRunning;
  final bool Function() isOnline;
  final bool Function() isPaused;

  AppLifecycleHandler({
    required this.getCurrentTime,
    required this.isRunning,
    required this.isOnline,
    required this.isPaused,
  });

  void init() {
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _saveCurrentState();
      // send paused event to firebase
    }
  }

  @override
  void onWindowBlur() {
    _saveCurrentState();
  }

  void _saveCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeEmail = prefs.getString('employee_email');
    if (employeeEmail == null || employeeEmail.isEmpty) {
      return;
    }
    final currentTime = getCurrentTime();
    final running = isRunning();
    final online = isOnline();
    final paused = isPaused();

    await prefs.setInt('last_time_spent', currentTime.inSeconds);
    await prefs.setBool('was_running', running);
    await prefs.setBool('was_online', online);
    await prefs.setBool('was_paused', paused);
    await prefs.setString('employee_email', employeeEmail);

    // Save current date for inactivity checks
    await prefs.setString('pause_date', DateTime.now().toString());

    // send status to firebase if app is closed or unfocused
    final firestoreService = FirestoreService();

    await firestoreService.setStatus(
      status: 'Paused',
      timestamp: DateTime.now(),
      title: "App lost focus - saving state",
    );

    // Save current timestamp for when we'll need to show the start time
    if (online) {
      await prefs.setString('start_time', DateTime.now().toString());
    }
  }
}
