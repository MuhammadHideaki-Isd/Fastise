import 'package:flutter_test/flutter_test.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';
import 'package:fastise/features/fasting/domain/fasting_timer.dart';

void main() {
  const plan = FastingPlan(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );

  test('calculates elapsed and remaining from startAt', () {
    final startAt = DateTime(2026, 11, 25, 8);
    final session = FastingSession.start(
      id: 'session-1',
      plan: plan,
      startAt: startAt,
    );

    final snapshot = FastingTimer.calculate(
      session,
      startAt.add(const Duration(hours: 4, minutes: 30)),
    );

    expect(snapshot.elapsed, const Duration(hours: 4, minutes: 30));
    expect(snapshot.remaining, const Duration(hours: 11, minutes: 30));
    expect(snapshot.progress, closeTo(0.28125, 0.00001));
    expect(snapshot.targetReached, isFalse);
  });

  test('clamps progress and shows target reached after planned duration', () {
    final startAt = DateTime(2026, 11, 25, 8);
    final session = FastingSession.start(
      id: 'session-1',
      plan: plan,
      startAt: startAt,
    );

    final snapshot = FastingTimer.calculate(
      session,
      startAt.add(const Duration(hours: 20)),
    );

    expect(snapshot.remaining, Duration.zero);
    expect(snapshot.progress, 1);
    expect(snapshot.targetReached, isTrue);
  });

  test('handles a future timestamp safely', () {
    final startAt = DateTime(2026, 11, 25, 8);
    final session = FastingSession.start(
      id: 'session-1',
      plan: plan,
      startAt: startAt,
    );

    final snapshot = FastingTimer.calculate(
      session,
      startAt.subtract(const Duration(minutes: 5)),
    );

    expect(snapshot.elapsed, Duration.zero);
    expect(snapshot.remaining, const Duration(hours: 16));
    expect(snapshot.progress, 0);
  });

  test('formats timer as hours, minutes, and seconds', () {
    expect(
      FastingTimerSnapshot.formatDuration(
        const Duration(hours: 4, minutes: 5, seconds: 9),
      ),
      '04:05:09',
    );
  });
}
