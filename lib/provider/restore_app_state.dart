import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'stopwatch_provider.dart';

/// Dummy providers for your online/paused/active states
/// (replace with your actual providers)
final onlinestatus = StateProvider<bool>((ref) => false);
final pausedstatus = StateProvider<bool>((ref) => false);
final appActiveProvider = StateProvider<bool>((ref) => false);

/// Restore state after login
Future<void> restoreAppState(
  WidgetRef ref,
  String loggedInEmployeeEmail,
  String loggedInCompanyEmail,
) async {
  final prefs = await SharedPreferences.getInstance();

  // final elapsedMs = prefs.getInt('stopwatch_spend_time') ?? 0;
  final wasOnline = prefs.getBool('was_online') ?? false;
  final wasPaused = prefs.getBool('was_paused') ?? false;

  // Restore Online/Paused states
  ref.read(onlinestatus.notifier).state = wasOnline;
  ref.read(pausedstatus.notifier).state = wasPaused;

  // Mark app as active
  ref.read(appActiveProvider.notifier).state = true;

  print("✅ State restored after login");
}
