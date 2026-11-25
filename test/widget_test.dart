import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/data/fasting_repository.dart';
import 'package:fastise/features/fasting/presentation/plan_selection_screen.dart';
import 'package:fastise/features/fasting/presentation/session_summary_screen.dart';

import 'support/memory_string_store.dart';

void main() {
  testWidgets('shows the home foundation and bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      FastiseApp(repository: FastingRepository(store: MemoryStringStore())),
    );
    await tester.pumpAndSettle();

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
    final repository = FastingRepository(store: MemoryStringStore());
    await tester.pumpWidget(FastiseApp(repository: repository));
    await tester.pumpAndSettle();

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
    expect((await repository.load()).selectedPlan.id, '18-6');
  });

  testWidgets('confirms session end, shows summary, and returns home', (
    WidgetTester tester,
  ) async {
    final repository = FastingRepository(store: MemoryStringStore());
    await tester.pumpWidget(FastiseApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start fasting'));
    await tester.pump();

    expect(find.text('Fasting'), findsOneWidget);
    expect(find.text('End fasting'), findsOneWidget);
    expect((await repository.load()).activeSession, isNotNull);

    await tester.tap(find.text('End fasting'));
    await tester.pumpAndSettle();

    expect(find.text('End fasting?'), findsOneWidget);
    await tester.tap(find.text('Keep fasting'));
    await tester.pumpAndSettle();
    expect(find.text('Fasting'), findsOneWidget);
    expect((await repository.load()).activeSession, isNotNull);

    await tester.tap(find.text('End fasting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionSummaryScreen), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Started'), findsOneWidget);
    expect(find.text('Ended'), findsOneWidget);
    expect(find.text('Actual duration'), findsOneWidget);
    expect((await repository.load()).completedSessions, hasLength(1));

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Not fasting'), findsOneWidget);
    expect(find.text('Start fasting'), findsOneWidget);
    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('1 completed session'), findsOneWidget);
    expect(find.text('16:8'), findsOneWidget);
  });

  testWidgets(
    'restores selected plan and an active session after app restart',
    (WidgetTester tester) async {
      final store = MemoryStringStore();
      final repository = FastingRepository(store: store);
      await tester.pumpWidget(FastiseApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('16:8 Intermittent fasting'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.textContaining('16:8 Intermittent fasting'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18:6').last);
      await tester.tap(find.text('Save plan'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Start fasting'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start fasting'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(FastiseApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Fasting'), findsOneWidget);
      expect(find.text('End fasting'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('18:6 Intermittent fasting'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('18:6 Intermittent fasting'), findsOneWidget);
      expect(find.textContaining('00:00:'), findsOneWidget);
    },
  );

  testWidgets('shows an error and rolls back when local save fails', (
    WidgetTester tester,
  ) async {
    final store = MemoryStringStore()
      ..writeError = const FastingStorageException('Storage write failed.');
    await tester.pumpWidget(
      FastiseApp(repository: FastingRepository(store: store)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start fasting'));
    await tester.pumpAndSettle();

    expect(find.text('Not fasting'), findsOneWidget);
    expect(find.text('Start fasting'), findsOneWidget);
    expect(find.text('Storage write failed.'), findsOneWidget);
  });

  testWidgets('keeps session active when saving completion fails', (
    WidgetTester tester,
  ) async {
    final store = MemoryStringStore();
    final repository = FastingRepository(store: store);
    await tester.pumpWidget(FastiseApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start fasting'));
    await tester.pumpAndSettle();
    store.writeError = const FastingStorageException('Storage write failed.');

    await tester.tap(find.text('End fasting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();

    expect(find.byType(SessionSummaryScreen), findsNothing);
    expect(find.text('Fasting'), findsOneWidget);
    expect((await repository.load()).activeSession, isNotNull);
    expect(find.text('Storage write failed.'), findsOneWidget);
  });
}
