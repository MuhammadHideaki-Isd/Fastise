import 'package:flutter_test/flutter_test.dart';
import 'package:fastise/features/fasting/domain/fasting_plan.dart';
import 'package:fastise/features/fasting/domain/fasting_session.dart';
import 'package:fastise/features/progress/domain/progress_summary.dart';

void main() {
  const plan = FastingPlan(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );
  final now = DateTime(2026, 11, 25, 12);

  FastingSession completed(String id, DateTime startAt, Duration duration) {
    return FastingSession.start(
      id: id,
      plan: plan,
      startAt: startAt,
    ).completeAt(startAt.add(duration));
  }

  test(
    'calculates all-time metrics and current calendar week by completion',
    () {
      final tuesday = completed(
        'tuesday',
        DateTime(2026, 11, 24, 8),
        const Duration(hours: 2),
      );
      final wednesday = completed(
        'wednesday',
        DateTime(2026, 11, 25, 5),
        const Duration(hours: 4),
      );
      final previousWeek = completed(
        'previous-week',
        DateTime(2026, 11, 16, 8),
        const Duration(hours: 3),
      );
      final active = FastingSession.start(
        id: 'active',
        plan: plan,
        startAt: now,
      );

      final summary = ProgressSummary.calculate(
        sessions: [tuesday, wednesday, previousWeek, active],
        now: now,
      );

      expect(summary.completedSessionCount, 3);
      expect(summary.totalDuration, const Duration(hours: 9));
      expect(summary.averageDuration, const Duration(hours: 3));
      expect(summary.weeklySessionCount, 2);
      expect(summary.weeklyTotalDuration, const Duration(hours: 6));
      expect(summary.weeklyAverageDuration, const Duration(hours: 3));
      expect(summary.weekStart, DateTime(2026, 11, 23));
      expect(summary.weeklyProgress, hasLength(7));
      expect(
        summary.weeklyProgress[1].totalSeconds,
        const Duration(hours: 2).inSeconds,
      );
      expect(
        summary.weeklyProgress[2].totalSeconds,
        const Duration(hours: 4).inSeconds,
      );
      expect(
        summary.weeklyProgress.fold<int>(
          0,
          (total, day) => total + day.totalSeconds,
        ),
        const Duration(hours: 6).inSeconds,
      );
    },
  );

  test(
    'returns zero weekly values and no average without completed sessions',
    () {
      final active = FastingSession.start(
        id: 'active',
        plan: plan,
        startAt: now,
      );

      final summary = ProgressSummary.calculate(sessions: [active], now: now);

      expect(summary.completedSessionCount, 0);
      expect(summary.totalDuration, Duration.zero);
      expect(summary.averageDuration, isNull);
      expect(summary.weeklySessionCount, 0);
      expect(summary.weeklyTotalDuration, Duration.zero);
      expect(summary.weeklyAverageDuration, isNull);
      expect(
        summary.weeklyProgress.every((day) => day.totalSeconds == 0),
        isTrue,
      );
    },
  );

  test(
    'excludes completion on the next Monday from the current week chart',
    () {
      final nextMonday = completed(
        'next-monday',
        DateTime(2026, 11, 30, 8),
        const Duration(hours: 5),
      );

      final summary = ProgressSummary.calculate(
        sessions: [nextMonday],
        now: now,
      );

      expect(summary.completedSessionCount, 1);
      expect(summary.totalDuration, const Duration(hours: 5));
      expect(summary.weeklySessionCount, 0);
      expect(
        summary.weeklyProgress.every((day) => day.totalSeconds == 0),
        isTrue,
      );
    },
  );
}
