import 'fasting_plan.dart';

enum FastingSessionStatus { idle, active, completed }

class FastingSession {
  const FastingSession({
    required this.id,
    required this.planId,
    required this.planNameSnapshot,
    required this.startAt,
    required this.plannedDurationMinutes,
    this.endAt,
    this.actualDurationSeconds,
    required this.status,
  });

  final String id;
  final String planId;
  final String planNameSnapshot;
  final DateTime startAt;
  final DateTime? endAt;
  final int plannedDurationMinutes;
  final int? actualDurationSeconds;
  final FastingSessionStatus status;

  factory FastingSession.start({
    required String id,
    required FastingPlan plan,
    required DateTime startAt,
  }) {
    return FastingSession(
      id: id,
      planId: plan.id,
      planNameSnapshot: plan.name,
      startAt: startAt,
      plannedDurationMinutes: plan.fastingHours * 60,
      status: FastingSessionStatus.active,
    );
  }

  FastingSession completeAt(DateTime endAt) {
    if (status != FastingSessionStatus.active) {
      throw StateError('Only an active session can be completed.');
    }
    if (endAt.isBefore(startAt)) {
      throw ArgumentError('End time cannot be before start time.');
    }

    return FastingSession(
      id: id,
      planId: planId,
      planNameSnapshot: planNameSnapshot,
      startAt: startAt,
      endAt: endAt,
      plannedDurationMinutes: plannedDurationMinutes,
      actualDurationSeconds: endAt.difference(startAt).inSeconds,
      status: FastingSessionStatus.completed,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'planId': planId,
    'planNameSnapshot': planNameSnapshot,
    'startAt': startAt.toIso8601String(),
    'endAt': endAt?.toIso8601String(),
    'plannedDurationMinutes': plannedDurationMinutes,
    'actualDurationSeconds': actualDurationSeconds,
    'status': status.name,
  };

  factory FastingSession.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final planId = json['planId'];
    final planNameSnapshot = json['planNameSnapshot'];
    final startAtValue = json['startAt'];
    final endAtValue = json['endAt'];
    final plannedDurationMinutes = json['plannedDurationMinutes'];
    final actualDurationSeconds = json['actualDurationSeconds'];
    final statusValue = json['status'];

    if (id is! String ||
        id.isEmpty ||
        planId is! String ||
        planId.isEmpty ||
        planNameSnapshot is! String ||
        planNameSnapshot.isEmpty ||
        startAtValue is! String ||
        plannedDurationMinutes is! int ||
        plannedDurationMinutes <= 0 ||
        statusValue is! String) {
      throw const FormatException('Saved fasting session is invalid.');
    }

    final startAt = DateTime.tryParse(startAtValue);
    final endAt = endAtValue == null
        ? null
        : endAtValue is String
        ? DateTime.tryParse(endAtValue)
        : null;
    FastingSessionStatus? status;
    for (final value in FastingSessionStatus.values) {
      if (value.name == statusValue) {
        status = value;
        break;
      }
    }

    if (startAt == null ||
        (endAtValue != null && endAt == null) ||
        status == null ||
        status == FastingSessionStatus.idle) {
      throw const FormatException(
        'Saved fasting session contains invalid data.',
      );
    }

    if (status == FastingSessionStatus.active &&
        (endAt != null || actualDurationSeconds != null)) {
      throw const FormatException('Active session has completion data.');
    }

    if (status == FastingSessionStatus.completed &&
        (endAt == null ||
            actualDurationSeconds is! int ||
            actualDurationSeconds < 0 ||
            endAt.isBefore(startAt) ||
            actualDurationSeconds != endAt.difference(startAt).inSeconds)) {
      throw const FormatException(
        'Completed session has invalid duration data.',
      );
    }

    return FastingSession(
      id: id,
      planId: planId,
      planNameSnapshot: planNameSnapshot,
      startAt: startAt,
      endAt: endAt,
      plannedDurationMinutes: plannedDurationMinutes,
      actualDurationSeconds: actualDurationSeconds as int?,
      status: status,
    );
  }
}
