import '../../fasting/domain/fasting_session.dart';

class DailyProgress {
  const DailyProgress({required this.date, required this.totalSeconds});

  final DateTime date;
  final int totalSeconds;
}

class ProgressSummary {
  const ProgressSummary({
    required this.completedSessionCount,
    required this.totalDuration,
    required this.averageDuration,
    required this.weeklySessionCount,
    required this.weeklyTotalDuration,
    required this.weeklyAverageDuration,
    required this.weekStart,
    required this.weeklyProgress,
  });

  final int completedSessionCount;
  final Duration totalDuration;
  final Duration? averageDuration;
  final int weeklySessionCount;
  final Duration weeklyTotalDuration;
  final Duration? weeklyAverageDuration;
  final DateTime weekStart;
  final List<DailyProgress> weeklyProgress;

  factory ProgressSummary.calculate({
    required List<FastingSession> sessions,
    required DateTime now,
  }) {
    final completed = sessions
        .where(
          (session) =>
              session.status == FastingSessionStatus.completed &&
              session.endAt != null &&
              session.actualDurationSeconds != null,
        )
        .toList();
    final totalSeconds = completed.fold<int>(
      0,
      (total, session) => total + session.actualDurationSeconds!,
    );
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - DateTime.monday),
    );
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 7,
    );
    final weeklyCompleted = completed.where((session) {
      final endAt = session.endAt!;
      final completionDate = DateTime(endAt.year, endAt.month, endAt.day);
      return !completionDate.isBefore(weekStart) &&
          completionDate.isBefore(weekEnd);
    }).toList();
    final dailySeconds = List<int>.filled(7, 0);

    for (final session in weeklyCompleted) {
      final endAt = session.endAt!;
      dailySeconds[endAt.weekday - DateTime.monday] +=
          session.actualDurationSeconds!;
    }
    final weeklyTotalSeconds = weeklyCompleted.fold<int>(
      0,
      (total, session) => total + session.actualDurationSeconds!,
    );

    return ProgressSummary(
      completedSessionCount: completed.length,
      totalDuration: Duration(seconds: totalSeconds),
      averageDuration: completed.isEmpty
          ? null
          : Duration(seconds: (totalSeconds / completed.length).round()),
      weeklySessionCount: weeklyCompleted.length,
      weeklyTotalDuration: Duration(seconds: weeklyTotalSeconds),
      weeklyAverageDuration: weeklyCompleted.isEmpty
          ? null
          : Duration(
              seconds: (weeklyTotalSeconds / weeklyCompleted.length).round(),
            ),
      weekStart: weekStart,
      weeklyProgress: List.unmodifiable(
        List.generate(
          7,
          (index) => DailyProgress(
            date: DateTime(
              weekStart.year,
              weekStart.month,
              weekStart.day + index,
            ),
            totalSeconds: dailySeconds[index],
          ),
        ),
      ),
    );
  }
}
