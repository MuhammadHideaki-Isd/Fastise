import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';

void main() {
  testWidgets('shows the home foundation and bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FastiseApp());

    expect(find.text('Your fasting space'), findsOneWidget);
    expect(find.text('Not fasting'), findsOneWidget);
    expect(find.text('Start fasting'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pump();
    expect(find.text('History'), findsNWidgets(2));
  });
}
