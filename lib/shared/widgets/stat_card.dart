import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Bento stat card modeled after the 3-card Daily Nutrition row in the reference:
/// circular tinted icon badge top-left with a smooth diagonal corner glow,
/// label in the middle, bold Sora metric value, and optional sublabel below.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.sublabel,
    this.icon,
    this.useWarmAccent = false,
    this.compact = false,
  });

  final String value;
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool useWarmAccent;
  final bool compact;

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: const Alignment(0.75, 0.95),
          stops: const [0.0, 0.48, 1.0],
          colors: [
            AppColors.surfaceTint(accent, 0.18),
            AppColors.surfaceTint(accent, 0.05),
            AppColors.surface,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                width: compact ? 30 : 34,
                height: compact ? 30 : 34,
                decoration: BoxDecoration(
                  color: accentSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.32)),
                ),
                child: Icon(icon, size: compact ? 15 : 17, color: accent),
              ),
              SizedBox(height: compact ? 10 : 12),
            ],
            if (compact)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style:
                    (compact
                            ? textTheme.titleLarge
                            : textTheme.headlineSmall)
                        ?.copyWith(
                          fontFamily: AppColors.fontDisplay,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
              ),
            ),
            if (sublabel != null) ...[
              const SizedBox(height: 2),
              Text(
                sublabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
