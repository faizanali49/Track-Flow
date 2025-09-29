// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logger/logger.dart';

// final logger = Logger();

// // --- 1. Stopwatch State Model ---

// class StopwatchState {
//   final Duration elapsed;
//   final bool isRunning;

//   StopwatchState({required this.elapsed, required this.isRunning});

//   StopwatchState copyWith({
//     Duration? elapsed,
//     bool? isRunning,
//   }) {
//     return StopwatchState(
//       elapsed: elapsed ?? this.elapsed,
//       isRunning: isRunning ?? this.isRunning,
//     );
//   }
// }

// // --- 2. Stopwatch Notifier (with setElapsed for restoration) ---

// class StopwatchNotifier extends StateNotifier<StopwatchState> {
//   Timer? _timer;
  
//   // Stores the time when the stopwatch was started or resumed
//   DateTime? _lastStartTime;

//   StopwatchNotifier() : super(StopwatchState(elapsed: Duration.zero, isRunning: false));

//   /// Sets the elapsed time manually, typically used for restoring state
//   /// from persistence without automatically starting the timer.
//   void setElapsed(Duration duration) {
//     if (state.isRunning) {
//       pause(); // Ensure we pause before setting a new value if it was running
//     }
//     // Update the state with the restored duration and ensure it is not running
//     state = state.copyWith(elapsed: duration, isRunning: false);
//     logger.d('Stopwatch time set to: ${duration.inSeconds}s');
//   }

//   /// Starts the stopwatch from the current elapsed time.
//   void start() {
//     if (state.isRunning) return;

//     _lastStartTime = DateTime.now();
//     state = state.copyWith(isRunning: true);

//     _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (state.isRunning) {
//         final now = DateTime.now();
//         // Calculate the actual elapsed duration since the last start
//         final durationSinceStart = now.difference(_lastStartTime!);
        
//         // Update the state's elapsed time by adding the duration since the last tick
//         state = state.copyWith(
//           elapsed: state.elapsed + durationSinceStart,
//         );
//         _lastStartTime = now; // Update the last start time for the next tick
//       } else {
//         _timer?.cancel();
//       }
//     });
//     logger.i('Stopwatch started.');
//   }

//   /// Pauses the stopwatch and updates the total elapsed time.
//   void pause() {
//     if (!state.isRunning) return;

//     if (_lastStartTime != null) {
//       // Calculate final duration segment and add it to total elapsed time
//       final durationSegment = DateTime.now().difference(_lastStartTime!);
//       state = state.copyWith(
//         elapsed: state.elapsed + durationSegment,
//         isRunning: false,
//       );
//     }
//     _timer?.cancel();
//     _lastStartTime = null;
//     logger.i('Stopwatch paused. Total elapsed: ${state.elapsed}');
//   }

//   /// Resets the stopwatch to zero.
//   void reset() {
//     _timer?.cancel();
//     _lastStartTime = null;
//     state = StopwatchState(elapsed: Duration.zero, isRunning: false);
//     logger.i('Stopwatch reset.');
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }

// // --- 3. Providers ---

// /// Provider for the main stopwatch logic.
// final stopwatchProvider = StateNotifierProvider<StopwatchNotifier, StopwatchState>((ref) {
//   return StopwatchNotifier();
// });

// /// Tracks the persistent start time of the entire work session (ISO 8601 string).
// final onlineTimeProvider = StateProvider<String?>((ref) => null);

// /// Tracks if the user has globally set their status to 'Online'/'Offline'.
// final onlinestatus = StateProvider<bool>((ref) => false);

// /// Tracks if the timer is currently in a paused state (true if paused, false if running/stopped).
// final pausedstatus = StateProvider<bool>((ref) => false);

// /// Tracks if the application window is currently focused (active).
// final appActiveProvider = StateProvider<bool>((ref) => true);

// /// Placeholder for the employee's email.
// final employeeEmailProvider = StateProvider<String?>((ref) => null);

// /// Placeholder for the company's email (used as Document ID for company).
// final companyEmailProvider = StateProvider<String?>((ref) => null);
