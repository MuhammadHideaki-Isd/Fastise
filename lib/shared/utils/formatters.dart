const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// `HH:MM:SS`. Hours may exceed 24 (long sessions).
String formatClock(Duration d) {
  final s = d.isNegative ? 0 : d.inSeconds;
  return '${_two(s ~/ 3600)}:${_two(s % 3600 ~/ 60)}:${_two(s % 60)}';
}

/// `HH:mm` in the given DateTime's own zone (callers pass local times).
String formatTime(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

/// `16 h 5 m`, `45 m`, or `0 m`. Seconds are dropped on purpose.
String formatDuration(Duration d) {
  final minutes = d.isNegative ? 0 : d.inMinutes;
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m m';
  return '$h h $m m';
}

/// `Thursday, 25 Nov` (full) or `Thu, 25 Nov`.
String formatDate(DateTime d, {bool full = false}) {
  final day = _weekdays[d.weekday - 1];
  return '${full ? day : day.substring(0, 3)}, ${d.day} ${_months[d.month - 1]}';
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// `HH:mm` when on the same day as [relativeTo], else `Thu 08:00`.
String formatWhen(DateTime t, DateTime relativeTo) {
  if (isSameDay(t, relativeTo)) return formatTime(t);
  return '${_weekdays[t.weekday - 1].substring(0, 3)} ${formatTime(t)}';
}
