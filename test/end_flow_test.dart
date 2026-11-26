import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';

/// pumpAndSettle never settles while the 1s ticker is running.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  late DateTime clock;
  late FastingController controller;

  setUp(() {
    clock = DateTime(2026, 1, 1, 8);
    controller = FastingController(clock: () => clock);
  });

  Future<void> startAndRun(WidgetTester tester, Duration d) async {
    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.tap(find.text('Start Fasting'));
    await tester.pump();
    clock = clock.add(d);
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('cancelling the end dialog keeps the session unchanged', (
    tester,
  ) async {
    await startAndRun(tester, const Duration(hours: 3));

    await tester.tap(find.text('End Fasting'));
    await _settle(tester);
    expect(find.text('End this fast?'), findsOneWidget);

    await tester.tap(find.text('Keep fasting'));
    await _settle(tester);

    expect(find.text('End this fast?'), findsNothing);
    expect(controller.isFasting, isTrue);
    expect(controller.sessions, isEmpty);
    expect(find.text('End Fasting'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('confirming ends the session, shows a neutral summary', (
    tester,
  ) async {
    await startAndRun(tester, const Duration(hours: 3, minutes: 30));

    await tester.tap(find.text('End Fasting'));
    await _settle(tester);
    await tester.tap(find.text('End session'));
    await _settle(tester);

    expect(find.text('Session summary'), findsOneWidget);
    expect(find.text('3 h 30 m'), findsOneWidget); // actual duration
    expect(find.text('16 h 0 m'), findsOneWidget); // planned target
    expect(find.text('16:8'), findsOneWidget); // plan snapshot
    expect(find.textContaining('fail'), findsNothing);
    expect(controller.sessions, hasLength(1));
    expect(controller.sessions.single.actualDurationSeconds, 12600);

    await tester.tap(find.text('Done'));
    await _settle(tester);

    expect(find.text('Start Fasting'), findsOneWidget);
    expect(controller.isFasting, isFalse);

    // A new session does not touch the saved one.
    await tester.tap(find.text('Start Fasting'));
    await tester.pump();
    expect(controller.isFasting, isTrue);
    expect(controller.sessions, hasLength(1));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('cancel session discards only after confirmation', (
    tester,
  ) async {
    await startAndRun(tester, const Duration(hours: 1));

    await tester.tap(find.text('Cancel session'));
    await _settle(tester);
    await tester.tap(find.text('Keep fasting'));
    await _settle(tester);
    expect(controller.isFasting, isTrue);

    await tester.tap(find.text('Cancel session'));
    await _settle(tester);
    await tester.tap(find.text('Discard'));
    await _settle(tester);

    expect(controller.isFasting, isFalse);
    expect(controller.sessions, isEmpty);
    expect(find.text('Start Fasting'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('early end is recorded neutrally (no target-reached claim)', (
    tester,
  ) async {
    await startAndRun(tester, const Duration(minutes: 10));

    await tester.tap(find.text('End Fasting'));
    await _settle(tester);
    await tester.tap(find.text('End session'));
    await _settle(tester);

    expect(find.text('10 m'), findsOneWidget);
    expect(find.text('Target reached'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
