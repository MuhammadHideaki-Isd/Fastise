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
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('FASTING PLAN'),
          const SizedBox(height: 10),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PlanSelectionScreen(),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Icon(Icons.schedule, color: AppColors.primary),
              ),
              title: Text(
                plan.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                '${plan.fastingHours} h fasting · '
                '${plan.eatingHours} h eating window\n'
                'Applies to your next session',
              ),
              isThreeLine: true,
              trailing: const Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('ABOUT'),
          const SizedBox(height: 10),
          const _InfoCard(
            title: 'Fasting Tracker',
            body:
                'A simple companion to log your fasting schedule, track a '
                'running session, and review past sessions.',
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'Privacy',
            body:
                'Everything is stored on this device only. There is no '
                'account and nothing is sent anywhere.',
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            title: 'Health note',
            body:
                'Fasting Tracker is a tracking tool, not medical advice. '
                'Fasting may not be suitable for everyone. Consult a '
                'qualified healthcare professional if you are unsure whether '
                'fasting is appropriate for you. This includes if you have a '
                'medical condition, are pregnant or breastfeeding, have a '
                'history of eating disorders, or are still growing.',
          ),
          const SizedBox(height: 24),
          const _SectionLabel('DATA'),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await showConfirmationDialog(
                context,
                title: 'Reset all data?',
                message:
                    'This deletes your history, any running session, and '
                    'your plan choice from this device. It cannot be undone.',
                confirmLabel: 'Reset',
              );
              if (ok) controller.resetData();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: AppColors.error),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Reset all data'),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
