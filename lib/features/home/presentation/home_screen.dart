import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/domain/fasting_plan.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../fasting/domain/fasting_timer.dart';
import '../../progress/domain/progress_summary.dart';
import 'widgets/hexagon_fasting_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.selectedPlan,
    required this.onSelectPlan,
    required this.onOpenProfile,
    this.activeSession,
    required this.onStart,
    required this.onEnd,
    required this.completedSessions,
    this.isBusy = false,
    this.clock,
  });

  final FastingPlan selectedPlan;
  final VoidCallback onSelectPlan;
  final VoidCallback onOpenProfile;
  final FastingSession? activeSession;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final List<FastingSession> completedSessions;
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
    final progressSummary = ProgressSummary.calculate(
      sessions: widget.completedSessions,
      now: now,
    );
    final recentSessions = widget.completedSessions.toList()
      ..sort((first, second) => second.endAt!.compareTo(first.endAt!));
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);

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
                    IconButton(
                      tooltip: 'Profile',
                      onPressed: widget.onOpenProfile,
                      icon: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.12,
                        ),
                        child: const Icon(
                          PhosphorIconsRegular.userCircle,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activeSession == null
                                    ? 'Not fasting'
                                    : 'Fasting',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                activeSession?.planNameSnapshot ??
                                    widget.selectedPlan.label,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        HexagonFastingRing(
                              progress: timerSnapshot?.progress ?? 0,
                              semanticLabel:
                                  '${((timerSnapshot?.progress ?? 0) * 100).round()}% of the fasting target complete',
                              maxSize: MediaQuery.sizeOf(context).height < 700
                                  ? 220
                                  : 280,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    activeSession == null
                                        ? 'Ready to begin'
                                        : 'Fasting for',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 7),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      timerSnapshot?.elapsedLabel ?? '00:00:00',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    activeSession == null
                                        ? '${widget.selectedPlan.fastingHours}h target'
                                        : 'remaining ${_compactDuration(timerSnapshot!.remaining)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${((timerSnapshot?.progress ?? 0) * 100).round()}% complete',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.96, 0.96),
                              duration: 400.ms,
                            ),
                        const SizedBox(height: 16),
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
                        if (activeSession != null) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _SessionTime(
                                  label: 'STARTED',
                                  time: DateFormat(
                                    'HH:mm',
                                  ).format(activeSession.startAt),
                                ),
                              ),
                              Expanded(
                                child: _SessionTime(
                                  label: 'TARGET',
                                  time: DateFormat('HH:mm').format(
                                    activeSession.startAt.add(
                                      Duration(
                                        minutes: activeSession
                                            .plannedDurationMinutes,
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
                      child: Icon(
                        PhosphorIconsRegular.clock,
                        color: AppColors.primary,
                      ),
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
                    trailing: const Icon(PhosphorIconsRegular.caretRight),
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
                  children: [
                    Expanded(
                      child: _StatCard(
                        value: progressSummary.weeklySessionCount.toString(),
                        label: 'Sessions',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: progressSummary.weeklyAverageDuration == null
                            ? '—'
                            : _compactDuration(
                                progressSummary.weeklyAverageDuration!,
                              ),
                        label: 'Avg. duration',
                      ),
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
                  child: recentSessions.isEmpty
                      ? Padding(
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
                                  PhosphorIconsRegular.clockCounterClockwise,
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
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Completed sessions will appear here.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            for (
                              var index = 0;
                              index < recentSessions.length.clamp(0, 3);
                              index++
                            ) ...[
                              if (index > 0) const Divider(height: 1),
                              _RecentSessionTile(
                                session: recentSessions[index],
                              ),
                            ],
                          ],
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _compactDuration(Duration duration) {
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
}

class _SessionTime extends StatelessWidget {
  const _SessionTime({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _RecentSessionTile extends StatelessWidget {
  const _RecentSessionTile({required this.session});

  final FastingSession session;

  @override
  Widget build(BuildContext context) {
    final endAt = session.endAt!;
    final time = TimeOfDay.fromDateTime(endAt).format(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8F0EB),
        child: Icon(PhosphorIconsRegular.check, color: AppColors.primary),
      ),
      title: Text(session.planNameSnapshot),
      subtitle: Text('${endAt.day}/${endAt.month}/${endAt.year} · $time'),
      trailing: Text(
        FastingTimerSnapshot.formatDuration(
          Duration(seconds: session.actualDurationSeconds!),
        ),
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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
