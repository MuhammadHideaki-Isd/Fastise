import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../fasting/application/fasting_scope.dart';
import '../../fasting/domain/fasting_stats.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    final controller = FastingScope.of(context);
    final theme = Theme.of(context);
    final now = controller.now();
    final since = startOfLastDays(now, _days);
    final inRange = sessionsSince(controller.sessions, since);
    final stats = statsFor(inRange);
    final totals = dailyTotals(inRange, now, _days);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Progress',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 7, label: Text('7 days')),
              ButtonSegment(value: 30, label: Text('30 days')),
            ],
            selected: {_days},
            onSelectionChanged: (s) => setState(() => _days = s.first),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatDate(since)} – ${formatDate(now)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          if (stats.count == 0)
            const EmptyState(
              icon: Icons.insights_outlined,
              title: 'Not enough data yet',
              message: 'Finish a fast and your totals will show up here.',
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: StatCard(value: '${stats.count}', label: 'Sessions'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: _hours(stats.total),
                    label: 'Total fasting',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StatCard(
              value: formatDuration(stats.average!),
              label: 'Average session',
            ),
            const SizedBox(height: 24),
            Text(
              'FASTING TIME PER DAY',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            _BarChart(totals: totals, showLabels: _days <= 7),
          ],
        ],
      ),
    );
  }

  static String _hours(Duration d) =>
      '${(d.inMinutes / 60).toStringAsFixed(1)} h';
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.totals, required this.showLabels});

  final List<({DateTime day, Duration total})> totals;
  final bool showLabels;

  static const _height = 140.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final max = totals.fold<int>(
      0,
      (m, t) => t.total.inSeconds > m ? t.total.inSeconds : m,
    );
    final summary = [
      for (final t in totals)
        if (t.total > Duration.zero)
          '${formatDate(t.day)}: ${formatDuration(t.total)}',
    ].join(', ');

    return Semantics(
      label: 'Fasting time per day. $summary',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: _height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final t in totals)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: showLabels ? 6 : 1,
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: t.total == Duration.zero || max == 0
                                  ? 3
                                  : (_height * t.total.inSeconds / max).clamp(
                                      6.0,
                                      _height,
                                    ),
                              decoration: BoxDecoration(
                                color: t.total == Duration.zero
                                    ? AppColors.border
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (showLabels) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final t in totals)
                      Expanded(
                        child: Text(
                          formatDate(t.day).substring(0, 1),
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
