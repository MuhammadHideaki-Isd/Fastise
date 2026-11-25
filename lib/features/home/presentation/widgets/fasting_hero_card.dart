import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../fasting/application/fasting_controller.dart';
import '../../../fasting/application/fasting_scope.dart';
import '../../../fasting/presentation/session_summary_screen.dart';
import 'fasting_timer.dart';

/// Timer ring + primary CTA. While a session is active it repaints every
/// second, but every value is recomputed from `session.startAt`.
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
    final now = controller.now();
    final theme = Theme.of(context);
    final isActive = session != null;
    final reached = session != null && session.reachedTarget(now);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive
              ? [
                  AppColors.primarySoft.withValues(alpha: 0.55),
                  AppColors.surface,
                ]
              : const [AppColors.surface, AppColors.surface],
        ),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.border,
          width: isActive ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          children: [
            if (session == null)
              FastingTimer(
                statusLabel: 'Not fasting',
                timeText: '00:00:00',
                progress: 0,
                caption: 'Target ${controller.selectedPlan.fastingHours} h',
              )
            else
              FastingTimer(
                statusLabel: 'Fasting',
                timeText: formatClock(session.elapsed(now)),
                progress: session.progress(now),
                caption: reached
                    ? 'Target reached'
                    : '${formatDuration(session.remaining(now))} left',
                isActive: true,
                isTargetReached: reached,
              ),
            if (session != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeInfo(
                          icon: Icons.play_circle_outline_rounded,
                          label: 'Started',
                          value: formatWhen(session.startAt, now),
                        ),
                      ),
                      const VerticalDivider(width: 20),
                      Expanded(
                        child: _TimeInfo(
                          icon: Icons.flag_outlined,
                          label: 'Target end',
                          value: formatWhen(session.targetEndAt, now),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (reached) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You can keep going or end the session whenever you like.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 18),
            if (session == null)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
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
                    backgroundColor: AppColors.primaryDark,
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

class _TimeInfo extends StatelessWidget {
  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
