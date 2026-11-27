import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../features/widget/data/home_widget_sync.dart';

/// Expressive stopwatch mascot ("Fasty") drawn cleanly in vector canvas,
/// matching the native Android home screen widget drawables.
class FastyMascot extends StatelessWidget {
  const FastyMascot({
    super.key,
    required this.mood,
    this.size = 64,
  });

  final WidgetMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _FastyPainter(mood: mood),
    );
  }
}

class _FastyPainter extends CustomPainter {
  const _FastyPainter({required this.mood});

  final WidgetMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.56);
    final bodyRadius = w * 0.36;

    final ringColor = mood == WidgetMood.targetReached
        ? AppColors.accentWarm
        : AppColors.primary;
    final bodyColor = mood == WidgetMood.targetReached
        ? const Color(0xFF2B241A)
        : const Color(0xFF1E2D26);

    // Top stopwatch crown & button ears
    final earPaint = Paint()..color = ringColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.12),
          width: w * 0.18,
          height: h * 0.09,
        ),
        Radius.circular(w * 0.045),
      ),
      earPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.25, h * 0.23),
      w * 0.065,
      Paint()..color = AppColors.accentWarm,
    );
    canvas.drawCircle(
      Offset(w * 0.75, h * 0.23),
      w * 0.065,
      Paint()..color = AppColors.accentWarm,
    );

    // Outer glow & ring body
    canvas.drawCircle(
      center,
      bodyRadius + w * 0.04,
      Paint()..color = ringColor.withValues(alpha: 0.22),
    );
    canvas.drawCircle(center, bodyRadius, Paint()..color = bodyColor);
    canvas.drawCircle(
      center,
      bodyRadius,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075,
    );

    // Sporty focus headband when actively fasting
    if (mood == WidgetMood.fasting) {
      final bandRect = Rect.fromCircle(center: center, radius: bodyRadius * 0.88);
      final bandPaint = Paint()
        ..color = AppColors.accentWarm.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.065
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(bandRect, -math.pi * 0.84, math.pi * 0.68, false, bandPaint);
    }

    // Expressive eyes
    final leftEye = Offset(w * 0.39, h * 0.53);
    final rightEye = Offset(w * 0.61, h * 0.53);

    if (mood == WidgetMood.targetReached || mood == WidgetMood.doneToday) {
      // Happy upward curved eyes (^ ^)
      final eyeArc = Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round;
      for (final eyeCenter in [leftEye, rightEye]) {
        canvas.drawArc(
          Rect.fromCenter(center: eyeCenter, width: w * 0.12, height: h * 0.09),
          -math.pi * 0.9,
          math.pi * 0.8,
          false,
          eyeArc,
        );
      }
    } else {
      // Bright eyes with shine dots
      final eyePaint = Paint()..color = AppColors.textPrimary;
      final shinePaint = Paint()..color = ringColor;
      final eyeR = w * 0.056;
      for (final eyeCenter in [leftEye, rightEye]) {
        canvas.drawCircle(eyeCenter, eyeR, eyePaint);
        canvas.drawCircle(
          Offset(eyeCenter.dx - eyeR * 0.25, eyeCenter.dy - eyeR * 0.28),
          eyeR * 0.34,
          shinePaint,
        );
      }
      if (mood == WidgetMood.fasting) {
        // Determined little brow lines
        final browPaint = Paint()
          ..color = AppColors.textPrimary
          ..strokeWidth = w * 0.036
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(leftEye.dx - w * 0.05, leftEye.dy - h * 0.08),
          Offset(leftEye.dx + w * 0.04, leftEye.dy - h * 0.065),
          browPaint,
        );
        canvas.drawLine(
          Offset(rightEye.dx + w * 0.05, rightEye.dy - h * 0.08),
          Offset(rightEye.dx - w * 0.04, rightEye.dy - h * 0.065),
          browPaint,
        );
      }
    }

    // Cheek blush
    final blushColor = mood == WidgetMood.targetReached
        ? AppColors.accentWarm.withValues(alpha: 0.40)
        : AppColors.primary.withValues(alpha: 0.32);
    canvas.drawCircle(Offset(w * 0.31, h * 0.61), w * 0.04, Paint()..color = blushColor);
    canvas.drawCircle(Offset(w * 0.69, h * 0.61), w * 0.04, Paint()..color = blushColor);

    // Smile mouth
    final mouthPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.63),
        width: w * 0.16,
        height: mood == WidgetMood.targetReached ? h * 0.11 : h * 0.08,
      ),
      0.15 * math.pi,
      0.70 * math.pi,
      false,
      mouthPaint,
    );

    // Sparkles for goal reached
    if (mood == WidgetMood.targetReached) {
      final sparkle = Paint()..color = AppColors.accentWarm;
      canvas.drawCircle(Offset(w * 0.15, h * 0.38), w * 0.032, sparkle);
      canvas.drawCircle(Offset(w * 0.87, h * 0.36), w * 0.038, sparkle);
    }
  }

  @override
  bool shouldRepaint(covariant _FastyPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
