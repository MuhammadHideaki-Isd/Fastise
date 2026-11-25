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
}
