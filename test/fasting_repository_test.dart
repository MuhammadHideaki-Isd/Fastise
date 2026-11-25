import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fastise/features/fasting/data/fasting_repository.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';

import 'support/memory_string_store.dart';

void main() {
  const plan = FastingPlan(
    id: '18-6',
    name: '18:6',
    fastingHours: 18,
    eatingHours: 6,
  );
  final startAt = DateTime(2026, 11, 25, 8);

  test('returns default plan and no sessions when storage is empty', () async {
    final repository = FastingRepository(store: MemoryStringStore());

    final data = await repository.load();

    expect(data.selectedPlan.id, '16-8');
    expect(data.sessions, isEmpty);
    expect(data.glassEffectEnabled, isTrue);
  });

  test(
    'round trips selected plan, active session, and completed history',
    () async {
      final store = MemoryStringStore();
      final repository = FastingRepository(store: store);
      final active = FastingSession.start(
        id: 'active-session',
        plan: plan,
        startAt: startAt,
      );
      final completedStartAt = startAt.subtract(const Duration(days: 1));
      final completed = FastingSession.start(
        id: 'completed-session',
        plan: plan,
        startAt: completedStartAt,
      ).completeAt(completedStartAt.add(const Duration(hours: 6)));
      final expected = FastingAppData(
        selectedPlan: plan,
        sessions: [active, completed],
      );

      await repository.save(expected);
      final restored = await repository.load();

      expect(restored.selectedPlan.id, plan.id);
      expect(restored.selectedPlan.fastingHours, plan.fastingHours);
      expect(restored.activeSession?.id, active.id);
      expect(restored.completedSessions.single.endAt, completed.endAt);
      expect(
        restored.completedSessions.single.actualDurationSeconds,
        completed.actualDurationSeconds,
      );
    },
  );

  test('rejects malformed saved data instead of silently resetting', () async {
    final store = MemoryStringStore()
      ..values['fastise.app_data.v1'] = '{bad json';
    final repository = FastingRepository(store: store);

    await expectLater(repository.load(), throwsFormatException);
  });

  test('restores the glass setting and defaults it for older saved data', () {
    final data = const FastingAppData(
      selectedPlan: FastingAppData.defaultPlan,
      sessions: [],
      glassEffectEnabled: false,
    );

    final restored = FastingAppData.fromJson(data.toJson());
    final olderData = FastingAppData.fromJson(
      Map<String, dynamic>.from(data.toJson())..remove('glassEffectEnabled'),
    );

    expect(restored.glassEffectEnabled, isFalse);
    expect(olderData.glassEffectEnabled, isTrue);
  });

  test('rejects multiple active sessions in saved data', () async {
    final session = FastingSession.start(
      id: 'session-one',
      plan: plan,
      startAt: startAt,
    );
    final data = FastingAppData(
      selectedPlan: plan,
      sessions: [
        session,
        FastingSession.start(id: 'session-two', plan: plan, startAt: startAt),
      ],
    );
    final store = MemoryStringStore()
      ..values['fastise.app_data.v1'] = jsonEncode(data.toJson());
    final repository = FastingRepository(store: store);

    await expectLater(repository.load(), throwsFormatException);
  });

  test('clears only the Fastise state key', () async {
    final store = MemoryStringStore()
      ..values['fastise.app_data.v1'] = 'saved'
      ..values['other-app-key'] = 'untouched';
    final repository = FastingRepository(store: store);

    await repository.clear();

    expect(store.values, {'other-app-key': 'untouched'});
  });
}
