

// import 'package:trackerdesktop/models/workstatus.dart';

// class WorkSession {
//   final DateTime startTime;             // When user went Online (or last Resume)
//   final int elapsedSeconds;             // Sum of active time so far
//   final WorkStatus status;              // online / paused / offline
//   final DateTime? lastPausedAt;         // when user pressed Pause (null if not paused)
//   final String? title;                  // captured at Offline
//   final String? description;            // captured at Offline
//   final List<Map<String, dynamic>> events; // local log: [{type,time}]

//   const WorkSession({
//     required this.startTime,
//     required this.elapsedSeconds,
//     required this.status,
//     this.lastPausedAt,
//     this.title,
//     this.description,
//     this.events = const [],
//   });

//   Duration get elapsed => Duration(seconds: elapsedSeconds);

//   WorkSession copyWith({
//     DateTime? startTime,
//     int? elapsedSeconds,
//     WorkStatus? status,
//     DateTime? lastPausedAt,
//     String? title,
//     String? description,
//     List<Map<String, dynamic>>? events,
//   }) {
//     return WorkSession(
//       startTime: startTime ?? this.startTime,
//       elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
//       status: status ?? this.status,
//       lastPausedAt: lastPausedAt,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       events: events ?? this.events,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'startTime': startTime.toIso8601String(),
//     'elapsedSeconds': elapsedSeconds,
//     'status': status.name,
//     'lastPausedAt': lastPausedAt?.toIso8601String(),
//     'title': title,
//     'description': description,
//     'events': events,
//   };

//   static WorkSession fromJson(Map<String, dynamic> j) => WorkSession(
//     startTime: DateTime.parse(j['startTime'] as String),
//     elapsedSeconds: (j['elapsedSeconds'] as num).toInt(),
//     status: WorkStatusX.fromName(j['status'] as String),
//     lastPausedAt: j['lastPausedAt'] == null ? null : DateTime.parse(j['lastPausedAt']),
//     title: j['title'] as String?,
//     description: j['description'] as String?,
//     events: (j['events'] as List<dynamic>? ?? const [])
//         .cast<Map<String, dynamic>>(),
//   );
// }
