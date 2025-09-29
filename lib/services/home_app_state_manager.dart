import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/employee_profile_provider.dart';
import 'package:trackerdesktop/provider/states.dart';
import 'package:trackerdesktop/views/login_authentication/services/login_auth.dart';
import 'package:trackerdesktop/views/widgets/offline_dialog_box.dart';
import 'package:window_manager/window_manager.dart';

final logger = Logger();
final _firestore = FirebaseFirestore.instance;

// Define a type alias for the Ref used in non-widget logic for clarity.
typedef ServiceRef = ProviderRef;

// --- 1. App Lifecycle Service (Handles OS-level interactions and Persistence) ---

/// Provider for the AppLifecycleService.
final appLifecycleServiceProvider = Provider((ref) {
  return AppLifecycleService(ref);
});

class AppLifecycleService with WindowListener {
  // Use the type alias for the Ref to ensure strong typing alignment.
  final ServiceRef _ref;

  AppLifecycleService(this._ref) {
    windowManager.addListener(this);
  }

  /// Needs to be called once, typically from the HomeScreen's initState.
  void init() {
    // Listener added in constructor.
  }

  void dispose() {
    windowManager.removeListener(this);
  }

  @override
  void onWindowFocus() {
    _ref.read(appActiveProvider.notifier).state = true;
    logger.d("✅ App is active (focused)");
  }

  @override
  void onWindowBlur() {
    _ref.read(appActiveProvider.notifier).state = false;
    logger.d("⚠️ App is inactive (unfocused)");
  }

  @override
  void onWindowClose() async {
    final stopwatchState = _ref.read(stopwatchProvider);
    final stopwatchNotifier = _ref.read(stopwatchProvider.notifier);
    final isOnline = _ref.read(onlinestatus);
    final employeemail = _ref.read(employeeEmailProvider);
    final companyEmail = _ref.read(companyEmailProvider);

    try {
      if (isOnline && stopwatchState.isRunning) {
        stopwatchNotifier.pause();
        // Give time for the pause to register before saving state
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final prefs = await SharedPreferences.getInstance();

      if (employeemail != null && companyEmail != null) {
        // --- Shared Preferences Persistence ---
        await prefs.setString('s_employee_email', employeemail);
        await prefs.setString('s_company_email', companyEmail);
        await prefs.setInt(
          'elapsed_time',
          stopwatchState.elapsed.inMilliseconds,
        );
        await prefs.setBool('was_online', isOnline);
        await prefs.setBool('was_paused', !stopwatchState.isRunning);
        await prefs.setBool('was_running', stopwatchState.isRunning);

        // Save the persistent online start time
        await prefs.setString(
          'start_time',
          _ref.read(onlineTimeProvider) ?? DateTime.now().toIso8601String(),
        );

        await prefs.setString('last_closed', DateTime.now().toIso8601String());

        // --- Firestore Activity Logging ---
        await _firestore
            .collection('companies')
            .doc(companyEmail)
            .collection('employees')
            .doc(employeemail)
            .collection('activities')
            .add({
              'status': 'paused',
              'timestamp': DateTime.now(),
              'title': 'Auto-paused on exit',
              'automatic': true,
            });

        _ref.read(appActiveProvider.notifier).state = false;
        logger.i("✅ App state saved on close (SharedPreferences & Firestore)");
      } else {
        logger.w("⚠️ Missing email info, state not saved");
      }
    } catch (e) {
      logger.e("❌ Error saving state on close: $e");
    }

    // Always attempt to close the window if allowed by windowManager
    bool preventClose = await windowManager.isPreventClose();
    if (preventClose) {
      await windowManager.destroy();
    }
  }
}

// --- 2. Home Controller (Handles UI interactions and initial setup/restoration) ---

/// Provider for the HomeController.
final homeControllerProvider = Provider((ref) {
  return HomeController(ref);
});

class HomeController {
  final Ref _ref;

  HomeController(this._ref);

