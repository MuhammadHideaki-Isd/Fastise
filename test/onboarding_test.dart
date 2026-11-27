import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/data/fasting_repository.dart';

void main() {
  test('onboarding completion persists and survives restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = FastingController(repository: FastingRepository(prefs));
    expect(controller.hasSeenOnboarding, isFalse);

    controller.completeOnboarding();
    await pumpEventQueue();

    final reopened = FastingController(repository: FastingRepository(prefs));
    expect(reopened.hasSeenOnboarding, isTrue);

    reopened.resetData();
    await pumpEventQueue();
    expect(reopened.hasSeenOnboarding, isFalse);
    expect(prefs.getKeys(), isEmpty);
  });

  test('malformed onboarding flag falls back to false safely', () async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': 'yes'});
    final prefs = await SharedPreferences.getInstance();
    final repo = FastingRepository(prefs);
    expect(repo.loadHasSeenOnboarding(), isFalse);
  });

  testWidgets('first launch shows splash -> 3-step guide -> chooses plan -> home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    final controller = FastingController(repository: FastingRepository(prefs!));

    await tester.pumpWidget(
      FastiseApp(
        controller: controller,
        showLaunchFlow: true,
        splashDuration: const Duration(milliseconds: 200),
      ),
    );

    // 1. Splash screen renders first.
    expect(find.text('Fastise'), findsOneWidget);
    expect(find.text('Calm intermittent fasting'), findsOneWidget);

    // 2. Transitions to slide 1 of onboarding guide.
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Track every fast with calm clarity'), findsOneWidget);

    // 3. Advance to slide 2.
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Honest progress, privately yours'), findsOneWidget);

    // 4. Advance to slide 3 (plan picker) and choose 18:6.
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Pick a fasting plan'), findsOneWidget);

    await tester.ensureVisible(find.text('18:6'));
    await tester.tap(find.text('18:6'));
    await tester.pump();

    await tester.tap(find.text('Start using Fastise'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.hasSeenOnboarding, isTrue);
    expect(controller.selectedPlan.id, '18-6');
    expect(find.text('Not fasting'), findsOneWidget);
    expect(find.text('Target 18 h'), findsOneWidget);

    await tester.runAsync(() => pumpEventQueue());
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('returning user skips guide after splash and lands on Home', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    final controller = FastingController(repository: FastingRepository(prefs!));

    await tester.pumpWidget(
      FastiseApp(
        controller: controller,
        showLaunchFlow: true,
        splashDuration: const Duration(milliseconds: 150),
      ),
    );

    expect(find.text('Calm intermittent fasting'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Fastise Guide'), findsNothing);
    expect(find.text('Not fasting'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('skipping guide completes onboarding and keeps default plan', (
    tester,
  ) async {
    final controller = FastingController();

    await tester.pumpWidget(
      FastiseApp(
        controller: controller,
        showLaunchFlow: true,
        splashDuration: const Duration(milliseconds: 100),
      ),
    );

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(controller.hasSeenOnboarding, isTrue);
    expect(controller.selectedPlan.id, '16-8');
    expect(find.text('Not fasting'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Profile App guide replays guide without altering state', (
    tester,
  ) async {
    final controller = FastingController(hasSeenOnboarding: true);

    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.tap(find.text('Profile'));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('App guide'), 200);

    await tester.tap(find.text('App guide'));
    await tester.pumpAndSettle();

    expect(find.text('Fastise Guide'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Fastise Guide'), findsNothing);
    expect(find.text('Profile'), findsAtLeastNWidgets(1));
  });

  testWidgets('splash and all 3 guide slides fit small screen with 1.6x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    final controller = FastingController();
    await tester.pumpWidget(
      FastiseApp(
        controller: controller,
        showLaunchFlow: true,
        splashDuration: const Duration(milliseconds: 100),
      ),
    );
    expect(tester.takeException(), isNull, reason: 'Splash overflowed');

    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull, reason: 'Slide 1 overflowed');

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull, reason: 'Slide 2 overflowed');

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull, reason: 'Slide 3 overflowed');

    await tester.pumpWidget(const SizedBox());
  });
}
