import 'fasting_session.dart';

/// Monday 00:00 of the week containing [now] (local time).
DateTime startOfWeek(DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// 00:00 of the first day of a window of [days] days ending today.
DateTime startOfLastDays(DateTime now, int days) =>
    DateTime(now.year, now.month, now.day - (days - 1));

/// Sessions that started on or after [since]. Input order is kept.
List<FastingSession> sessionsSince(
  List<FastingSession> sessions,
  DateTime since,
) => [
  for (final s in sessions)
    if (!s.startAt.isBefore(since)) s,
];

class FastingStats {
  const FastingStats({required this.count, required this.total});

  final int count;
  final Duration total;

  /// Null when there are no sessions (never a made-up zero).
  Duration? get average => count == 0 ? null : total ~/ count;
}

/// Totals over completed sessions only.
FastingStats statsFor(List<FastingSession> sessions) {
  var total = Duration.zero;
  var count = 0;
  for (final s in sessions) {
    if (s.status != SessionStatus.completed) continue;
    total += s.actualDuration;
    count++;
  }
  return FastingStats(count: count, total: total);
}

/// Fasting time per local day (by start date) for the last [days] days,
/// oldest first, ending today. Days without sessions are zero.
List<({DateTime day, Duration total})> dailyTotals(
  List<FastingSession> sessions,
  DateTime now,
  int days,
) {
  final first = startOfLastDays(now, days);
  return [
    for (var i = 0; i < days; i++)
      () {
        final targetDay = DateTime(first.year, first.month, first.day + i);
        return (
          day: targetDay,
          total: statsFor([
            for (final s in sessions)
              if (s.startAt.year == targetDay.year &&
                  s.startAt.month == targetDay.month &&
                  s.startAt.day == targetDay.day)
                s,
          ]).total,
        );
      }(),
  ];
}

/// Consecutive days with at least one completed (or currently active) fast.
/// Following Duolingo-style streak rules, yesterday's streak stays alive
/// throughout today until the user logs today's session.
int currentStreakDays(
  List<FastingSession> sessions,
  DateTime now, {
  FastingSession? activeSession,
}) {
  DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  final activeDays = <DateTime>{
    for (final s in sessions)
      if (s.status == SessionStatus.completed) dayOnly(s.startAt),
  };

  final today = dayOnly(now);
  if (activeSession != null) {
    activeDays.add(dayOnly(activeSession.startAt));
    activeDays.add(today);
  }

  final yesterday = DateTime(today.year, today.month, today.day - 1);
  DateTime cursor;
  if (activeDays.contains(today)) {
    cursor = today;
  } else if (activeDays.contains(yesterday)) {
    cursor = yesterday;
  } else {
    return 0;
  }

  var streak = 0;
  while (activeDays.contains(cursor)) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return streak;
}
