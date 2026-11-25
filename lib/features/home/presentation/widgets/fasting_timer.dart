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
  });

  final String statusLabel;
  final String timeText;

  /// 0..1
  final double progress;
  final String caption;

  static const double _size = 208;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$statusLabel, $timeText, ${(progress * 100).round()}% of target',
      excludeSemantics: true,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.primarySoft,
                color: AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusLabel,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timeText,
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
