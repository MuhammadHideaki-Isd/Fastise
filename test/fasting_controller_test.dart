import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';

void main() {
  late DateTime clock;
  late FastingController c;

  setUp(() {
    clock = DateTime(2026, 1, 1, 8);
    c = FastingController(clock: () => clock);
  });

  test('starts idle with the default plan', () {
    expect(c.isFasting, isFalse);
    expect(c.selectedPlan.id, '16-8');
    expect(c.sessions, isEmpty);
  });

  test('start creates one active session with a plan snapshot', () {
    final s = c.startFasting()!;
    expect(c.isFasting, isTrue);
    expect(s.status, SessionStatus.active);
    expect(s.startAt, clock);
    expect(s.plannedDurationMinutes, 16 * 60);
    expect(s.planNameSnapshot, '16:8');
  });

  test('cannot start two sessions', () {
    final first = c.startFasting();
    clock = clock.add(const Duration(minutes: 5));
    expect(c.startFasting(), isNull);
    expect(c.activeSession!.id, first!.id);
    expect(c.activeSession!.startAt, DateTime(2026, 1, 1, 8));
  });

  test('changing plan does not alter the running session', () {
    c.startFasting();
    c.selectPlan(FastingPlan.byId('20-4')!);
    expect(c.activeSession!.plannedDurationMinutes, 16 * 60);
    expect(c.activeSession!.planNameSnapshot, '16:8');
    clock = clock.add(const Duration(hours: 1));
    c.endFasting();
    c.startFasting();
    expect(c.activeSession!.plannedDurationMinutes, 20 * 60);
  });

  test('end completes the session and stores it in history', () {
    c.startFasting();
    clock = clock.add(const Duration(hours: 3, minutes: 30));
    final done = c.endFasting()!;
    expect(done.status, SessionStatus.completed);
    expect(done.endAt, clock);
    expect(done.actualDurationSeconds, 3 * 3600 + 30 * 60);
    expect(c.isFasting, isFalse);
    expect(c.sessions, [done]);
    expect(c.endFasting(), isNull);
  });

  test('history is newest first and survives a new start', () {
    c.startFasting();
    clock = clock.add(const Duration(hours: 1));
    final a = c.endFasting()!;
    clock = clock.add(const Duration(hours: 1));
    c.startFasting();
    clock = clock.add(const Duration(hours: 2));
    final b = c.endFasting()!;
    expect(c.sessions, [b, a]);
  });

  test('cancel discards the session without history', () {
    c.startFasting();
    c.cancelFasting();
    expect(c.isFasting, isFalse);
    expect(c.sessions, isEmpty);
  });

  group('FastingSession timing', () {
    test('elapsed, remaining and progress come from startAt', () {
      c.startFasting();
      final s = c.activeSession!;
      final t = clock.add(const Duration(hours: 4));
      expect(s.elapsed(t), const Duration(hours: 4));
      expect(s.remaining(t), const Duration(hours: 12));
      expect(s.progress(t), closeTo(0.25, 1e-9));
      expect(s.reachedTarget(t), isFalse);
    });

    test('target reached clamps progress and does not end the session', () {
      c.startFasting();
      clock = clock.add(const Duration(hours: 20));
      final s = c.activeSession!;
      expect(s.reachedTarget(clock), isTrue);
      expect(s.progress(clock), 1.0);
      expect(s.remaining(clock), Duration.zero);
      expect(c.isFasting, isTrue);
    });

    test('a clock set back never gives a negative elapsed', () {
      c.startFasting();
      final s = c.activeSession!;
      expect(
        s.elapsed(clock.subtract(const Duration(hours: 1))),
        Duration.zero,
      );
    });
  });

  group('FastingSession json', () {
    test('round-trips', () {
      c.startFasting();
      clock = clock.add(const Duration(hours: 2));
      final done = c.endFasting()!;
      final back = FastingSession.tryFromJson(done.toJson())!;
      expect(back.id, done.id);
      expect(back.startAt.isAtSameMomentAs(done.startAt), isTrue);
      expect(back.endAt!.isAtSameMomentAs(done.endAt!), isTrue);
      expect(back.actualDurationSeconds, 7200);
      expect(back.status, SessionStatus.completed);
    });

    test('malformed data returns null instead of throwing', () {
      expect(FastingSession.tryFromJson(null), isNull);
      expect(FastingSession.tryFromJson('x'), isNull);
      expect(FastingSession.tryFromJson({'id': 1}), isNull);
      expect(
        FastingSession.tryFromJson({
          'id': 'a',
          'planId': 'p',
          'planNameSnapshot': 'n',
          'startAt': 'not a date',
          'plannedDurationMinutes': 60,
          'status': 'active',
        }),
        isNull,
      );
      expect(
        FastingSession.tryFromJson({
          'id': 'a',
          'planId': 'p',
          'planNameSnapshot': 'n',
          'startAt': '2026-01-01T00:00:00Z',
          'plannedDurationMinutes': 60,
          'status': 'completed',
        }),
        isNull,
        reason: 'completed session without endAt is invalid',
      );
    });
  });
}
