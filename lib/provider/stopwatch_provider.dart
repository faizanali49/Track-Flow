import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackerdesktop/services/app_lifecycle_handler.dart';
import 'package:trackerdesktop/provider/states.dart';

/// Represents the state of the stopwatch.
class StopwatchState {
  final Duration elapsed;
  final bool isRunning;

  const StopwatchState({required this.elapsed, required this.isRunning});

  StopwatchState copyWith({Duration? elapsed, bool? isRunning}) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class StopwatchNotifier extends StateNotifier<StopwatchState> {
  final Ref ref;
  late AppLifecycleHandler lifecycleHandler;

  StopwatchNotifier(this.ref)
    : super(const StopwatchState(elapsed: Duration.zero, isRunning: false)) {
    _timer = null;

    // Create and initialize lifecycle handler
    lifecycleHandler = AppLifecycleHandler(
      getCurrentTime: () => state.elapsed,
      isRunning: () => state.isRunning,
      isOnline: () => ref.read(onlinestatus),
      isPaused: () => ref.read(pausedstatus),
    );

    lifecycleHandler.init();
  }

  Timer? _timer;
  DateTime? _lastTick;

  // Starts the stopwatch.
  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _lastTick = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final now = DateTime.now();
      final diff = now.difference(_lastTick!);
      state = state.copyWith(elapsed: state.elapsed + diff);
      _lastTick = now;
    });
  }

  // Pauses the stopwatch.
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  // Resets the stopwatch.
  void reset() {
    _timer?.cancel();
    state = const StopwatchState(elapsed: Duration.zero, isRunning: false);
  }

  // Sets the elapsed time to a specific duration.
  void setTime(Duration duration) {
    state = state.copyWith(elapsed: duration);
  }

  @override
  void dispose() {
    _timer?.cancel();
    lifecycleHandler.dispose();
    super.dispose();
  }
}

final stopwatchProvider =
    StateNotifierProvider<StopwatchNotifier, StopwatchState>(
      (ref) => StopwatchNotifier(ref),
    );
