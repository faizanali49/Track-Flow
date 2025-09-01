enum WorkStatus { offline, online, paused }

extension WorkStatusX on WorkStatus {
  String get name => toString().split('.').last;
  static WorkStatus fromName(String v) =>
      WorkStatus.values.firstWhere((e) => e.name == v);
}
