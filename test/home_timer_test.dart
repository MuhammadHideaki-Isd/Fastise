import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/shared/utils/formatters.dart';

void main() {
  group('formatters', () {
    test('formatClock', () {
      expect(formatClock(Duration.zero), '00:00:00');
      expect(formatClock(const Duration(hours: 4, seconds: 5)), '04:00:05');
      expect(formatClock(const Duration(hours: 26)), '26:00:00');
      expect(formatClock(const Duration(seconds: -5)), '00:00:00');
    });

    test('formatDuration', () {
      expect(formatDuration(const Duration(minutes: 45)), '45 m');
      expect(formatDuration(const Duration(hours: 16, minutes: 5)), '16 h 5 m');
      expect(formatDuration(Duration.zero), '0 m');
    });

    test('formatDate and formatWhen', () {
      final d = DateTime(2026, 11, 25, 9, 5);
      expect(formatDate(d, full: true), 'Wednesday, 25 Nov');
      expect(formatDate(d), 'Wed, 25 Nov');
      expect(formatWhen(d, DateTime(2026, 11, 25, 23)), '09:05');
      expect(formatWhen(d, DateTime(2026, 11, 24)), 'Wed 09:05');
    });
  });

  group('home timer', () {
    late DateTime clock;
    late FastingController controller;

    setUp(() {
      clock = DateTime(2026, 1, 1, 8); // a Thursday
      controller = FastingController(clock: () => clock);
    });

    testWidgets('start shows an active timer computed from startAt', (
      tester,
    ) async {
      await tester.pumpWidget(FastiseApp(controller: controller));
      await tester.tap(find.text('Start Fasting'));
      await tester.pump();

      expect(find.text('Fasting'), findsOneWidget);
      expect(find.text('00:00:00'), findsOneWidget);
      expect(find.text('16 h 0 m left'), findsOneWidget);
      expect(find.text('Started'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('Fri 00:00'), findsOneWidget);
      expect(find.text('Start Fasting'), findsNothing);

      // Jump the clock; the next tick must show the real elapsed time,
      // not "one more second".
      clock = clock.add(const Duration(hours: 4, minutes: 30));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('04:30:00'), findsOneWidget);
      expect(find.text('11 h 30 m left'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('reaching the target keeps the session running', (
      tester,
    ) async {
      await tester.pumpWidget(FastiseApp(controller: controller));
      await tester.tap(find.text('Start Fasting'));
      await tester.pump();

      clock = clock.add(const Duration(hours: 17));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Target reached'), findsOneWidget);
      expect(find.text('17:00:00'), findsOneWidget);
      expect(controller.isFasting, isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a running session is shown again after rebuilding the app', (
      tester,
    ) async {
      controller.startFasting();
      clock = clock.add(const Duration(hours: 2));

      await tester.pumpWidget(FastiseApp(controller: controller));

      expect(find.text('02:00:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('active state fits a small screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      controller.startFasting();
      clock = clock.add(const Duration(hours: 17));
      await tester.pumpWidget(FastiseApp(controller: controller));

      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
