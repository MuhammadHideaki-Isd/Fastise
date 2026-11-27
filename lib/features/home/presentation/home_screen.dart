import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fastise_logo_mark.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../fasting/application/fasting_scope.dart';
import '../../fasting/domain/fasting_stats.dart';
import '../../fasting/presentation/plan_selection_screen.dart';
import '../../fasting/presentation/session_history_tile.dart';
import 'widgets/fasting_hero_card.dart';
import 'widgets/week_strip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onProfileTap,
    this.onProgressTap,
  });

  final VoidCallback onProfileTap;
  final VoidCallback? onProgressTap;

  static String _greeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openPlanSelection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PlanSelectionScreen(),
      ),
    );
    if (mounted && _scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = FastingScope.of(context);
    final plan = controller.selectedPlan;
    final recent = controller.sessions.take(3).toList();
    final now = controller.now();
    final weekStart = startOfWeek(now);
    final weekSessions = sessionsSince(controller.sessions, weekStart);
    final weekStats = statsFor(weekSessions);
    final activeDaysThisWeek = dailyTotals(
      weekSessions,
      now,
      now.difference(weekStart).inDays + 1,
    ).where((d) => d.total > Duration.zero).length;
    final dateText = formatDate(now, full: true);

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header modeled after Screen 1 (Avatar + Greeting + Circular Action)
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.42),
                          width: 1.4,
                        ),
                      ),
                      child: const Center(
                        child: FastiseLogoMark(
                          size: 24,
                          showBadgeContainer: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateText,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            HomeScreen._greeting(now.hour),
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: AppColors.fontDisplay,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'Open profile',
                      onPressed: widget.onProfileTap,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderHighlight),
                      ),
                      icon: Badge(
                        isLabelVisible: controller.isFasting,
                        backgroundColor: AppColors.primary,
                        smallSize: 7,
                        child: const Icon(Icons.person_outline_rounded, size: 21),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Borderless top Week Calendar Strip (modeled after Screen 2 top)
                WeekStripCard(
                  now: now,
                  sessions: controller.sessions,
                  activeSession: controller.activeSession,
                  targetHours: plan.fastingHours,
                ),
                const SizedBox(height: 14),
                // Centerpiece Ring + 3 Equalizer Metric Bars + Pill CTA (Screen 2)
                const FastingHeroCard(),
                const SizedBox(height: 16),
                // Dual Split Highlight Cards (modeled after Screen 3 right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _HighlightFeatureCard(
                        streakLabel: 'Active Plan',
                        streakValue: plan.name,
                        cardTitle: "Today's\nPlan",
                        actionLabel: 'Edit Plan',
                        icon: Icons.schedule_rounded,
                        accent: AppColors.primary,
                        accentDark: AppColors.primaryDark,
                        onTap: _openPlanSelection,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HighlightFeatureCard(
                        streakLabel: 'Weekly Rhythm',
                        streakValue: '$activeDaysThisWeek active d',
                        cardTitle: 'Weekly\nSummary',
                        actionLabel: 'Daily Stats',
                        icon: Icons.insights_rounded,
                        accent: AppColors.accentWarm,
                        accentDark: const Color(0xFFB89260),
                        onTap: widget.onProgressTap ?? widget.onProfileTap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionLabel('THIS WEEK'),
                const SizedBox(height: 10),
                // 3-Column Bento Stat Triad (modeled after Screen 1 left)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                    final threeCol =
                        constraints.maxWidth >= 300 && textScale <= 1.3;
                    final sessionsCard = StatCard(
                      compact: threeCol,
                      icon: Icons.local_fire_department_outlined,
                      value: '${weekStats.count}',
                      label: 'Sessions',
                      sublabel: 'this week',
                    );
                    final avgCard = StatCard(
                      compact: threeCol,
                      icon: Icons.timelapse_rounded,
                      value: weekStats.average == null
                          ? '—'
                          : formatDuration(weekStats.average!),
                      label: 'Avg. duration',
                      sublabel: 'per fast',
                      useWarmAccent: true,
                    );
                    final totalCard = StatCard(
                      compact: threeCol,
                      icon: Icons.schedule_rounded,
                      value:
                          '${(weekStats.total.inMinutes / 60).toStringAsFixed(1)} h',
                      label: 'Total',
                      sublabel: 'logged',
                    );

                    if (threeCol) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: sessionsCard),
                          const SizedBox(width: 10),
                          Expanded(child: avgCard),
                          const SizedBox(width: 10),
                          Expanded(child: totalCard),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: sessionsCard),
                            const SizedBox(width: 10),
                            Expanded(child: avgCard),
                          ],
                        ),
                        const SizedBox(height: 10),
                        totalCard,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _SectionLabel('RECENT ACTIVITY'),
                const SizedBox(height: 10),
                if (recent.isEmpty)
                  const EmptyState(
                    icon: Icons.history_rounded,
                    title: 'No sessions yet',
                    message: 'Completed fasts will appear here.',
                  )
                else
                  for (final s in recent) ...[
                    SessionHistoryTile(session: s, showDate: true),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nested streak + colored highlight card modeled after the PulseUp Fitness
/// "Training Streak / Today's Training" & "Nutrition Streak / Today's Nutrition"
/// cards on the right screen of the reference image.
class _HighlightFeatureCard extends StatelessWidget {
  const _HighlightFeatureCard({
    required this.streakLabel,
    required this.streakValue,
    required this.cardTitle,
    required this.actionLabel,
    required this.icon,
    required this.accent,
    required this.accentDark,
    required this.onTap,
  });

  final String streakLabel;
  final String streakValue;
  final String cardTitle;
  final String actionLabel;
  final IconData icon;
  final Color accent;
  final Color accentDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streakLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                streakValue,
                                style: textTheme.titleSmall?.copyWith(
                                  fontFamily: AppColors.fontDisplay,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 17,
                            height: 17,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Colored inner card with soft gradient + bottom frosted action pill
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accent, accentDark],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              cardTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontFamily: AppColors.fontDisplay,
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            icon,
                            size: 18,
                            color: AppColors.onPrimary.withValues(alpha: 0.78),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.24),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                actionLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF2F5F3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_outward_rounded,
                                size: 13,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
