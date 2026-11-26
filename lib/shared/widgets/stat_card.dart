import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.useWarmAccent = false,
  });

  final String value;
  final String label;
  final IconData? icon;
  final bool useWarmAccent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = useWarmAccent ? AppColors.accentWarm : AppColors.primary;
    final accentSoft = useWarmAccent
        ? AppColors.accentWarmSoft
        : AppColors.primarySoft;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: const Alignment(0.75, 0.95),
          stops: const [0.0, 0.48, 1.0],
          colors: [
            AppColors.surfaceTint(accent, 0.16),
            AppColors.surfaceTint(accent, 0.05),
            AppColors.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentSoft,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Icon(icon, size: 17, color: accent),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: AppColors.fontDisplay,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
