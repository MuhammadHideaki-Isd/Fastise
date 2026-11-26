import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Display-only timer ring. The caller supplies already-computed values;
/// timestamp-based calculation belongs to the session logic (Task 6).
class FastingTimer extends StatelessWidget {
  const FastingTimer({
    super.key,
    required this.statusLabel,
    required this.timeText,
    required this.progress,
    required this.caption,
    this.isActive = false,
    this.isTargetReached = false,
  });

  final String statusLabel;
  final String timeText;

  /// 0..1
  final double progress;
  final String caption;
  final bool isActive;
  final bool isTargetReached;

  static const double _size = 196;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clamped = progress.clamp(0.0, 1.0);
    final badgeBg = isTargetReached
        ? AppColors.accentWarmSoft
        : (isActive ? AppColors.primarySoft : AppColors.surfaceElevated);
    final badgeBorder = isTargetReached
        ? AppColors.accentWarm.withValues(alpha: 0.40)
        : (isActive
              ? AppColors.primary.withValues(alpha: 0.38)
              : AppColors.border);
    final badgeFg = isTargetReached
        ? AppColors.accentWarm
        : (isActive ? AppColors.primaryBright : AppColors.textSecondary);
    final dotColor = isTargetReached
        ? AppColors.accentWarm
        : (isActive ? AppColors.primary : AppColors.textSecondary);

    return Semantics(
      label: '$statusLabel, $timeText, ${(clamped * 100).round()}% of target',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ringSize = math.min(_size, constraints.maxWidth);
          return SizedBox(
            width: ringSize,
            height: ringSize,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: clamped),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return CustomPaint(
                  painter: _FastingRingPainter(
                    progress: animatedProgress,
                    isActive: isActive,
                    isTargetReached: isTargetReached,
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: badgeBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: dotColor.withValues(alpha: 0.65),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                statusLabel,
                                style: textTheme.labelMedium?.copyWith(
                                  color: badgeFg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        timeText,
                        style: textTheme.displaySmall?.copyWith(
                          fontFamily: AppColors.fontDisplay,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        caption,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: isTargetReached
                              ? AppColors.accentWarm
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FastingRingPainter extends CustomPainter {
  const _FastingRingPainter({
    required this.progress,
    required this.isActive,
    required this.isTargetReached,
  });

  final double progress;
  final bool isActive;
  final bool isTargetReached;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth - 6) / 2;
    final innerRadius = radius - strokeWidth * 0.9;

    // Subtle recessed dark inner dial with ambient glow
    final innerAccent = isTargetReached
        ? AppColors.accentWarm
        : AppColors.primary;
    final dialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isActive
              ? innerAccent.withValues(alpha: 0.12)
              : AppColors.surfaceElevated.withValues(alpha: 0.55),
          AppColors.surfaceSubtle.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: innerRadius));
    canvas.drawCircle(center, innerRadius, dialPaint);

    // Base ring track
    final trackPaint = Paint()
      ..color = const Color(0xFF242B27)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // 24 precision hour ticks inside the track (quarter milestones highlighted)
    for (var i = 0; i < 24; i++) {
      final isQuarter = i % 6 == 0;
      final angle = -math.pi / 2 + (i * 2 * math.pi / 24);
      final innerOffset = radius - strokeWidth * (isQuarter ? 0.98 : 0.92);
      final outerOffset = radius - strokeWidth * 0.72;
      final p1 = Offset(
        center.dx + innerOffset * math.cos(angle),
        center.dy + innerOffset * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerOffset * math.cos(angle),
        center.dy + outerOffset * math.sin(angle),
      );
      final tickPaint = Paint()
        ..color = isQuarter
            ? AppColors.primaryMuted.withValues(alpha: 0.95)
            : AppColors.border.withValues(alpha: 0.75)
        ..strokeWidth = isQuarter ? 2.0 : 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, tickPaint);
    }

    if (progress <= 0) return;

    final clamped = progress.clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * clamped;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final startColor = AppColors.primaryDark;
    final endColor = isTargetReached
        ? AppColors.accentWarm
        : AppColors.primaryBright;
    final glowColor = isTargetReached
        ? AppColors.accentWarm
        : AppColors.primary;

    // Soft outer halo behind the active progress arc
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(arcRect, -math.pi / 2, sweepAngle, false, glowPaint);

    // Seamless gradient progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          startColor,
          AppColors.primary,
          endColor,
          startColor,
        ],
        stops: const [0.0, 0.45, 0.96, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, -math.pi / 2, sweepAngle, false, progressPaint);

    // Clean start cap to mask any SweepGradient wrap seam
    if (clamped < 0.98) {
      final startCapCenter = Offset(center.dx, center.dy - radius);
      canvas.drawCircle(
        startCapCenter,
        strokeWidth / 2,
        Paint()..color = startColor,
      );
    }

    // Glowing indicator jewel at the leading tip of the arc
    final endAngle = -math.pi / 2 + sweepAngle;
    final tipCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    canvas.drawCircle(tipCenter, strokeWidth / 2, Paint()..color = endColor);
    canvas.drawCircle(tipCenter, 3.4, Paint()..color = AppColors.onPrimary);
  }

  @override
  bool shouldRepaint(covariant _FastingRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isTargetReached != isTargetReached;
  }
}
