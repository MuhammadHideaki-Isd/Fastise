import 'dart:math' as math;

import 'package:flutter/material.dart';

class HexagonFastingRing extends StatelessWidget {
  const HexagonFastingRing({
    super.key,
    required this.progress,
    required this.semanticLabel,
    required this.child,
    required this.maxSize,
  });

  final double progress;
  final String semanticLabel;
  final Widget child;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.clamp(0.0, maxSize);
        final normalizedProgress = progress.isFinite
            ? progress.clamp(0.0, 1.0).toDouble()
            : 0.0;

        return Semantics(
          label: semanticLabel,
          child: SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _HexagonRingPainter(progress: normalizedProgress),
              child: Padding(
                padding: EdgeInsets.all(size * 0.12),
                child: Center(child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HexagonRingPainter extends CustomPainter {
  const _HexagonRingPainter({required this.progress});

  final double progress;

  static const _segmentColors = [
    Color(0xFF32B77A),
    Color(0xFF4387E9),
    Color(0xFF7369D8),
    Color(0xFFE9B92A),
    Color(0xFFF18B38),
    Color(0xFFE86C55),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.shortestSide * 0.045;
    final radius = size.shortestSide / 2 - strokeWidth;
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();

    for (var index = 0; index < 6; index++) {
      final angle = -math.pi / 2 + index * math.pi / 3;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final metric = path.computeMetrics().first;
    final segmentLength = metric.length / _segmentColors.length;
    final gap = strokeWidth * 1.35;
    final progressEnd = metric.length * progress;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < _segmentColors.length; index++) {
      final segmentStart = index * segmentLength;
      final drawStart = segmentStart + gap / 2;
      final drawEnd = segmentStart + segmentLength - gap / 2;
      final color = _segmentColors[index];

      trackPaint.color = color.withValues(alpha: 0.16);
      canvas.drawPath(metric.extractPath(drawStart, drawEnd), trackPaint);

      final activeEnd = math.min(drawEnd, progressEnd);
      if (activeEnd > drawStart) {
        trackPaint.color = color;
        canvas.drawPath(metric.extractPath(drawStart, activeEnd), trackPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HexagonRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
