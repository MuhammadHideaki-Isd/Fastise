import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../fasting/application/fasting_scope.dart';
import '../../fasting/presentation/plan_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FastingScope.of(context);
    final plan = controller.selectedPlan;
    final theme = Theme.of(context);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                'Profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
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
              Card(
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
                                borderRadius: BorderRadius.circular(12),
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
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${plan.fastingHours} h fasting · '
                                    '${plan.eatingHours} h eating window\n'
                                    'Applies to your next session',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
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
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 6,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: plan.fastingHours,
                                  child: const ColoredBox(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  flex: plan.eatingHours,
                                  child: const ColoredBox(
                                    color: AppColors.primaryMuted,
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
              const SizedBox(height: 26),
              const _SectionLabel('ABOUT'),
              const SizedBox(height: 10),
              const _InfoCard(
                icon: Icons.spa_outlined,
                title: 'Fasting Tracker',
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
                title: 'Health note',
                body:
                    'Fasting Tracker is a tracking tool, not medical advice. '
                    'Fasting may not be suitable for everyone. Consult a '
                    'qualified healthcare professional if you are unsure '
                    'whether fasting is appropriate for you. This includes if '
                    'you have a medical condition, are pregnant or '
                    'breastfeeding, have a history of eating disorders, or '
                    'are still growing.',
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
                  backgroundColor: AppColors.errorSoft.withValues(alpha: 0.45),
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.55),
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
        letterSpacing: 1.1,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
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
