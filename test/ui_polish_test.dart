import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/data/fasting_repository.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';

import 'support/memory_string_store.dart';

void main() {
  testWidgets('main screens stay usable on a compact display', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final startAt = DateTime(2026, 1, 1, 8);
    final completedSession = FastingSession.start(
      id: 'compact-display-session',
      plan: FastingAppData.defaultPlan,
      startAt: startAt,
    ).completeAt(startAt.add(const Duration(hours: 36)));
    final repository = FastingRepository(store: MemoryStringStore());
    await repository.save(
      FastingAppData(
        selectedPlan: FastingAppData.defaultPlan,
        sessions: [completedSession],
      ),
    );

    await tester.pumpWidget(FastiseApp(repository: repository));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final profileButton = find.byTooltip('Profile');
    final homeProfileButton = profileButton.first;
    expect(tester.getSize(homeProfileButton).width, greaterThanOrEqualTo(48));
    await tester.tap(homeProfileButton);
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    expect(tester.takeException(), isNull);

    for (final tab in ['Home', 'Progress', 'History']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      final error = tester.takeException();
      expect(error, isNull, reason: '$tab should not overflow: $error');
    }

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('actual duration'));
    expect(find.text('36:00:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
