import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/presentation/plan_selection_screen.dart';

void main() {
  testWidgets('shows the home foundation and bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FastiseApp());

    expect(find.text('Not fasting'), findsOneWidget);
    expect(find.text('Start fasting'), findsOneWidget);
    expect(find.text('0% complete'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('RECENT ACTIVITY'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('RECENT ACTIVITY'), findsOneWidget);
    expect(find.text('No recent sessions'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pump();
    expect(find.text('History'), findsNWidgets(2));
  });

  testWidgets('can select and save a fasting plan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FastiseApp());

    await tester.scrollUntilVisible(
      find.textContaining('16:8 Intermittent fasting'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.textContaining('16:8 Intermittent fasting'));
    await tester.pumpAndSettle();

    expect(find.byType(PlanSelectionScreen), findsOneWidget);
    await tester.tap(find.text('18:6').last);
    await tester.tap(find.text('Save plan'));
    await tester.pumpAndSettle();

    expect(find.text('18:6 Intermittent fasting'), findsOneWidget);
  });
}
