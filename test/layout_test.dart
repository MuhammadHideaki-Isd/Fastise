import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';

/// Layout sweep: every tab, idle and active, small / large screens and
/// enlarged text. Any RenderFlex overflow surfaces as a test exception.
void main() {
  late DateTime clock;

  FastingController build({required bool active}) {
    clock = DateTime(2026, 1, 1, 8);
    final c = FastingController(clock: () => clock);
    for (var i = 0; i < 4; i++) {
      c.startFasting();
      clock = clock.add(const Duration(hours: 16, minutes: 30));
      c.endFasting();
      clock = clock.add(const Duration(hours: 8));
    }
    if (active) {
      c.startFasting();
      clock = clock.add(const Duration(hours: 17));
    }
    return c;
  }

  const sizes = {
    'small phone': (Size(320, 568), 1.0),
    'small phone, large text': (Size(320, 568), 1.6),
    'phone': (Size(411, 891), 1.0),
    'tablet': (Size(800, 1280), 1.0),
  };

  for (final entry in sizes.entries) {
    for (final active in [false, true]) {
      testWidgets(
        '${entry.key}, ${active ? 'active' : 'idle'}: no overflow on any tab',
        (tester) async {
          final (size, textScale) = entry.value;
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          tester.platformDispatcher.textScaleFactorTestValue = textScale;
          addTearDown(tester.platformDispatcher.clearAllTestValues);

          await tester.pumpWidget(
            FastiseApp(controller: build(active: active)),
          );
          final scaler = MediaQuery.textScalerOf(
            tester.element(find.byType(Scaffold).first),
          );
          expect(scaler.scale(10), closeTo(10 * textScale, 1e-9));

          for (final tab in ['Home', 'Progress', 'History', 'Profile']) {
            await tester.tap(find.text(tab));
            await tester.pump();
            expect(
              tester.takeException(),
              isNull,
              reason: '$tab overflowed on ${entry.key}',
            );
          }
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
