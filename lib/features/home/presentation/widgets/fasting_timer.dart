import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Display-only timer ring modeled after the multi-segment glowing ring
/// in the reference design. All values are computed externally from timestamps.
class FastingTimer extends StatelessWidget {
  const FastingTimer({
    super.key,
    required this.statusLabel,
    required this.timeText,
    required this.progress,
    required this.caption,
    this.isActive = false,
    this.isTargetReached = false,
    this.maxSize = 178,
  });

  final String statusLabel;
  final String timeText;

  /// 0..1
  final double progress;
  final String caption;
  final bool isActive;
  final bool isTargetReached;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final clamped = progress.clamp(0.0, 1.0);
    final badgeBg = isTargetReached
        ? AppColors.accentWarmSoft
        : (isActive ? AppColors.surfaceElevated : AppColors.surfaceElevated);
    final badgeBorder = isTargetReached
        ? AppColors.accentWarm.withValues(alpha: 0.42)
        : (isActive
              ? AppColors.primary.withValues(alpha: 0.42)
              : AppColors.borderHighlight);
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
          final ringSize = math.min(maxSize, constraints.maxWidth);
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
                        horizontal: 9,
                        vertical: 3.5,
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
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                statusLabel,
                                style: textTheme.labelSmall?.copyWith(
                                  color: badgeFg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        timeText,
                        style: textTheme.headlineMedium?.copyWith(
                          fontFamily: AppColors.fontDisplay,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.9,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
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

/// Vertical segmented equalizer-bar metric row modeled after the right column
/// next to the ring in the reference Nutrition screen.
class EqualizerMetricRow extends StatelessWidget {
  const EqualizerMetricRow({
    super.key,
    required this.value,
    required this.label,
    required this.fillRatio,
    this.accent = AppColors.primary,
  });

  final String value;
  final String label;

  /// 0..1 fraction of vertical bars illuminated.
  final double fillRatio;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const totalBars = 7;
    final litBars = (fillRatio.clamp(0.0, 1.0) * totalBars).round();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = totalBars - 1; i >= 0; i--) ...[
              Container(
                width: 11,
                height: 2.6,
                decoration: BoxDecoration(
                  color: i < litBars
                      ? accent
                      : AppColors.border.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              if (i != 0) const SizedBox(height: 2),
            ],
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: AppColors.fontDisplay,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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
    const strokeWidth = 12.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth - 6) / 2;

    // Subtle recessed inner dark circle
    final innerAccent = isTargetReached
        ? AppColors.accentWarm
        : AppColors.primary;
    final dialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isActive
              ? innerAccent.withValues(alpha: 0.10)
              : AppColors.surfaceElevated.withValues(alpha: 0.35),
          AppColors.background.withValues(alpha: 0.70),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 6));
    canvas.drawCircle(center, radius - strokeWidth * 0.6, dialPaint);

    // Base thick dark track matching the reference gauge
    final trackPaint = Paint()
      ..color = const Color(0xFF282E2B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Subtle decorative dual-tone resting segments when idle so the ring
    // feels rich like the segmented reference gauge even before starting.
    if (!isActive || progress <= 0) {
      final sageHint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, -math.pi * 0.42, math.pi * 0.38, false, sageHint);

      final sandHint = Paint()
        ..color = AppColors.accentWarm.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(arcRect, math.pi * 0.28, math.pi * 0.34, false, sandHint);
      return;
    }

    final clamped = progress.clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * clamped;

    // Companion subtle Warm Sand accent segment on the remaining tail
    if (clamped < 0.85) {
      final tailStart = -math.pi / 2 + sweepAngle + 0.16;
      final tailSweep = math.min(0.45, (2 * math.pi - sweepAngle) - 0.32);
      if (tailSweep > 0.08) {
        final tailPaint = Paint()
          ..color = AppColors.accentWarm.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(arcRect, tailStart, tailSweep, false, tailPaint);
      }
    }

    final startColor = AppColors.primaryDark;
    final endColor = isTargetReached
        ? AppColors.accentWarm
        : AppColors.primaryBright;
    final glowColor = isTargetReached
        ? AppColors.accentWarm
        : AppColors.primary;

    // Soft outer glow behind the active arc
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(arcRect, -math.pi / 2, sweepAngle, false, glowPaint);

    // Seamless gradient progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [startColor, AppColors.primary, endColor, startColor],
        stops: const [0.0, 0.45, 0.96, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, -math.pi / 2, sweepAngle, false, progressPaint);

    if (clamped < 0.98) {
      canvas.drawCircle(
        Offset(center.dx, center.dy - radius),
        strokeWidth / 2,
        Paint()..color = startColor,
      );
    }

    // Crisp leading tip jewel
    final endAngle = -math.pi / 2 + sweepAngle;
    final tipCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    canvas.drawCircle(tipCenter, strokeWidth / 2, Paint()..color = endColor);
    canvas.drawCircle(tipCenter, 3.0, Paint()..color = AppColors.onPrimary);
  }

  @override
  bool shouldRepaint(covariant _FastingRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isTargetReached != isTargetReached;
  }
}
