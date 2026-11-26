import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/data/fasting_repository.dart';

/// Blueprint §17: the end-to-end MVP scenario, with real persistence and a
/// simulated app restart (new controller built from the same storage).
void main() {
  testWidgets('select plan -> start -> restart -> end -> history -> new fast', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    var clock = DateTime(2026, 1, 1, 8);

    Future<FastingController> launch() async {
      final prefs = await tester.runAsync(SharedPreferences.getInstance);
      final controller = FastingController(
        clock: () => clock,
        repository: FastingRepository(prefs!),
      );
      await tester.pumpWidget(FastiseApp(controller: controller));
      return controller;
    }

    Future<void> settle() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    Future<void> flushStorage() async {
      await tester.runAsync(() => pumpEventQueue());
    }

    // 1-2. Open the app, choose 16:8.
    var controller = await launch();
    expect(find.text('Not fasting'), findsOneWidget);
    await tester.ensureVisible(find.text('16:8'));
    await tester.pump();
    await tester.tap(find.text('16:8'));
    await settle();
    await tester.tap(find.text('16:8').last);
    await tester.pump();
    await tester.tap(find.text('Save Plan'));
    await settle();

    // 3-4. Start fasting: the dashboard turns active.
    await tester.tap(find.text('Start Fasting'));
    await tester.pump();
    expect(find.text('Fasting'), findsOneWidget);
    expect(find.text('End Fasting'), findsOneWidget);
    await flushStorage();

    // 5. Close the app (tree torn down, ticker cancelled).
    await tester.pumpWidget(const SizedBox());

    // 6. Reopen 5 h later: the timer matches real elapsed time.
    clock = clock.add(const Duration(hours: 5));
    controller = await launch();
    expect(controller.isFasting, isTrue);
    expect(find.text('05:00:00'), findsOneWidget);
    expect(find.text('11 h 0 m left'), findsOneWidget);

    // 7-8. End fasting, confirm, see the summary.
    clock = clock.add(const Duration(minutes: 30));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('End Fasting'));
    await settle();
    await tester.tap(find.text('End session'));
    await settle();
    expect(find.text('Session summary'), findsOneWidget);
    expect(find.text('5 h 30 m'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await settle();
    await flushStorage();

    // 9. The finished session is in History.
    await tester.tap(find.text('History'));
    await tester.pump();
    expect(find.text('Thursday, 1 Jan'), findsOneWidget);
    expect(find.text('5 h 30 m'), findsOneWidget);

    // ...and is still there after another restart.
    await tester.pumpWidget(const SizedBox());
    controller = await launch();
    await tester.tap(find.text('History'));
    await tester.pump();
    expect(find.text('5 h 30 m'), findsOneWidget);

    // 10. A new session starts without damaging the previous record.
    await tester.tap(find.text('Home'));
    await tester.pump();
    await tester.tap(find.text('Start Fasting'));
    await tester.pump();
    expect(controller.isFasting, isTrue);
    expect(controller.sessions, hasLength(1));
    expect(controller.sessions.single.actualDurationSeconds, 5 * 3600 + 1800);

    await tester.pumpWidget(const SizedBox());
  });
}
