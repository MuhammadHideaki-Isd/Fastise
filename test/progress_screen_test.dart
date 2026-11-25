import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';
import 'package:fastise/features/progress/presentation/progress_screen.dart';

void main() {
  testWidgets('shows an honest empty state and no average without data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProgressScreen(
          sessions: const [],
          now: () => DateTime(2026, 11, 25),
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('0m'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('No completed sessions this week.'), findsOneWidget);
    expect(find.text('23–29 Nov 2026'), findsOneWidget);
  });

  testWidgets('shows calculated metrics and weekly day values', (
    WidgetTester tester,
  ) async {
    const plan = FastingPlan(
      id: '16-8',
      name: '16:8',
      fastingHours: 16,
      eatingHours: 8,
    );
    final startAt = DateTime(2026, 11, 24, 8);
    final session = FastingSession.start(
      id: 'session',
      plan: plan,
      startAt: startAt,
    ).completeAt(startAt.add(const Duration(hours: 2)));

    await tester.pumpWidget(
      MaterialApp(
        home: ProgressScreen(
          sessions: [session],
          now: () => DateTime(2026, 11, 25),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2h'), findsNWidgets(2));
    expect(find.text('Tue'), findsOneWidget);
    expect(find.text('2.0h'), findsOneWidget);
  });
}
