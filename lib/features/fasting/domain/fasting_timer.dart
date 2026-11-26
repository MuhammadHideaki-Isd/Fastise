import 'fasting_session.dart';

class FastingTimerSnapshot {
  const FastingTimerSnapshot({
    required this.elapsed,
    required this.remaining,
    required this.progress,
    required this.targetReached,
  });

  final Duration elapsed;
  final Duration remaining;
  final double progress;
  final bool targetReached;

  String get elapsedLabel => formatDuration(elapsed);

  static String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}

abstract final class FastingTimer {
  static FastingTimerSnapshot calculate(
    FastingSession session,
    DateTime currentTime,
  ) {
    var elapsedSeconds = currentTime.difference(session.startAt).inSeconds;
    if (elapsedSeconds < 0) {
      elapsedSeconds = 0;
    }

    final elapsed = Duration(seconds: elapsedSeconds);
    final planned = Duration(minutes: session.plannedDurationMinutes);
    var remaining = planned - elapsed;
    if (remaining.isNegative) {
      remaining = Duration.zero;
    }

    var progress = planned.inSeconds == 0
        ? 0.0
        : elapsedSeconds / planned.inSeconds;
    if (progress < 0) {
      progress = 0;
    } else if (progress > 1) {
      progress = 1;
    }

    return FastingTimerSnapshot(
      elapsed: elapsed,
      remaining: remaining,
      progress: progress,
      targetReached: elapsed >= planned,
    );
  }
}
