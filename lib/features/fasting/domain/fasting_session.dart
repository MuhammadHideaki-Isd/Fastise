enum SessionStatus { active, completed }

/// One fasting session. `startAt` is the single source of truth for time:
/// elapsed/remaining/progress are always derived from it (never counted).
class FastingSession {
  const FastingSession({
    required this.id,
    required this.planId,
    required this.planNameSnapshot,
    required this.startAt,
    required this.plannedDurationMinutes,
    this.endAt,
    this.actualDurationSeconds,
    this.status = SessionStatus.active,
  });

  final String id;
  final String planId;
  final String planNameSnapshot;
  final DateTime startAt;
  final DateTime? endAt;
  final int plannedDurationMinutes;
  final int? actualDurationSeconds;
  final SessionStatus status;

  Duration get plannedDuration => Duration(minutes: plannedDurationMinutes);

  DateTime get targetEndAt => startAt.add(plannedDuration);

  /// Time since start (or until `endAt` once completed). Never negative, so a
  /// clock set back cannot produce a negative timer.
  Duration elapsed(DateTime now) {
    final d = (endAt ?? now).difference(startAt);
    return d.isNegative ? Duration.zero : d;
  }

  Duration remaining(DateTime now) {
    final d = plannedDuration - elapsed(now);
    return d.isNegative ? Duration.zero : d;
  }

  /// 0..1; 0 when the planned duration is invalid.
  double progress(DateTime now) {
    if (plannedDurationMinutes <= 0) return 0;
    final p = elapsed(now).inMilliseconds / plannedDuration.inMilliseconds;
    return p.clamp(0.0, 1.0);
  }

  bool reachedTarget(DateTime now) => elapsed(now) >= plannedDuration;

  FastingSession complete(DateTime at) {
    final end = at.isBefore(startAt) ? startAt : at;
    return FastingSession(
      id: id,
      planId: planId,
      planNameSnapshot: planNameSnapshot,
      startAt: startAt,
      endAt: end,
      plannedDurationMinutes: plannedDurationMinutes,
      actualDurationSeconds: end.difference(startAt).inSeconds,
      status: SessionStatus.completed,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'planId': planId,
    'planNameSnapshot': planNameSnapshot,
    'startAt': startAt.toUtc().toIso8601String(),
    'endAt': endAt?.toUtc().toIso8601String(),
    'plannedDurationMinutes': plannedDurationMinutes,
    'actualDurationSeconds': actualDurationSeconds,
    'status': status.name,
  };

  /// Returns null if the data is missing or malformed (never throws).
  static FastingSession? tryFromJson(Object? json) {
    if (json is! Map) return null;
    try {
      final id = json['id'];
      final planId = json['planId'];
      final name = json['planNameSnapshot'];
      final start = DateTime.tryParse('${json['startAt']}');
      final planned = json['plannedDurationMinutes'];
      final status = SessionStatus.values.asNameMap()[json['status']];
      if (id is! String ||
          planId is! String ||
          name is! String ||
          start == null ||
          planned is! int ||
          planned <= 0 ||
          status == null) {
        return null;
      }
      final endRaw = json['endAt'];
      final end = endRaw == null ? null : DateTime.tryParse('$endRaw');
      if (status == SessionStatus.completed && end == null) return null;
      final actual = json['actualDurationSeconds'];
      return FastingSession(
        id: id,
        planId: planId,
        planNameSnapshot: name,
        startAt: start.toLocal(),
        endAt: end?.toLocal(),
        plannedDurationMinutes: planned,
        actualDurationSeconds: actual is int ? actual : null,
        status: status,
      );
    } catch (_) {
      return null;
    }
  }
}
