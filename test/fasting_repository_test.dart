import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/data/fasting_repository.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';

Future<FastingController> _open(DateTime Function() clock) async {
  final prefs = await SharedPreferences.getInstance();
  return FastingController(clock: clock, repository: FastingRepository(prefs));
}

void main() {
  late DateTime clock;
  DateTime now() => clock;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = DateTime(2026, 1, 1, 8);
  });

  test('fresh install gives defaults', () async {
    final c = await _open(now);
    expect(c.selectedPlan.id, '16-8');
    expect(c.isFasting, isFalse);
    expect(c.sessions, isEmpty);
  });

  test('selected plan survives a restart', () async {
    final c = await _open(now);
    c.selectPlan(FastingPlan.byId('18-6')!);
    await pumpEventQueue();

    final reopened = await _open(now);
    expect(reopened.selectedPlan.id, '18-6');
  });

  test('active session is restored with the original startAt', () async {
    final c = await _open(now);
    c.startFasting();
    await pumpEventQueue();

    // "App closed" for 5 hours, then reopened.
    clock = clock.add(const Duration(hours: 5));
    final reopened = await _open(now);

    final s = reopened.activeSession!;
    expect(s.startAt.isAtSameMomentAs(DateTime(2026, 1, 1, 8)), isTrue);
    expect(s.elapsed(clock), const Duration(hours: 5));
    expect(reopened.isFasting, isTrue);
    expect(reopened.startFasting(), isNull, reason: 'no second active session');
  });

  test('target passed while closed: still active, not auto-ended', () async {
    final c = await _open(now);
    c.startFasting();
    await pumpEventQueue();

    clock = clock.add(const Duration(hours: 30));
    final reopened = await _open(now);
    expect(reopened.isFasting, isTrue);
    expect(reopened.activeSession!.reachedTarget(clock), isTrue);
  });

  test('completed sessions persist and the active slot is cleared', () async {
    final c = await _open(now);
    c.startFasting();
    clock = clock.add(const Duration(hours: 2));
    final done = c.endFasting()!;
    await pumpEventQueue();

    final reopened = await _open(now);
    expect(reopened.isFasting, isFalse);
    expect(reopened.sessions.single.id, done.id);
    expect(reopened.sessions.single.actualDurationSeconds, 7200);
  });

  test('cancelled session is not restored', () async {
    final c = await _open(now);
    c.startFasting();
    c.cancelFasting();
    await pumpEventQueue();

    final reopened = await _open(now);
    expect(reopened.isFasting, isFalse);
    expect(reopened.sessions, isEmpty);
  });

  test('malformed stored data falls back safely', () async {
    SharedPreferences.setMockInitialValues({
      'selected_plan_id': 'nonsense',
      'active_session': '{not json',
      'completed_sessions': 'also not json',
    });
    final c = await _open(now);
    expect(c.selectedPlan.id, '16-8');
    expect(c.isFasting, isFalse);
    expect(c.sessions, isEmpty);
  });

  test('wrong value types do not crash', () async {
    SharedPreferences.setMockInitialValues({
      'selected_plan_id': 42,
      'active_session': 7,
      'completed_sessions': true,
    });
    final c = await _open(now);
    expect(c.selectedPlan.id, '16-8');
    expect(c.sessions, isEmpty);
  });

  test('bad entries are dropped, good ones kept (newest first)', () async {
    final older = FastingSession(
      id: 'a',
      planId: '16-8',
      planNameSnapshot: '16:8',
      startAt: DateTime(2026, 1, 1, 8),
      plannedDurationMinutes: 960,
    ).complete(DateTime(2026, 1, 1, 12));
    final newer = FastingSession(
      id: 'b',
      planId: '16-8',
      planNameSnapshot: '16:8',
      startAt: DateTime(2026, 1, 3, 8),
      plannedDurationMinutes: 960,
    ).complete(DateTime(2026, 1, 3, 20));
    final prefs = await SharedPreferences.getInstance();
    await FastingRepository(prefs).saveCompleted([older, newer]);
    final raw = prefs.getString('completed_sessions')!;
    await prefs.setString(
      'completed_sessions',
      raw.replaceFirst('[', '[{"id":1},"junk",'),
    );

    final c = await _open(now);
    expect(c.sessions.map((s) => s.id), ['b', 'a']);
  });

  test('an active-status entry in the completed list is ignored', () async {
    final active = FastingSession(
      id: 'x',
      planId: '16-8',
      planNameSnapshot: '16:8',
      startAt: DateTime(2026, 1, 1, 8),
      plannedDurationMinutes: 960,
    );
    final prefs = await SharedPreferences.getInstance();
    await FastingRepository(prefs).saveCompleted([active]);
    final c = await _open(now);
    expect(c.sessions, isEmpty);
  });
}
