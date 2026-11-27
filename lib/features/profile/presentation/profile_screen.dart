import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fasty_mascot.dart';
import '../../fasting/application/fasting_scope.dart';
import '../../fasting/presentation/plan_selection_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../widget/data/home_widget_sync.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FastingScope.of(context);
    final plan = controller.selectedPlan;
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              Text(
                'Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: AppColors.fontDisplay,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Schedule preferences, privacy, and local device data.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('FASTING PLAN'),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderHighlight),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: const Alignment(0.7, 1.0),
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      AppColors.surfaceTint(AppColors.primary, 0.16),
                      AppColors.surfaceTint(AppColors.primary, 0.04),
                      AppColors.surface,
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PlanSelectionScreen(),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.32,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.schedule_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontFamily: AppColors.fontDisplay,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${plan.fastingHours} h fasting · '
                                      '${plan.eatingHours} h eating window\n'
                                      'Applies to your next session',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            height: 1.45,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontFamily: AppColors.fontDisplay,
                                    color: AppColors.primaryBright,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 6,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 26),
              const _SectionLabel('ABOUT'),
              const SizedBox(height: 10),
              const _InfoCard(
                icon: Icons.spa_outlined,
                title: 'Fastise',
                body:
                    'A simple companion to log your fasting schedule, track a '
                    'running session, and review past sessions.',
              ),
              const SizedBox(height: 12),
              const _InfoCard(
                icon: Icons.shield_outlined,
                title: 'Privacy',
                body:
                    'Everything is stored on this device only. There is no '
                    'account and nothing is sent anywhere.',
              ),
              const SizedBox(height: 12),
              const _InfoCard(
                icon: Icons.health_and_safety_outlined,
                useWarmAccent: true,
                title: 'Health note',
                body:
                    'Fastise is a tracking tool, not medical advice. '
                    'Fasting may not be suitable for everyone. Consult a '
                    'qualified healthcare professional if you are unsure '
                    'whether fasting is appropriate for you. This includes if '
                    'you have a medical condition, are pregnant or '
                    'breastfeeding, have a history of eating disorders, or '
                    'are still growing.',
              ),
              const SizedBox(height: 26),
              const _SectionLabel('HOME SCREEN WIDGET'),
              const SizedBox(height: 10),
              _WidgetPreviewCard(snapshot: WidgetSnapshot.fromController(controller)),
              const SizedBox(height: 26),
              const _SectionLabel('GUIDE'),
              const SizedBox(height: 10),
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const OnboardingScreen(isReplay: true),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 19,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'App guide',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: AppColors.fontDisplay,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Review how Fastise works anytime.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const _SectionLabel('DATA'),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showConfirmationDialog(
                    context,
                    title: 'Reset all data?',
                    message:
                        'This deletes your history, any running session, and '
                        'your plan choice from this device. It cannot be '
                        'undone.',
                    confirmLabel: 'Reset',
                    isDestructive: true,
                  );
                  if (ok) controller.resetData();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  backgroundColor: AppColors.errorSoft,
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.45),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Reset all data'),
              ),
            ],
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.useWarmAccent = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool useWarmAccent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = useWarmAccent ? AppColors.accentWarm : AppColors.primary;
    final accentSoft = useWarmAccent
        ? AppColors.accentWarmSoft
        : AppColors.primarySoft;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: accent.withValues(alpha: 0.28)),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: AppColors.fontDisplay,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.48,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetPreviewCard extends StatelessWidget {
  const _WidgetPreviewCard({required this.snapshot});

  final WidgetSnapshot snapshot;

  Future<void> _pinWidget(BuildContext context) async {
    final pinned = await HomeWidgetSync.instance.requestPinWidget();
    if (!context.mounted) return;
    final message = pinned
        ? 'Follow the system prompt to add the Fastise widget to your Home screen.'
        : 'Long-press an empty space on your phone Home screen, open Widgets, and pick Fastise.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWarm = snapshot.mood == WidgetMood.targetReached;
    final accent = isWarm ? AppColors.accentWarm : AppColors.primary;
    final accentSoft = isWarm
        ? AppColors.accentWarmSoft
        : AppColors.primarySoft;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.42)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceTint(accent, 0.16),
            AppColors.surface,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FastyMascot(mood: snapshot.mood, size: 60),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accentSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 13,
                              color: accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              snapshot.streakDays == 0
                                  ? 'Start Day 1'
                                  : '${snapshot.streakDays} day streak',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        snapshot.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppColors.fontDisplay,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        snapshot.subtext,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _pinWidget(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withValues(alpha: 0.45)),
                minimumSize: const Size.fromHeight(46),
              ),
              icon: const Icon(Icons.widgets_outlined, size: 18),
              label: const Text('Add widget to Home screen'),
            ),
          ],
        ),
      ),
    );
  }
}
