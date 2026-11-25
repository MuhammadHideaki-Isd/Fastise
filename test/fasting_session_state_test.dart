import 'package:flutter_test/flutter_test.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';
import 'package:fastise/features/fasting/domain/fasting_session_state.dart';

void main() {
  const plan = FastingPlan(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );

  test('starts one active session with a plan snapshot', () {
    final startAt = DateTime(2026, 11, 25, 8);
    final state = FastingSessionState(
      clock: () => startAt,
      idFactory: () => 'session-1',
    );

    expect(state.start(plan), isTrue);
    expect(state.isActive, isTrue);
    expect(state.activeSession?.id, 'session-1');
    expect(state.activeSession?.planId, '16-8');
    expect(state.activeSession?.planNameSnapshot, '16:8');
    expect(state.activeSession?.plannedDurationMinutes, 960);
    expect(state.activeSession?.status, FastingSessionStatus.active);
  });

  test('prevents a second active session', () {
    final state = FastingSessionState(
      clock: () => DateTime(2026, 11, 25, 8),
      idFactory: () => 'session-1',
    );

    expect(state.start(plan), isTrue);
    expect(state.start(plan), isFalse);
  });

  test('completes the active session and records actual duration', () {
    final startAt = DateTime(2026, 11, 25, 8);
    final endAt = startAt.add(const Duration(hours: 10));
    final state = FastingSessionState(
      clock: () => startAt,
      idFactory: () => 'session-1',
    );

    expect(state.start(plan), isTrue);
    expect(state.complete(endAt: endAt), isTrue);
    expect(state.isActive, isFalse);
    expect(state.completedSessions, hasLength(1));
    expect(
      state.completedSessions.first.status,
      FastingSessionStatus.completed,
    );
    expect(state.completedSessions.first.endAt, endAt);
    expect(state.completedSessions.first.actualDurationSeconds, 36000);
  });

  test('cancel removes the active session without adding history', () {
    final state = FastingSessionState(
      clock: () => DateTime(2026, 11, 25, 8),
      idFactory: () => 'session-1',
    );

    state.start(plan);
    state.cancel();

    expect(state.isActive, isFalse);
    expect(state.completedSessions, isEmpty);
  });

  test('rejects completion before start time', () {
    final startAt = DateTime(2026, 11, 25, 8);
    final session = FastingSession.start(
      id: 'session-1',
      plan: plan,
      startAt: startAt,
    );

    expect(
      () => session.completeAt(startAt.subtract(const Duration(minutes: 1))),
      throwsArgumentError,
    );
  });
}
