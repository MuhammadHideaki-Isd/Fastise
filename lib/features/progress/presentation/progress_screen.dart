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
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                'Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Consistency and duration from your completed fasts.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              SegmentedButton<int>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 days')),
                  ButtonSegment(value: 30, label: Text('30 days')),
                ],
                selected: {_days},
                onSelectionChanged: (s) => setState(() => _days = s.first),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${formatDate(since)} – ${formatDate(now)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (stats.count == 0)
                const EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'Not enough data yet',
                  message: 'Finish a fast and your totals will show up here.',
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        value: '${stats.count}',
                        label: 'Sessions',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.schedule_rounded,
                        value: _hours(stats.total),
                        label: 'Total fasting',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  icon: Icons.timelapse_rounded,
                  value: formatDuration(stats.average!),
                  label: 'Average session',
                ),
                const SizedBox(height: 26),
                Text(
                  'FASTING TIME PER DAY',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                _BarChart(totals: totals, today: now, showLabels: _days <= 7),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _hours(Duration d) =>
      '${(d.inMinutes / 60).toStringAsFixed(1)} h';
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.totals,
    required this.today,
    required this.showLabels,
  });

  final List<({DateTime day, Duration total})> totals;
  final DateTime today;
  final bool showLabels;

  static const _height = 148.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final max = totals.fold<int>(
      0,
      (m, t) => t.total.inSeconds > m ? t.total.inSeconds : m,
    );
    final activeDays = totals.where((t) => t.total > Duration.zero).length;
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$activeDays of ${totals.length} days logged',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (max > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Peak ${(max / 3600).toStringAsFixed(0)}h',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: _height,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(height: 1, color: AppColors.surfaceSubtle),
                        Container(height: 1, color: AppColors.surfaceSubtle),
                        Container(height: 1, color: AppColors.border),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final t in totals)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: showLabels ? 5 : 1.2,
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: t.total == Duration.zero || max == 0
                                        ? 4
                                        : (_height * t.total.inSeconds / max)
                                              .clamp(8.0, _height),
                                  ),
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, barHeight, _) {
                                    final isToday = isSameDay(t.day, today);
                                    return Container(
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        color: t.total == Duration.zero
                                            ? AppColors.border
                                            : (isToday
                                                  ? AppColors.primaryDark
                                                  : AppColors.primary),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(6),
                                              bottom: Radius.circular(2),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showLabels) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final t in totals)
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              formatDate(t.day).substring(0, 3),
                              textAlign: TextAlign.center,
                              style: textTheme.labelSmall?.copyWith(
                                color: isSameDay(t.day, today)
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                                fontWeight: isSameDay(t.day, today)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
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
