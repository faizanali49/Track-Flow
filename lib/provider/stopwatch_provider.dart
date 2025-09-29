// lib/provider/stopwatch_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State class to hold stopwatch data
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

/// Riverpod StateNotifier to control stopwatch
class StopwatchNotifier extends StateNotifier<StopwatchState> {
  Timer? _timer;

  StopwatchNotifier()
    : super(const StopwatchState(elapsed: Duration.zero, isRunning: false)) {
    _loadInitialTime(); // Restore on init
  }
  void setElapsed(Duration elapsed) {
    state = state.copyWith(elapsed: elapsed);
  }

  // Start stopwatch
  void start() {
    if (state.isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newElapsed = state.elapsed + const Duration(seconds: 1);
      state = state.copyWith(elapsed: newElapsed, isRunning: true);
      _saveState();
    });
    state = state.copyWith(isRunning: true);
    _saveState();
  }

  // Pause stopwatch
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _saveState();
  }

  // Reset stopwatch
  void reset() {
    _timer?.cancel();
    state = const StopwatchState(elapsed: Duration.zero, isRunning: false);
    _saveState();
  }

  // Manually set elapsed time (when restoring)
  void setTime(Duration elapsed) {
    state = state.copyWith(elapsed: elapsed);
    _saveState();
  }

  // Save state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsed_time', state.elapsed.inMilliseconds);
    await prefs.setBool('was_running', state.isRunning);
  }

  // Load state from SharedPreferences
  Future<void> _loadInitialTime() async {
    final prefs = await SharedPreferences.getInstance();
    final elapsedMs = prefs.getInt('elapsed_time') ?? 0;
    final wasRunning = prefs.getBool('was_running') ?? false;

    final restoredElapsed = Duration(milliseconds: elapsedMs);

    state = StopwatchState(elapsed: restoredElapsed, isRunning: wasRunning);

    // Auto-resume timer if it was running
    if (wasRunning) {
      start();
    }
  }
}

// final stopwatchProvider =
//     StateNotifierProvider<StopwatchNotifier, StopwatchState>((ref) {
//       return StopwatchNotifier();
//     });
