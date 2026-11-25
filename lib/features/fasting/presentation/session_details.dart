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
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
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
    final start = session.startAt;
    final end = session.endAt ?? session.startAt;
    final actual = Duration(
      seconds: session.actualDurationSeconds ?? end.difference(start).inSeconds,
    );
    return Column(
      children: [
        _Row('Plan', session.planNameSnapshot),
        _Row('Started', '${formatDate(start)} · ${formatTime(start)}'),
        _Row('Ended', '${formatDate(end)} · ${formatTime(end)}'),
        _Row('Duration', formatDuration(actual)),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
