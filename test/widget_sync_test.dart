import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/domain/fasting_stats.dart';
import 'package:fastise/features/widget/data/home_widget_sync.dart';

void main() {
  group('currentStreakDays', () {
    test('returns 0 when no completed or active fasts exist', () {
      expect(currentStreakDays(const [], DateTime(2026, 11, 27, 9)), 0);
    });

    test('keeps yesterday streak alive today until user logs today', () {
      var clock = DateTime(2026, 11, 25, 20);
      final c = FastingController(clock: () => clock);

      // Day 1: Nov 25
      c.startFasting();
      clock = DateTime(2026, 11, 26, 12);
      c.endFasting();

      // Day 2: Nov 26
      clock = DateTime(2026, 11, 26, 20);
      c.startFasting();
      clock = DateTime(2026, 11, 27, 8);
      c.endFasting();

      // On Nov 27 morning (no fast started yet on Nov 27), streak is 2 days.
      expect(
        currentStreakDays(c.sessions, DateTime(2026, 11, 27, 9)),
        2,
      );

      // Starting a fast on Nov 27 extends streak to 3 days.
      clock = DateTime(2026, 11, 27, 10);
      c.startFasting();
      expect(
        currentStreakDays(
          c.sessions,
          DateTime(2026, 11, 27, 10),
          activeSession: c.activeSession,
        ),
        3,
      );

      // Missing Nov 27 completely breaks streak on Nov 28.
      expect(currentStreakDays(c.sessions, DateTime(2026, 11, 28, 9)), 0);
    });
  });

  group('WidgetSnapshot moods', () {
    test('covers idle, fasting, targetReached, and doneToday moods', () {
      var clock = DateTime(2026, 11, 27, 8, 0);
      final c = FastingController(clock: () => clock);

      final idleSnap = WidgetSnapshot.fromController(c);
      expect(idleSnap.mood, WidgetMood.idle);
      expect(idleSnap.headline, 'Ready to fast?');
      expect(idleSnap.streakDays, 0);

      c.startFasting();
      clock = DateTime(2026, 11, 27, 16, 0); // 8h elapsed
      final fastingSnap = WidgetSnapshot.fromController(c);
      expect(fastingSnap.mood, WidgetMood.fasting);
      expect(fastingSnap.progressPercent, 50);
      expect(fastingSnap.streakDays, 1);

      clock = DateTime(2026, 11, 28, 1, 0); // 17h elapsed (> 16h)
      final goalSnap = WidgetSnapshot.fromController(c);
      expect(goalSnap.mood, WidgetMood.targetReached);
      expect(goalSnap.headline, 'Goal reached!');
      expect(goalSnap.progressPercent, 100);

      c.endFasting();
      final doneSnap = WidgetSnapshot.fromController(c);
      expect(doneSnap.mood, WidgetMood.doneToday);
      expect(doneSnap.headline, 'Great job today!');
      expect(doneSnap.lastDurationLabel, '17 h 0 m');
    });
  });

  group('HomeWidgetSync MethodChannel', () {
    testWidgets('syncs widget payload on launch and fasting actions', (
      tester,
    ) async {
      final calls = <MethodCall>[];
      const channel = MethodChannel('test_fastise_widget');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'requestPinWidget') return true;
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );

      final clock = DateTime(2026, 11, 27, 9);
      final controller = FastingController(clock: () => clock);
      final sync = HomeWidgetSync(channel: channel);

      await tester.pumpWidget(FastiseApp(controller: controller, widgetSync: sync));
      expect(calls, hasLength(1));
      expect(calls.last.method, 'updateWidget');
      expect((calls.last.arguments as Map)['mood'], 'idle');

      await tester.tap(find.text('Start Fasting'));
      await tester.pump();
      expect(calls, hasLength(2));
      expect((calls.last.arguments as Map)['mood'], 'fasting');
      expect((calls.last.arguments as Map)['streakDays'], 1);

      expect(await sync.requestPinWidget(), isTrue);
      await tester.pumpWidget(const SizedBox());
    });
  });

  testWidgets('Profile shows Home screen widget preview and Add button', (
    tester,
  ) async {
    final controller = FastingController(clock: () => DateTime(2026, 11, 27, 9));
    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.tap(find.text('Profile'));
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Add widget to Home screen'), 200);
    expect(find.text('HOME SCREEN WIDGET'), findsOneWidget);
    expect(find.text('Ready to fast?'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
