// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trackerdesktop/services/firebase_service.dart';
// import 'package:window_manager/window_manager.dart';

// /// Handles lifecycle + window focus changes
// /// Saves state into SharedPreferences so it can be restored later.
// class AppLifecycleHandler with WidgetsBindingObserver, WindowListener {
//   final Duration Function() getCurrentTime;
//   final bool Function() isRunning;
//   final bool Function() isOnline;
//   final bool Function() isPaused;
//   final String? companyEmail;

//   AppLifecycleHandler({
//     required this.getCurrentTime,
//     required this.isRunning,
//     required this.isOnline,
//     required this.isPaused,
//     required this.companyEmail,
//   });

//   void init() {
//     WidgetsBinding.instance.addObserver(this);
//     windowManager.addListener(this);
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     windowManager.removeListener(this);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.detached ||
//         state == AppLifecycleState.inactive) {
//       _saveCurrentState();
//     }
//   }

//   @override
//   void onWindowBlur() {
//     _saveCurrentState();
//   }

//   /// Save current state into SharedPreferences + update Firestore
//   Future<void> _saveCurrentState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final employeeEmail = FirebaseAuth.instance.currentUser?.email;
//     if (employeeEmail == null || employeeEmail.isEmpty) return;

//     final elapsed = getCurrentTime();
//     final running = isRunning();
//     final online = isOnline();
//     final paused = isPaused();

//     // ✅ Save exact same keys used in restoreAppState
//     await prefs.setInt('elapsed_time', elapsed.inSeconds);
//     await prefs.setBool('is_online', online);
//     await prefs.setBool('is_paused', paused);
//     await prefs.setString('employee_email', employeeEmail);
//     await prefs.setString('company_email', companyEmail ?? '');

//     // Save reference times
//     if (online && !paused) {
//       await prefs.setString('start_time', DateTime.now().toIso8601String());
//     }
//     if (paused) {
//       await prefs.setString('pause_date', DateTime.now().toIso8601String());
//     }

//     // 🔗 Update Firestore with actual status
//     final firestoreService = FirestoreService();
//     if (online && paused) {
//       await firestoreService.setStatus(
//         status: 'Paused',
//         timestamp: DateTime.now(),
//         title: "App lost focus - saving state",
//       );
//     } else if (online && !paused) {
//       await firestoreService.setStatus(
//         status: 'Online',
//         timestamp: DateTime.now(),
//         title: "App still online - saving state",
//       );
//     } else {
//       await firestoreService.setStatus(
//         status: 'Offline',
//         timestamp: DateTime.now(),
//         title: "App lost focus - user offline",
//       );
//     }
//   }
// }
