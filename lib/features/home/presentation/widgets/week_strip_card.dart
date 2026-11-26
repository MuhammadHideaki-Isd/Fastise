import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../fasting/domain/fasting_session.dart';
import '../../../fasting/domain/fasting_stats.dart';

/// Compact Mon–Sun calendar strip inspired by modern wellness trackers.
/// Shows each day of the current week with a progress ring reflecting
/// completed or running fasting activity.
class WeekStripCard extends StatelessWidget {
  const WeekStripCard({
    super.key,
    required this.now,
    required this.sessions,
    required this.activeSession,
    required this.targetHours,
  });

  final DateTime now;
  final List<FastingSession> sessions;
  final FastingSession? activeSession;
  final int targetHours;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final monday = startOfWeek(now);
    final targetSeconds = math.max(1, targetHours * 3600);
    final entries = <_DayEntry>[];
    var loggedDays = 0;

    for (var i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      final isToday = isSameDay(day, now);
      var seconds = 0;
      for (final s in sessions) {
        if (isSameDay(s.startAt, day)) {
          seconds += s.actualDurationSeconds ?? s.actualDuration.inSeconds;
        }
      }
      if (isToday && activeSession != null) {
        seconds += activeSession!.elapsed(now).inSeconds;
      }
      if (seconds > 0) loggedDays++;
      final progress = (seconds / targetSeconds).clamp(0.0, 1.0);
      entries.add(
        _DayEntry(
          label: _dayNames[i],
          dayNumber: day.day,
          isToday: isToday,
          progress: progress,
          reachedTarget: seconds >= targetSeconds,
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Weekly rhythm, $loggedDays of 7 days active this week',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Weekly rhythm',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: loggedDays > 0
                          ? AppColors.primarySoft
                          : AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: loggedDays > 0
                            ? AppColors.primary.withValues(alpha: 0.30)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: loggedDays > 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$loggedDays/7 active',
                          style: textTheme.labelSmall?.copyWith(
                            color: loggedDays > 0
                                ? AppColors.primaryBright
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 58,
                child: CustomPaint(
                  painter: _WeekStripPainter(entries: entries),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayEntry {
  const _DayEntry({
    required this.label,
    required this.dayNumber,
    required this.isToday,
    required this.progress,
    required this.reachedTarget,
  });

  final String label;
  final int dayNumber;
  final bool isToday;
  final double progress;
  final bool reachedTarget;
}

class _WeekStripPainter extends CustomPainter {
  const _WeekStripPainter({required this.entries});

  final List<_DayEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final slotWidth = size.width / entries.length;
    final circleRadius = math.min(16.5, (slotWidth - 6) / 2);
    final circleY = size.height - circleRadius - 2;

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final cx = slotWidth * i + slotWidth / 2;
      final center = Offset(cx, circleY);

      // Weekday short label (Mon..Sun)
      final dayLabelPainter = TextPainter(
        text: TextSpan(
          text: e.label,
          style: TextStyle(
            fontFamily: AppColors.fontBody,
            fontSize: 11,
            fontWeight: e.isToday ? FontWeight.w700 : FontWeight.w500,
            color: e.isToday ? AppColors.primaryBright : AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);
      dayLabelPainter.paint(
        canvas,
        Offset(cx - dayLabelPainter.width / 2, 0),
      );

      // Day circle fill
      final fillColor = e.reachedTarget
          ? AppColors.accentWarmSoft
          : (e.isToday
                ? AppColors.primarySoft
                : (e.progress > 0
                      ? AppColors.primarySoft.withValues(alpha: 0.55)
                      : AppColors.surfaceSubtle));
      canvas.drawCircle(center, circleRadius, Paint()..color = fillColor);

      // Base ring track
      final trackPaint = Paint()
        ..color = e.isToday
            ? AppColors.primary.withValues(alpha: 0.35)
            : AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawCircle(center, circleRadius - 1.1, trackPaint);

      // Active progress ring around the day number
      if (e.progress > 0) {
        final arcPaint = Paint()
          ..color = e.reachedTarget ? AppColors.accentWarm : AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: circleRadius - 1.1),
          -math.pi / 2,
          2 * math.pi * e.progress,
          false,
          arcPaint,
        );
      }

      // Day number inside circle
      final numPainter = TextPainter(
        text: TextSpan(
          text: '${e.dayNumber}',
          style: TextStyle(
            fontFamily: AppColors.fontDisplay,
            fontSize: circleRadius < 14 ? 10 : 11.5,
            fontWeight: e.isToday || e.progress > 0
                ? FontWeight.w700
                : FontWeight.w500,
            color: e.reachedTarget
                ? AppColors.accentWarm
                : (e.isToday
                      ? AppColors.textPrimary
                      : (e.progress > 0
                            ? AppColors.primaryBright
                            : AppColors.textSecondary)),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numPainter.paint(
        canvas,
        Offset(cx - numPainter.width / 2, circleY - numPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeekStripPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
