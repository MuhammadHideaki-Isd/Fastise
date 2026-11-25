import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';

Widget _app([FastingController? controller]) =>
    FastiseApp(controller: controller ?? FastingController());

void main() {
  testWidgets('shows the idle home dashboard and bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());

    expect(find.text('Not fasting'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('Start Fasting'), findsOneWidget);
    expect(find.text('16:8'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('No sessions yet'), 200);
    expect(find.text('No sessions yet'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pump();
    expect(find.text('History'), findsNWidgets(2));
  });

  testWidgets('profile shortcut opens the Profile tab', (tester) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.byTooltip('Open profile'));
    await tester.pump();

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 3);
  });

  testWidgets('home fits a small screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app());

    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing a plan updates the home dashboard', (tester) async {
    final controller = FastingController();
    await tester.pumpWidget(_app(controller));
    expect(find.text('Target 16 h'), findsOneWidget);

    await tester.ensureVisible(find.text('16:8'));
    await tester.pump();
    await tester.tap(find.text('16:8'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your fasting plan'), findsOneWidget);
    expect(find.text('Selected'), findsOneWidget);

    await tester.tap(find.text('18:6'));
    await tester.pump();
    // Selection is only a draft until Save Plan.
    expect(controller.selectedPlan.id, '16-8');

    await tester.tap(find.text('Save Plan'));
    await tester.pumpAndSettle();

    expect(controller.selectedPlan.id, '18-6');
    expect(find.text('18:6'), findsOneWidget);
    expect(find.text('Target 18 h'), findsOneWidget);
  });

  test('presets are the four blueprint plans', () {
    expect(FastingPlan.presets.map((p) => p.name), [
      '14:10',
      '16:8',
      '18:6',
      '20:4',
    ]);
    for (final p in FastingPlan.presets) {
      expect(p.fastingHours + p.eatingHours, 24);
    }
    expect(FastingPlan.byId('nope'), isNull);
  });
}
