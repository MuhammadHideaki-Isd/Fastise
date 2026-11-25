import 'package:flutter_test/flutter_test.dart';

import 'package:fastise/app/app.dart';
import 'package:fastise/features/fasting/application/fasting_controller.dart';
import 'package:fastise/features/fasting/domain/fasting_stats.dart';

void main() {
  late DateTime clock;
  late FastingController controller;

  void addSession(DateTime start, Duration length) {
    clock = start;
    controller.startFasting();
    clock = start.add(length);
    controller.endFasting();
  }

  setUp(() {
    clock = DateTime(2026, 1, 1);
    controller = FastingController(clock: () => clock);
    addSession(DateTime(2025, 12, 20, 8), const Duration(hours: 3));
    addSession(DateTime(2026, 1, 7, 8), const Duration(hours: 4));
    addSession(DateTime(2026, 1, 12, 9), const Duration(hours: 2));
    addSession(DateTime(2026, 1, 12, 20), const Duration(hours: 1));
    clock = DateTime(2026, 1, 13, 12); // Tuesday
  });

  group('stats', () {
    test('empty input has no average', () {
      final s = statsFor(const []);
      expect(s.count, 0);
      expect(s.total, Duration.zero);
      expect(s.average, isNull);
    });

    test('7 and 30 day windows', () {
      final now = clock;
      final seven = statsFor(
        sessionsSince(controller.sessions, startOfLastDays(now, 7)),
      );
      expect(seven.count, 3);
      expect(seven.total, const Duration(hours: 7));
      expect(seven.average, const Duration(hours: 2, minutes: 20));

      final thirty = statsFor(
        sessionsSince(controller.sessions, startOfLastDays(now, 30)),
      );
      expect(thirty.count, 4);
      expect(thirty.total, const Duration(hours: 10));
    });

    test('dailyTotals is oldest first, ends today, sums per day', () {
      final totals = dailyTotals(controller.sessions, clock, 7);
      expect(totals, hasLength(7));
      expect(totals.first.day, DateTime(2026, 1, 7));
      expect(totals.last.day, DateTime(2026, 1, 13));
      expect(totals.first.total, const Duration(hours: 4));
      expect(totals[5].total, const Duration(hours: 3)); // Jan 12: 2h + 1h
      expect(totals.last.total, Duration.zero);
    });

    test('dailyTotals preserves sessions across month boundaries', () {
      final totals = dailyTotals(controller.sessions, clock, 30);
      expect(totals, hasLength(30));
      final dec20 = totals.singleWhere((t) => t.day == DateTime(2025, 12, 20));
      final jan12 = totals.singleWhere((t) => t.day == DateTime(2026, 1, 12));
      expect(dec20.total, const Duration(hours: 3));
      expect(jan12.total, const Duration(hours: 3));
    });
  });

  testWidgets('progress with no sessions shows an empty state', (tester) async {
    final empty = FastingController(clock: () => clock);
    await tester.pumpWidget(FastiseApp(controller: empty));
    await tester.tap(find.text('Progress'));
    await tester.pump();

    expect(find.text('Not enough data yet'), findsOneWidget);
  });

  testWidgets('progress totals come from saved sessions', (tester) async {
    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.tap(find.text('Progress'));
    await tester.pump();

    expect(find.text('7.0 h'), findsOneWidget);
    expect(find.text('2 h 20 m'), findsOneWidget);

    await tester.tap(find.text('30 days'));
    await tester.pump();
    expect(find.text('10.0 h'), findsOneWidget);
    expect(find.text('2 h 30 m'), findsOneWidget);
  });

  testWidgets('home quick stats use this week only', (tester) async {
    await tester.pumpWidget(FastiseApp(controller: controller));
    await tester.scrollUntilVisible(find.text('Avg. duration'), 200);

    // Monday 12 Jan: two sessions of 2 h and 1 h -> avg 1 h 30 m.
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1 h 30 m'), findsOneWidget);
  });
}
