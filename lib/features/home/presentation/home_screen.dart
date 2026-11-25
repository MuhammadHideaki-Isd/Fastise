import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/domain/fasting_plan.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../fasting/domain/fasting_timer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.selectedPlan,
    required this.onSelectPlan,
    this.activeSession,
    required this.onStart,
    required this.onEnd,
    this.isBusy = false,
    this.clock,
  });

  final FastingPlan selectedPlan;
  final VoidCallback onSelectPlan;
  final FastingSession? activeSession;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final bool isBusy;
  final DateTime Function()? clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSession?.id != widget.activeSession?.id) {
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    _timer?.cancel();
    if (widget.activeSession != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = widget.clock?.call() ?? DateTime.now();
    final activeSession = widget.activeSession;
    final timerSnapshot = activeSession == null
        ? null
        : FastingTimer.calculate(activeSession, now);
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
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
    final dateLabel =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';

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
                            'Good morning',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateLabel,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'CURRENT STATUS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          activeSession == null ? 'Not fasting' : 'Fasting',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 190,
                          height: 190,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 190,
                                height: 190,
                                child: CircularProgressIndicator(
                                  value: timerSnapshot?.progress ?? 0,
                                  strokeWidth: 10,
                                  backgroundColor: AppColors.border,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timerSnapshot?.elapsedLabel ?? '00:00:00',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${((timerSnapshot?.progress ?? 0) * 100).round()}% complete',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timerSnapshot?.targetReached == true
                              ? 'Target reached'
                              : activeSession == null
                              ? 'Ready when you are'
                              : 'Keep going',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: widget.isBusy
                                ? null
                                : activeSession == null
                                ? widget.onStart
                                : widget.onEnd,
                            child: widget.isBusy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    activeSession == null
                                        ? 'Start fasting'
                                        : 'End fasting',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'YOUR PLAN',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F0EB),
                      child: Icon(Icons.schedule, color: AppColors.primary),
                    ),
                    title: Text(
                      '${activeSession?.planNameSnapshot ?? widget.selectedPlan.label} '
                      'Intermittent fasting',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      activeSession == null
                          ? '${widget.selectedPlan.fastingHours} hours fasting · '
                                '${widget.selectedPlan.eatingHours} hours eating'
                          : '${activeSession.planNameSnapshot.split(':').first} hours fasting · '
                                '${activeSession.planNameSnapshot.split(':').last} hours eating',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: activeSession == null ? widget.onSelectPlan : null,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'THIS WEEK',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(
                      child: _StatCard(value: '0', label: 'Sessions'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(value: '—', label: 'Avg. duration'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'RECENT ACTIVITY',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F0EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.history,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No recent sessions',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completed sessions will appear here.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
