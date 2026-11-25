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
        ? AppColors.warningSoft
        : (isActive ? AppColors.primarySoft : AppColors.surfaceSubtle);
    final badgeFg = isTargetReached
        ? AppColors.primaryDark
        : (isActive ? AppColors.primaryDark : AppColors.textSecondary);
    final dotColor = isTargetReached
        ? AppColors.warning
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return CustomPaint(
                  painter: _FastingRingPainter(
                    progress: animatedProgress,
                    isActive: isActive,
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(999),
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
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        timeText,
                        style: textTheme.displaySmall?.copyWith(
                          color: isActive
                              ? AppColors.primaryDark
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
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
                          color: AppColors.textSecondary,
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
  const _FastingRingPainter({required this.progress, required this.isActive});

  final double progress;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 13.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Calm inner dial fill
    final dialPaint = Paint()
      ..color = isActive
          ? AppColors.primarySoft.withValues(alpha: 0.28)
          : AppColors.background.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth * 0.85, dialPaint);

    // Base ring track
    final trackPaint = Paint()
      ..color = AppColors.primarySoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Subtle quarter milestone ticks
    final tickPaint = Paint()
      ..color = AppColors.primaryMuted
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 2);
      final inner = Offset(
        center.dx + (radius - strokeWidth * 0.75) * math.cos(angle),
        center.dy + (radius - strokeWidth * 0.75) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (radius - strokeWidth * 0.55) * math.cos(angle),
        center.dy + (radius - strokeWidth * 0.55) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, -math.pi / 2, sweepAngle, false, progressPaint);

    // Crisp white center dot on the active tip of the arc
    final endAngle = -math.pi / 2 + sweepAngle;
    final tipCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    canvas.drawCircle(tipCenter, 3.2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _FastingRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isActive != isActive;
  }
}
