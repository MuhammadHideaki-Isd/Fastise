import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';
import 'package:fastise/features/history/presentation/history_screen.dart';

void main() {
  const plan16 = FastingPlan(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );
  const plan18 = FastingPlan(
    id: '18-6',
    name: '18:6',
    fastingHours: 18,
    eatingHours: 6,
  );

  testWidgets('shows an empty state when there are no completed sessions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HistoryScreen(sessions: [])),
    );

    expect(find.text('0 completed sessions'), findsOneWidget);
    expect(find.text('No completed sessions yet'), findsOneWidget);
  });

  testWidgets(
    'shows completed sessions newest first and omits active sessions',
    (WidgetTester tester) async {
      final olderStart = DateTime(2026, 11, 20, 8);
      final newerStart = DateTime(2026, 11, 25, 9);
      final older = FastingSession.start(
        id: 'older-session',
        plan: plan16,
        startAt: olderStart,
      ).completeAt(olderStart.add(const Duration(hours: 3)));
      final newer = FastingSession.start(
        id: 'newer-session',
        plan: plan18,
        startAt: newerStart,
      ).completeAt(newerStart.add(const Duration(hours: 5)));
      final active = FastingSession.start(
        id: 'active-session',
        plan: plan16,
        startAt: DateTime(2026, 11, 26, 10),
      );

      await tester.pumpWidget(
        MaterialApp(home: HistoryScreen(sessions: [older, active, newer])),
      );

      expect(find.text('2 completed sessions'), findsOneWidget);
      expect(find.text('18:6'), findsOneWidget);
      expect(find.text('16:8'), findsOneWidget);
      expect(find.text('05:00:00'), findsOneWidget);
      expect(find.text('03:00:00'), findsOneWidget);
      expect(find.text('Start 9:00 AM'), findsOneWidget);
      expect(find.text('End 2:00 PM'), findsOneWidget);

      final newerPosition = tester.getTopLeft(find.text('18:6')).dy;
      final olderPosition = tester.getTopLeft(find.text('16:8')).dy;
      expect(newerPosition, lessThan(olderPosition));
    },
  );
}
