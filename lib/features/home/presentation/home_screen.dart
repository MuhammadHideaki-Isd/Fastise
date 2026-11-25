import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/stat_card.dart';
import 'widgets/fasting_timer.dart';

/// Static idle-state dashboard (Task 3). Plan, stats, and the Start CTA are
/// wired to real state in later tasks (4, 5, 6, 7).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onProfileTap});

  final VoidCallback onProfileTap;

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
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

  static String _greeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateText =
        '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]}';

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _greeting(now.hour),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Open profile',
                      onPressed: onProfileTap,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.person_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Static idle values; real timer arrives in Task 6.
                        const FastingTimer(
                          statusLabel: 'Not fasting',
                          timeText: '00:00:00',
                          progress: 0,
                          caption: 'Target 16 h',
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(
                          width: double.infinity,
                          height: 52,
                          // null = disabled: session start is Task 5/6.
                          child: FilledButton(
                            onPressed: null,
                            child: Text('Start Fasting'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('YOUR PLAN'),
                const SizedBox(height: 10),
                // Placeholder default plan until selection exists (Task 4).
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(Icons.schedule, color: AppColors.primary),
                    ),
                    title: Text(
                      '16:8',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text('16 h fasting · 8 h eating window'),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('THIS WEEK'),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: StatCard(value: '0', label: 'Sessions'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: StatCard(value: '—', label: 'Avg. duration'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('RECENT ACTIVITY'),
                const SizedBox(height: 10),
                const EmptyState(
                  icon: Icons.history,
                  title: 'No sessions yet',
                  message: 'Completed fasts will appear here.',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}
