import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../domain/fasting_session.dart';

Future<void> showSessionDetailSheet(
  BuildContext context,
  FastingSession session,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.32),
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Session details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: AppColors.fontDisplay,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SessionDetails(session: session),
          ],
        ),
      ),
    ),
  );
}

/// Neutral facts about a completed session (no success/failure labels).
class SessionDetails extends StatelessWidget {
  const SessionDetails({super.key, required this.session});

  final FastingSession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final start = session.startAt;
    final end = session.endAt ?? session.startAt;
    final actual = session.actualDuration;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.32),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Duration',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryBright,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  formatDuration(actual),
                  textAlign: TextAlign.end,
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: AppColors.fontDisplay,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _Row('Plan', session.planNameSnapshot),
        const Divider(),
        _Row('Started', '${formatDate(start)} · ${formatTime(start)}'),
        const Divider(),
        _Row('Ended', '${formatDate(end)} · ${formatTime(end)}'),
        const Divider(),
        _Row('Planned target', formatDuration(session.plannedDuration)),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontFamily: AppColors.fontDisplay,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
