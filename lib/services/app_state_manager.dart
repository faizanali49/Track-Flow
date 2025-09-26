// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trackerdesktop/provider/employee_profile_provider.dart';
// import 'package:trackerdesktop/services/firebase_service.dart';
// import 'package:trackerdesktop/provider/states.dart';
// import 'package:intl/intl.dart';

// class AppStateManager {
//   static const int maxInactiveHours = 16;

//   static Future<void> restoreAppState(WidgetRef ref) async {
//     final prefs = await SharedPreferences.getInstance();
//     final firestoreService = FirestoreService();
//     final userId = ref.watch(employeeEmailProvider); // employee email
//     final companyId = ref.watch(companyEmailProviderID); // company email

//     if (userId == null ||
//         userId.isEmpty ||
//         companyId == null ||
//         companyId.isEmpty) {
//       return;
//     }

//     // Retrieve stored user info
//     final savedEmployeeEmail = prefs.getString('employee_email');
//     final savedCompanyEmail = prefs.getString('company_email');

//     // ✅ Check if stored emails match the current logged-in user
//     if (savedEmployeeEmail != userId || savedCompanyEmail != companyId) {
//       // Different user → clear old data to avoid mixing states
//       await prefs.clear();
//       ref.read(onlinestatus.notifier).state = false;
//       ref.read(pausedstatus.notifier).state = false;
//       ref.read(onlineTimeProvider.notifier).state = null;
//       ref.read(stopwatchProvider.notifier).reset();
//       return;
//     }

//     // Check if too much time has elapsed (auto offline)
//     final autoOffline = await shouldAutoSetOffline();

//     if (autoOffline) {
//       await firestoreService.setStatus(
//         status: 'Offline',
//         offlineTime: DateTime.now().second,
//         title: "Automatic offline after 16+ hours of inactivity",
//       );

//       // Reset states
//       ref.read(onlinestatus.notifier).state = false;
//       ref.read(pausedstatus.notifier).state = false;
//       ref.read(onlineTimeProvider.notifier).state = null;
//       ref.read(stopwatchProvider.notifier).reset();

//       await prefs.remove('pause_date');
//       await prefs.remove('start_time');
//       await prefs.remove('elapsed_time');
//       await prefs.remove('is_online');
//       await prefs.remove('is_paused');
//     } else {
//       // Restore from saved state
//       final wasOnline = prefs.getBool('is_online') ?? false;
//       final wasPaused = prefs.getBool('is_paused') ?? false;
//       final seconds = prefs.getInt('elapsed_time') ?? 0;
//       final onlineStartTime = prefs.getString('start_time');

//       if (onlineStartTime != null) {
//         ref.read(onlineTimeProvider.notifier).state = DateFormat(
//           'h:mm:ss a',
//         ).format(DateTime.parse(onlineStartTime));
//       }

//       ref.read(onlinestatus.notifier).state = wasOnline;
//       ref.read(pausedstatus.notifier).state = wasPaused;

//       final stopwatchNotifier = ref.read(stopwatchProvider.notifier);
//       if (seconds > 0) {
//         final elapsed = Duration(seconds: seconds);
//         stopwatchNotifier.setTime(elapsed);

//         if (wasOnline && !wasPaused) {
//           stopwatchNotifier.start();
//         }
//       }

//       if (wasOnline && wasPaused) {
//         ref.read(pausedstatus.notifier).state = true;
//       }
//     }
//   }

//   // Check if user should be automatically set to offline
//   static Future<bool> shouldAutoSetOffline() async {
//     final prefs = await SharedPreferences.getInstance();
//     final pauseDateStr = prefs.getString('pause_date');

//     // If no pause date saved, check the last activity time
//     if (pauseDateStr == null) {
//       final lastActiveStr = prefs.getString('start_time');
//       if (lastActiveStr == null) {
//         return false;
//       }

//       final lastActive = DateTime.parse(lastActiveStr);
//       final now = DateTime.now();
//       final difference = now.difference(lastActive);

//       return difference.inHours > maxInactiveHours;
//     }

//     final pauseDate = DateTime.parse(pauseDateStr);
//     final now = DateTime.now();
//     final difference = now.difference(pauseDate);

//     return difference.inHours > maxInactiveHours;
//   }
// }
