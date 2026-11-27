import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../fasting/application/fasting_controller.dart';
import '../../../fasting/application/fasting_scope.dart';
import '../../../fasting/presentation/session_summary_screen.dart';
import 'fasting_timer.dart';

/// Timer ring paired with 3 vertical-tick equalizer metrics (modeled after
/// the central Nutrition screen in the reference) and the primary pill CTA.
class FastingHeroCard extends StatefulWidget {
  const FastingHeroCard({super.key});

  @override
  State<FastingHeroCard> createState() => _FastingHeroCardState();
}

class _FastingHeroCardState extends State<FastingHeroCard> {
  Timer? _ticker;

  /// Called whenever the controller notifies (InheritedNotifier dependency).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fasting = FastingScope.of(context).isFasting;
    if (fasting && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!fasting) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// Confirm -> save end time + actual duration -> show the summary.
  /// Dismissing the dialog leaves the session untouched.
  Future<void> _end(FastingController controller) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'End this fast?',
      message: 'Your session will be saved with its actual duration.',
      confirmLabel: 'End session',
      cancelLabel: 'Keep fasting',
    );
    if (!confirmed || !mounted) return;
    final done = controller.endFasting();
    if (done == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(session: done),
      ),
    );
  }

  Future<void> _cancel(FastingController controller) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Discard this session?',
      message: 'It will not be saved to your history.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep fasting',
      isDestructive: true,
    );
    if (confirmed && mounted) controller.cancelFasting();
  }

  @override
  Widget build(BuildContext context) {
    final FastingController controller = FastingScope.of(context);
    final session = controller.activeSession;
    final plan = controller.selectedPlan;
    final now = controller.now();
    final theme = Theme.of(context);
    final isActive = session != null;
    final reached = session != null && session.reachedTarget(now);
    final progress = session?.progress(now) ?? 0.0;
    final glowColor = reached ? AppColors.accentWarm : AppColors.primary;

    final timerWidget = session == null
        ? FastingTimer(
            statusLabel: 'Not fasting',
            timeText: '00:00:00',
            progress: 0,
            caption: 'Target ${plan.fastingHours} h',
          )
        : FastingTimer(
            statusLabel: 'Fasting',
            timeText: formatClock(session.elapsed(now)),
            progress: progress,
            caption: reached
                ? 'Target reached'
                : '${formatDuration(session.remaining(now))} left',
            isActive: true,
            isTargetReached: reached,
          );

    final metricsColumn = session == null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              EqualizerMetricRow(
                value: '${plan.fastingHours} h',
                label: 'Fast goal',
                fillRatio: plan.fastingHours / 24,
                accent: AppColors.primary,
              ),
              const SizedBox(height: 14),
              EqualizerMetricRow(
                value: '${plan.eatingHours} h',
                label: 'Eat window',
                fillRatio: plan.eatingHours / 24,
                accent: AppColors.accentWarm,
              ),
              const SizedBox(height: 14),
              EqualizerMetricRow(
                value: '${(plan.fastingHours / 24 * 100).round()}%',
                label: 'Daily ratio',
                fillRatio: plan.fastingHours / 24,
                accent: AppColors.primaryBright,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              EqualizerMetricRow(
                value: formatWhen(session.startAt, now),
                label: 'Started',
                fillRatio: 1.0,
                accent: AppColors.primary,
              ),
              const SizedBox(height: 14),
              EqualizerMetricRow(
                value: formatWhen(session.targetEndAt, now),
                label: 'Target end',
                fillRatio: reached ? 1.0 : 0.55,
                accent: AppColors.accentWarm,
              ),
              const SizedBox(height: 14),
              EqualizerMetricRow(
                value: '${(progress * 100).round()}%',
                label: 'Completed',
                fillRatio: progress.clamp(0.15, 1.0),
                accent: reached ? AppColors.accentWarm : AppColors.primaryBright,
              ),
            ],
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: AppColors.surface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
          colors: [
            AppColors.surfaceTint(glowColor, isActive ? 0.14 : 0.07),
            AppColors.surfaceTint(glowColor, isActive ? 0.04 : 0.02),
            AppColors.surface,
          ],
        ),
        border: Border.all(
          color: isActive
              ? glowColor.withValues(alpha: 0.36)
              : AppColors.border,
          width: isActive ? 1.2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                final sideBySide =
                    constraints.maxWidth >= 285 && textScale <= 1.35;
                if (sideBySide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 11,
                        child: Center(child: timerWidget),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 9,
                        child: metricsColumn,
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    timerWidget,
                    const SizedBox(height: 14),
                    metricsColumn,
                  ],
                );
              },
            ),
            if (reached) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentWarmSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentWarm.withValues(alpha: 0.32),
                  ),
                ),
                child: Text(
                  'You can keep going or end the session whenever you like.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.accentWarm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Sleek full-width pill action bar (like the reference's Check calories pill)
            if (session == null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: controller.startFasting,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 22),
                      SizedBox(width: 6),
                      Flexible(child: Text('Start Fasting')),
                    ],
                  ),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: AppColors.surfaceElevated,
                    foregroundColor: AppColors.primaryBright,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () => _end(controller),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stop_circle_outlined, size: 20),
                      SizedBox(width: 8),
                      Flexible(child: Text('End Fasting')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _cancel(controller),
                child: const Text('Cancel session'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
