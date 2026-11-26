import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/domain/fasting_session.dart';
import '../domain/progress_summary.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.sessions, this.now});

  final List<FastingSession> sessions;
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = ProgressSummary.calculate(
      sessions: sessions,
      now: now?.call() ?? DateTime.now(),
    );

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Progress',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A summary based on your completed sessions.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ALL TIME',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        value: summary.completedSessionCount.toString(),
                        label: 'Sessions',
                        icon: PhosphorIconsRegular.checkCircle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        value: _formatDuration(summary.totalDuration),
                        label: 'Total fasting',
                        icon: PhosphorIconsRegular.clock,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MetricCard(
                  value: summary.averageDuration == null
                      ? '—'
                      : _formatDuration(summary.averageDuration!),
                  label: 'Average session duration',
                  icon: PhosphorIconsRegular.timer,
                ),
                const SizedBox(height: 28),
                Text(
                  'THIS WEEK',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatWeekRange(summary.weekStart),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                _WeeklyChart(progress: summary.weeklyProgress),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalMinutes = duration.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (totalMinutes == 0 && duration.inSeconds > 0) {
      return '${duration.inSeconds}s';
    }
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String _formatWeekRange(DateTime start) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final end = DateTime(start.year, start.month, start.day + 6);

    if (start.month == end.month && start.year == end.year) {
      return '${start.day}–${end.day} ${months[start.month - 1]} ${start.year}';
    }
    if (start.year == end.year) {
      return '${start.day} ${months[start.month - 1]} – '
          '${end.day} ${months[end.month - 1]} ${end.year}';
    }
    return '${start.day} ${months[start.month - 1]} ${start.year} – '
        '${end.day} ${months[end.month - 1]} ${end.year}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.progress});

  final List<DailyProgress> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxSeconds = progress.fold<int>(
      0,
      (max, day) => day.totalSeconds > max ? day.totalSeconds : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: maxSeconds == 0
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Center(
                  child: Text(
                    'No completed sessions this week.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  for (var index = 0; index < progress.length; index++) ...[
                    if (index > 0) const SizedBox(height: 14),
                    _DayBar(day: progress[index], maxSeconds: maxSeconds),
                  ],
                ],
              ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.day, required this.maxSeconds});

  final DailyProgress day;
  final int maxSeconds;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final theme = Theme.of(context);
    final fraction = day.totalSeconds / maxSeconds;
    final hours = day.totalSeconds / Duration.secondsPerHour;

    return Semantics(
      label:
          '${weekdays[day.date.weekday - 1]}: ${hours.toStringAsFixed(1)} hours',
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              weekdays[day.date.weekday - 1],
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            child: Text(
              '${hours.toStringAsFixed(1)}h',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