  /// Utility to format Duration to H:MM:SS string.
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// Restores the previous session state from SharedPreferences.
  Future<void> restoreAppState() async {
    final prefs = await SharedPreferences.getInstance();

    final wasRunning = prefs.getBool('was_running') ?? false;
    final elapsedTimeMillis = prefs.getInt('elapsed_time') ?? 0;
    final storedStartTime = prefs.getString('start_time');
    final wasOnline = prefs.getBool('was_online') ?? false;

    // 1. Restore the persistent start time
    if (storedStartTime != null) {
      _ref.read(onlineTimeProvider.notifier).state = storedStartTime;
    }

    // 2. Restore the elapsed time
    if (elapsedTimeMillis > 0) {
      // Assuming stopwatchProvider.notifier has a setElapsed method
      // If not, this line will cause an error and needs to be implemented in states.dart
      _ref
          .read(stopwatchProvider.notifier)
          .setElapsed(Duration(milliseconds: elapsedTimeMillis));
    }

    // 3. Restore online status
    _ref.read(onlinestatus.notifier).state = wasOnline;

    // 4. Auto-start logic (if it was online and running)
    if (wasOnline && wasRunning) {
      _ref.read(stopwatchProvider.notifier).start();
      _ref.read(pausedstatus.notifier).state = false;

      // --- NEW: Log Resume Activity to Firestore ---
      // Read the saved emails from SharedPreferences to use for the Firestore path
      final employeemail = prefs.getString('s_employee_email');
      final companyEmail = prefs.getString('s_company_email');

      if (employeemail != null && companyEmail != null) {
        await _firestore
            .collection('companies')
            .doc(companyEmail)
            .collection('employees')
            .doc(employeemail)
            .collection('activities')
            .add({
              'status': 'resumed', // Logged as resumed
              'timestamp': DateTime.now(),
              'title': 'Auto-resumed on App Load',
              'automatic': true,
            });
      }
      // ---------------------------------------------

      logger.i("App state restored and stopwatch auto-started.");
    } else {
      // If it was paused or offline, restore the correct pause status
      final wasPaused = prefs.getBool('was_paused') ?? false;
      _ref.read(pausedstatus.notifier).state = wasPaused;
      logger.i("App state restored (paused/offline).");
    }
  }

  /// Checks authentication status, loads state, and navigates if needed.
  void runInitialSetup(BuildContext context) async {
    // 1. Restore previous application state
    await restoreAppState();

    // 2. Auth check and navigation
    WindowsAuthService().isAuthenticated().then((isAuthenticated) {
      if (!isAuthenticated && context.mounted) {
        // Use addPostFrameCallback to ensure navigation runs after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
      }
    });

    // 3. Email update
    WindowsAuthService().getUserEmail().then((email) {
      if (email != null && _ref.read(employeeEmailProvider) != email) {
        _ref.read(employeeEmailProvider.notifier).state = email;
      }
    });
  }

  /// Handles the 'Online' button click.
  void goOnline() {
    final onlineTimeNotifier = _ref.read(onlineTimeProvider.notifier);
    final stopwatchState = _ref.read(stopwatchProvider);

    // Set the initial online time ONLY if it's a completely fresh start (elapsed time is zero).
    // This ensures the original start time is preserved across app restarts.
    if (stopwatchState.elapsed == Duration.zero) {
      onlineTimeNotifier.state = DateTime.now().toIso8601String();
    }

    _ref.read(onlinestatus.notifier).state = true;
    _ref.read(stopwatchProvider.notifier).start();
    _ref.read(pausedstatus.notifier).state = false; // Ensure pause is reset
  }

  /// Handles the 'Pause' / 'Resume' button click.
  void togglePause(Duration elapsed) {
    final stopwatchNotifier = _ref.read(stopwatchProvider.notifier);
    final isRunning = _ref.read(stopwatchProvider).isRunning;

    if (isRunning) {
      _ref.read(pausedstatus.notifier).state = true;
      stopwatchNotifier.pause();
    } else if (elapsed > Duration.zero) {
      _ref.read(pausedstatus.notifier).state = false;
      stopwatchNotifier.start();
    }
  }

  /// Handles the 'Offline' button click, showing the confirmation dialog.
  void goOffline(BuildContext context, String formattedTime, Duration elapsed) {
    final stopwatchState = _ref.read(stopwatchProvider);
    final stopwatchNotifier = _ref.read(stopwatchProvider.notifier);
    final isOnline = _ref.read(onlinestatus);

    offlineAlert(
      context,
      _ref,
      formattedTime,
      isOnline,
      stopwatchState,
      stopwatchNotifier,
      elapsed,
    );
  }

  /// Handles user initiated sign out and navigation.
  Future<void> signOut(BuildContext context) async {
    await WindowsAuthService().signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }
}
