import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackerdesktop/provider/stopwatch_provider.dart';

// Existing providers
final onlinestatus = StateProvider<bool>((ref) => false);
final pausedstatus = StateProvider<bool>((ref) => false);
// final userNameProvider = StateProvider<String?>((ref) => null);
final onlineTimeProvider = StateProvider<String?>((ref) => null);
final employeeEmailProvider = StateProvider<String?>((ref) => null);

// New function to restore app state
Future<void> restoreAppState(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();

  // Restore online/offline status
  final wasOnline = prefs.getBool('was_online') ?? false;
  ref.read(onlinestatus.notifier).state = wasOnline;

  // Restore paused status
  final wasPaused = prefs.getBool('was_paused') ?? false;
  ref.read(pausedstatus.notifier).state = wasPaused;

  // Restore start time if was online
  if (wasOnline) {
    final startTimeStr = prefs.getString('start_time');
    if (startTimeStr != null) {
      ref.read(onlineTimeProvider.notifier).state = startTimeStr;
    }
  }
}

final stopwatchProvider =
    StateNotifierProvider<StopwatchNotifier, StopwatchState>(
      (ref) => StopwatchNotifier(ref),
    );
