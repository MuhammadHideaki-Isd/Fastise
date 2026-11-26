import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../domain/fasting_session.dart';
import 'session_details.dart';

/// One completed session. Tapping opens its details.
class SessionHistoryTile extends StatelessWidget {
  const SessionHistoryTile({
    super.key,
    required this.session,
    this.showDate = false,
  });

  final FastingSession session;

  /// Include the date in the subtitle (used where no date header exists).
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = session.startAt;
    final end = session.endAt ?? start;
    final actual = session.actualDuration;
    final plannedSeconds = session.plannedDuration.inSeconds;
    final ratio = plannedSeconds <= 0
        ? 0.0
        : (actual.inSeconds / plannedSeconds).clamp(0.0, 1.0);
    final reachedGoal = plannedSeconds > 0 && actual.inSeconds >= plannedSeconds;
    final accent = reachedGoal ? AppColors.accentWarm : AppColors.primary;
    final accentSoft = reachedGoal
        ? AppColors.accentWarmSoft
        : AppColors.primarySoft;

    final range = '${formatTime(start)} – ${formatTime(end)}';
    final subtitle = [if (showDate) formatDate(start), range].join(' · ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: const Alignment(0.65, 1.0),
          stops: const [0.0, 0.42, 1.0],
          colors: [
            AppColors.surfaceTint(accent, 0.14),
            AppColors.surfaceTint(accent, 0.04),
            AppColors.surface,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showSessionDetailSheet(context, session),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentSoft,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: accent.withValues(alpha: 0.30)),
                  ),
                  child: Icon(
                    Icons.task_alt_rounded,
                    size: 20,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            formatDuration(actual),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: AppColors.fontDisplay,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              session.planNameSnapshot,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryBright,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 4.5,
                          backgroundColor: AppColors.surfaceSubtle,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
