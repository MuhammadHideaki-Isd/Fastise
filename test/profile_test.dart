import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/data/fasting_repository.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';

Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.text('Profile'));
  await tester.pump();
}

void main() {
  late DateTime clock;
  late FastingController controller;

  setUp(() {
    clock = DateTime(2026, 1, 1, 8);
    controller = FastingController(clock: () => clock);
    controller.selectPlan(FastingPlan.byId('18-6')!);
    controller.startFasting();
    clock = clock.add(const Duration(hours: 1));
    controller.endFasting();
  });

  testWidgets('profile shows the plan, privacy and health notes', (
    tester,
  ) async {
    await tester.pumpWidget(FastiseApp(controller: controller));
    await _openProfile(tester);

    expect(find.text('18:6'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Health note'), 200);
    expect(find.textContaining('not medical advice'), findsOneWidget);
  });

  testWidgets('Edit opens plan selection and saving updates the profile', (
    tester,
  ) async {
    await tester.pumpWidget(FastiseApp(controller: controller));
    await _openProfile(tester);

    await tester.tap(find.text('18:6'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your fasting plan'), findsOneWidget);

    await tester.tap(find.text('14:10'));
    await tester.pump();
    await tester.tap(find.text('Save Plan'));
    await tester.pumpAndSettle();

    expect(controller.selectedPlan.id, '14-10');
    expect(find.text('14:10'), findsOneWidget);
  });

  testWidgets('reset needs confirmation and then clears everything', (
    tester,
  ) async {
    await tester.pumpWidget(FastiseApp(controller: controller));
    await _openProfile(tester);
    await tester.scrollUntilVisible(find.text('Reset all data'), 200);

    await tester.tap(find.text('Reset all data'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all data?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.sessions, hasLength(1));

    await tester.tap(find.text('Reset all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(controller.sessions, isEmpty);
    expect(controller.isFasting, isFalse);
    expect(controller.selectedPlan.id, '16-8');
  });

  test('reset also wipes stored data', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = FastingController(
      clock: () => clock,
      repository: FastingRepository(prefs),
    );
    c.selectPlan(FastingPlan.byId('20-4')!);
    c.startFasting();
    await pumpEventQueue();
    expect(prefs.getKeys(), isNotEmpty);

    c.resetData();
    await pumpEventQueue();
    expect(prefs.getKeys(), isEmpty);
  });

  testWidgets('profile fits a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(FastiseApp(controller: controller));
    await _openProfile(tester);

    expect(tester.takeException(), isNull);
  });
}
