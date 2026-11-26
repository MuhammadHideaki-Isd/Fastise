import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../fasting/application/fasting_scope.dart';
import '../../fasting/domain/fasting_stats.dart';
import '../../fasting/presentation/plan_selection_screen.dart';
import '../../fasting/presentation/session_history_tile.dart';
import 'widgets/fasting_hero_card.dart';
import 'widgets/week_strip_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onProfileTap});

  final VoidCallback onProfileTap;

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
    final weekStats = statsFor(
      sessionsSince(controller.sessions, startOfWeek(now)),
    );
    final dateText = formatDate(now, full: true);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  dateText,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            HomeScreen._greeting(now.hour),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily: AppColors.fontDisplay,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Open profile',
                      onPressed: widget.onProfileTap,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.primaryBright,
                        side: const BorderSide(color: AppColors.borderHighlight),
                      ),
                      icon: const Icon(Icons.person_outline_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const FastingHeroCard(),
                const SizedBox(height: 16),
                const _SectionLabel('YOUR PLAN'),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(0.7, 1.0),
                      stops: const [0.0, 0.45, 1.0],
                      colors: [
                        AppColors.surfaceTint(AppColors.primary, 0.15),
                        AppColors.surfaceTint(AppColors.primary, 0.04),
                        AppColors.surface,
                      ],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _openPlanSelection,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.30,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.schedule_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontFamily: AppColors.fontDisplay,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${plan.fastingHours} h fasting · '
                                        '${plan.eatingHours} h eating window',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_outward_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: SizedBox(
                                height: 6,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: plan.fastingHours,
                                      child: const ColoredBox(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      flex: plan.eatingHours,
                                      child: ColoredBox(
                                        color: AppColors.accentWarm.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('THIS WEEK'),
                const SizedBox(height: 8),
                WeekStripCard(
                  now: now,
                  sessions: controller.sessions,
                  activeSession: controller.activeSession,
                  targetHours: plan.fastingHours,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle_outline_rounded,
                        value: '${weekStats.count}',
                        label: 'Sessions',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icon: Icons.timelapse_rounded,
                        value: weekStats.average == null
                            ? '—'
                            : formatDuration(weekStats.average!),
                        label: 'Avg. duration',
                        useWarmAccent: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionLabel('RECENT ACTIVITY'),
                const SizedBox(height: 8),
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
