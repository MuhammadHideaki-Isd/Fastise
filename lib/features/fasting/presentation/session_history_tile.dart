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
    final start = session.startAt;
    final end = session.endAt ?? start;
    final actual = Duration(
      seconds: session.actualDurationSeconds ?? end.difference(start).inSeconds,
    );
    final range = '${formatTime(start)} – ${formatTime(end)}';
    final subtitle = [
      if (showDate) formatDate(start),
      range,
      session.planNameSnapshot,
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => showSessionDetailSheet(context, session),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Icon(Icons.check, color: AppColors.primary),
        ),
        title: Text(
          formatDuration(actual),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
