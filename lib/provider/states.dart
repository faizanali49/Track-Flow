import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackerdesktop/provider/stopwatch_provider.dart';

// Existing providers
final onlinestatus = StateProvider<bool>((ref) => false);
final pausedstatus = StateProvider<bool>((ref) => false);
// final userNameProvider = StateProvider<String?>((ref) => null);
final onlineTimeProvider = StateProvider<String?>((ref) => null);
final employeeEmailProvider = StateProvider<String?>((ref) => null);
final companyEmailProvider = StateProvider<String?>((ref) => null);
final restoreStateProvider = StateProvider<bool>((ref) => false);

final appActiveProvider = StateProvider<bool>((ref) => true);

final stopwatchProvider =
    StateNotifierProvider<StopwatchNotifier, StopwatchState>(
      (ref) => StopwatchNotifier(),
    
    );


