import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/domain/fasting_stats.dart';

void main() {
  late DateTime clock;
  late FastingController controller;

  setUp(() {
    clock = DateTime(2026, 1, 1, 8); // Thursday
    controller = FastingController(clock: () => clock);
  });

  void addSession(DateTime start, Duration length) {
    clock = start;
    controller.startFasting();
    clock = start.add(length);
    controller.endFasting();
  }

  test('startOfWeek is Monday 00:00', () {
    expect(startOfWeek(DateTime(2026, 1, 13, 12)), DateTime(2026, 1, 12));
    expect(startOfWeek(DateTime(2026, 1, 12)), DateTime(2026, 1, 12));
    expect(startOfWeek(DateTime(2026, 1, 18, 23)), DateTime(2026, 1, 12));
  });

  testWidgets('empty history shows an empty state', (tester) async {
    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.tap(find.text('History'));
    await tester.pump();

    expect(find.text('No sessions yet'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
  });

  testWidgets('lists saved sessions newest first, grouped by day', (
    tester,
  ) async {
    addSession(DateTime(2026, 1, 1, 8), const Duration(hours: 3, minutes: 30));
    addSession(DateTime(2026, 1, 12, 9), const Duration(hours: 2));
    clock = DateTime(2026, 1, 13, 12); // Tuesday of the later week

    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.tap(find.text('History'));
    await tester.pump();

    expect(find.text('Monday, 12 Jan'), findsOneWidget);
    expect(find.text('Thursday, 1 Jan'), findsOneWidget);
    expect(find.text('2 h 0 m'), findsOneWidget);
    expect(find.text('3 h 30 m'), findsOneWidget);
    final newer = tester.getTopLeft(find.text('Monday, 12 Jan')).dy;
    final older = tester.getTopLeft(find.text('Thursday, 1 Jan')).dy;
    expect(newer, lessThan(older));

    // This week filter hides the earlier week.
    await tester.tap(find.text('This week'));
    await tester.pump();
    expect(find.text('2 h 0 m'), findsOneWidget);
    expect(find.text('3 h 30 m'), findsNothing);

    // Details open from a tile.
    await tester.tap(find.text('2 h 0 m'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Session details'), findsOneWidget);
    expect(find.text('Planned target'), findsOneWidget);
  });

  testWidgets('home shows the latest sessions as recent activity', (
    tester,
  ) async {
    addSession(DateTime(2026, 1, 1, 8), const Duration(hours: 3, minutes: 30));
    addSession(DateTime(2026, 1, 12, 9), const Duration(hours: 2));
    clock = DateTime(2026, 1, 13, 12);

    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.scrollUntilVisible(find.textContaining('Thu, 1 Jan'), 200);

    expect(find.text('No sessions yet'), findsNothing);
    expect(find.textContaining('Mon, 12 Jan'), findsOneWidget);
    expect(find.textContaining('Thu, 1 Jan'), findsOneWidget);
  });

  testWidgets('history fits a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addSession(DateTime(2026, 1, 1, 8), const Duration(hours: 18));

    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.tap(find.text('History'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
