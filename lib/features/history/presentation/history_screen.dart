import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../fasting/domain/fasting_timer.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.sessions});

  final List<FastingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedSessions =
        sessions
            .where(
              (session) => session.status == FastingSessionStatus.completed,
            )
            .toList()
          ..sort((first, second) => second.endAt!.compareTo(first.endAt!));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'History',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${completedSessions.length} completed '
              '${completedSessions.length == 1 ? 'session' : 'sessions'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: completedSessions.isEmpty
                  ? const _HistoryEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: completedSessions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) => _HistorySessionCard(
                        key: ValueKey(completedSessions[index].id),
                        session: completedSessions[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No completed sessions yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completed fasting sessions will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySessionCard extends StatelessWidget {
  const _HistorySessionCard({super.key, required this.session});

  final FastingSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final endAt = session.endAt!;
    final duration = Duration(seconds: session.actualDurationSeconds!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.planNameSnapshot,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(endAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FastingTimerSnapshot.formatDuration(duration),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'actual duration',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _SessionTime(
                  icon: Icons.play_circle_outline,
                  text: 'Start ${_formatTime(context, session.startAt)}',
                  style: theme.textTheme.bodySmall,
                ),
                _SessionTime(
                  icon: Icons.stop_circle_outlined,
                  text: 'End ${_formatTime(context, endAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _formatTime(BuildContext context, DateTime value) =>
      TimeOfDay.fromDateTime(value).format(context);
}

class _SessionTime extends StatelessWidget {
  const _SessionTime({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: style?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
