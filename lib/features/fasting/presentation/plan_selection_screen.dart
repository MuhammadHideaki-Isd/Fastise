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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      Text(
                        'Choose your fasting plan',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppColors.fontDisplay,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pick a schedule to track. A plan change applies to '
                        'your next session, not one that is already running.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.48,
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: AppColors.accentWarm,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Fastise is a tracking tool, not '
                                'medical advice. Fasting may not be suitable '
                                'for everyone. Consult a qualified healthcare '
                                'professional if you are unsure whether '
                                'fasting is appropriate for you.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.48,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _save(controller, selected),
                      child: const Text('Save Plan'),
                    ),
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

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceElevated : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: const Alignment(0.75, 1.0),
                  stops: const [0.0, 0.48, 1.0],
                  colors: [
                    AppColors.surfaceTint(
                      AppColors.primary,
                      0.18,
                      AppColors.surfaceElevated,
                    ),
                    AppColors.surfaceTint(
                      AppColors.primary,
                      0.05,
                      AppColors.surfaceElevated,
                    ),
                    AppColors.surfaceElevated,
                  ],
                )
              : null,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontFamily: AppColors.fontDisplay,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? AppColors.primaryBright
                                    : AppColors.textPrimary,
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
                      const SizedBox(width: 12),
                      if (selected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.onPrimary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Selected',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderHighlight,
                              width: 2,
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
                            child: ColoredBox(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: plan.eatingHours,
                            child: ColoredBox(
                              color: AppColors.accentWarm.withValues(
                                alpha: selected ? 0.65 : 0.35,
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
    );
  }
}
