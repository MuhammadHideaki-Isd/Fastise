import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../application/fasting_controller.dart';
import '../application/fasting_scope.dart';
import '../domain/fasting_plan.dart';

class PlanSelectionScreen extends StatefulWidget {
  const PlanSelectionScreen({super.key});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  FastingPlan? _selected;

  void _save(FastingController controller, FastingPlan plan) {
    controller.selectPlan(plan);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = FastingScope.of(context);
    final selected = _selected ?? controller.selectedPlan;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Fasting plan')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Text(
                    'Choose your fasting plan',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pick a schedule to track. A plan change applies to your '
                    'next session, not one that is already running.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final plan in FastingPlan.presets) ...[
                    _PlanCard(
                      plan: plan,
                      selected: plan.id == selected.id,
                      onTap: () => setState(() => _selected = plan),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Fasting Tracker is a tracking tool, not medical advice. '
                    'Fasting may not be suitable for everyone. Consult a '
                    'qualified healthcare professional if you are unsure '
                    'whether fasting is appropriate for you.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => _save(controller, selected),
                  child: const Text('Save Plan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final FastingPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
        width: selected ? 2 : 1,
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      child: Card(
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.fastingHours} h fasting · '
                        '${plan.eatingHours} h eating window',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Selected',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
