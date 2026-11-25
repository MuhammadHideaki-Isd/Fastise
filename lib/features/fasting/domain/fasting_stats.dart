import 'fasting_session.dart';

/// Monday 00:00 of the week containing [now] (local time).
DateTime startOfWeek(DateTime now) {
  final day = DateTime(now.year, now.month, now.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// Sessions that started on or after [since]. Input order is kept.
List<FastingSession> sessionsSince(
  List<FastingSession> sessions,
  DateTime since,
) => [
  for (final s in sessions)
    if (!s.startAt.isBefore(since)) s,
];
