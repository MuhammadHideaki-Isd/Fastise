import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';

void main() {
  testWidgets('shows the idle home dashboard and bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FastiseApp());

    expect(find.text('Not fasting'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('Start Fasting'), findsOneWidget);
    expect(find.text('16:8'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('No sessions yet'), 200);
    expect(find.text('No sessions yet'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // Start is disabled until session logic exists (Task 5/6).
    final cta = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(cta.onPressed, isNull);

    await tester.tap(find.text('History'));
    await tester.pump();
    expect(find.text('History'), findsNWidgets(2));
  });

  testWidgets('profile shortcut opens the Profile tab', (tester) async {
    await tester.pumpWidget(const FastiseApp());

    await tester.tap(find.byTooltip('Open profile'));
    await tester.pump();

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 3);
  });

  testWidgets('home fits a small screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FastiseApp());

    expect(tester.takeException(), isNull);
  });
}
