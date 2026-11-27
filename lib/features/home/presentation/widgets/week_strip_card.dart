import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../fasting/domain/fasting_session.dart';
import '../../../fasting/domain/fasting_stats.dart';

/// Borderless Mon–Sun calendar strip modeled after the reference Nutrition screen:
/// logged days appear inside filled circular badges (Soft Sage Mint for active/logged,
/// Warm Sand for target reached) while inactive days remain crisp minimal numerals.
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

    return Semantics(
      label: 'Weekly rhythm, $loggedDays of 7 days active this week',
      excludeSemantics: true,
      child: SizedBox(
        height: 62,
        child: CustomPaint(
          painter: _WeekStripPainter(entries: entries),
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
    final circleRadius = math.min(17.5, (slotWidth - 6) / 2);
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
            fontSize: 11.5,
            fontWeight: e.isToday ? FontWeight.w700 : FontWeight.w500,
            color: e.isToday ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);
      dayLabelPainter.paint(
        canvas,
        Offset(cx - dayLabelPainter.width / 2, 0),
      );

      final hasFilledBadge = e.reachedTarget || e.progress > 0;

      if (hasFilledBadge) {
        final badgeColor = e.reachedTarget
            ? AppColors.accentWarm
            : AppColors.primary;
        // Subtle outer halo ring matching the reference's glowing day dots
        canvas.drawCircle(
          center,
          circleRadius + 1.5,
          Paint()
            ..color = badgeColor.withValues(alpha: 0.24)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
        // Solid filled circle
        canvas.drawCircle(center, circleRadius - 1, Paint()..color = badgeColor);
      } else if (e.isToday) {
        // Subtle outlined circle for today when idle
        canvas.drawCircle(
          center,
          circleRadius - 1,
          Paint()..color = AppColors.surfaceElevated,
        );
        canvas.drawCircle(
          center,
          circleRadius - 1,
          Paint()
            ..color = AppColors.primary.withValues(alpha: 0.70)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }

      // Day number inside circle (dark bold on filled badge, light otherwise)
      final numColor = hasFilledBadge
          ? AppColors.onPrimary
          : (e.isToday ? AppColors.textPrimary : AppColors.textSecondary);

      final numPainter = TextPainter(
        text: TextSpan(
          text: '${e.dayNumber}',
          style: TextStyle(
            fontFamily: AppColors.fontDisplay,
            fontSize: circleRadius < 14 ? 10.5 : 12.0,
            fontWeight: hasFilledBadge || e.isToday
                ? FontWeight.w700
                : FontWeight.w500,
            color: numColor,
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
