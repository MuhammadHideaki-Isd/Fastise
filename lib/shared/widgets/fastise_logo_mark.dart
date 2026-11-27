import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Vector brand mark matching the open-top stopwatch ring & tilted hand
/// app icon, styled in the Obsidian & Soft Sage Mint palette.
class FastiseLogoMark extends StatelessWidget {
  const FastiseLogoMark({
    super.key,
    this.size = 84,
    this.sweepProgress = 1.0,
    this.showBadgeContainer = true,
  });

  final double size;
  final double sweepProgress;
  final bool showBadgeContainer;

  @override
  Widget build(BuildContext context) {
    final mark = CustomPaint(
      size: Size.square(showBadgeContainer ? size * 0.56 : size),
      painter: _FastiseMarkPainter(
        sweepProgress: sweepProgress.clamp(0.0, 1.0),
      ),
    );

    if (!showBadgeContainer) return mark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        color: AppColors.surfaceElevated,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceTint(
              AppColors.primary,
              0.22,
              AppColors.surfaceElevated,
            ),
            AppColors.surface,
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.42),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: mark),
    );
  }
}

class _FastiseMarkPainter extends CustomPainter {
  const _FastiseMarkPainter({required this.sweepProgress});

  final double sweepProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    final radius = size.width * 0.37;
    final strokeWidth = size.width * 0.135;

    // Open top gap from -116 deg to -64 deg (sweep 308 deg around bottom)
    const startAngle = -math.pi * 0.34;
    const totalSweep = math.pi * 1.68;

    final trackPaint = Paint()
      ..color = AppColors.primaryMuted.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      trackPaint,
    );

    if (sweepProgress > 0) {
      final arcRect = Rect.fromCircle(center: center, radius: radius);
      final arcPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBright, AppColors.primary],
        ).createShader(arcRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        arcRect,
        startAngle,
        totalSweep * sweepProgress,
        false,
        arcPaint,
      );
    }

    // Two crisp endpoint dots flanking the top opening
    final dotRadius = strokeWidth * 0.44;
    final rightAngle = startAngle;
    final leftAngle = startAngle + totalSweep;
    final dotOffsets = [
      Offset(
        center.dx + (radius + strokeWidth * 0.52) * math.cos(rightAngle),
        center.dy + (radius + strokeWidth * 0.52) * math.sin(rightAngle),
      ),
      Offset(
        center.dx + (radius + strokeWidth * 0.52) * math.cos(leftAngle),
        center.dy + (radius + strokeWidth * 0.52) * math.sin(leftAngle),
      ),
    ];

    final dotPaint = Paint()..color = AppColors.accentWarm;
    for (final offset in dotOffsets) {
      canvas.drawCircle(offset, dotRadius, dotPaint);
    }

    // Center hub + clock hand pointing toward ~1:30
    final handAngle = -math.pi * 0.28;
    final handTip = Offset(
      center.dx + radius * 0.54 * math.cos(handAngle),
      center.dy + radius * 0.54 * math.sin(handAngle),
    );
    final handPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = strokeWidth * 0.62
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, handTip, handPaint);
    canvas.drawCircle(
      center,
      strokeWidth * 0.52,
      Paint()..color = AppColors.textPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant _FastiseMarkPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress;
  }
}
