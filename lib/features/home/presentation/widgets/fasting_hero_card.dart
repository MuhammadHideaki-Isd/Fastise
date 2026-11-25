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
    );
    if (confirmed && mounted) controller.cancelFasting();
  }

  @override
  Widget build(BuildContext context) {
    final FastingController controller = FastingScope.of(context);
    final session = controller.activeSession;
    final now = controller.now();
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                caption: session.reachedTarget(now)
                    ? 'Target reached'
                    : '${formatDuration(session.remaining(now))} left',
              ),
            if (session != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _TimeInfo(
                      label: 'Started',
                      value: formatWhen(session.startAt, now),
                    ),
                  ),
                  Expanded(
                    child: _TimeInfo(
                      label: 'Target end',
                      value: formatWhen(session.targetEndAt, now),
                    ),
                  ),
                ],
              ),
              if (session.reachedTarget(now)) ...[
                const SizedBox(height: 12),
                Text(
                  'You can keep going or end the session whenever you like.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            if (session == null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: controller.startFasting,
                  child: const Text('Start Fasting'),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => _end(controller),
                  child: const Text('End Fasting'),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
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
  const _TimeInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
