import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../fasting/domain/fasting_plan.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.selectedPlan,
    required this.hasActiveSession,
    required this.onEditPlan,
    required this.glassEffectEnabled,
    required this.onGlassEffectChanged,
    required this.isBusy,
  });

  final FastingPlan selectedPlan;
  final bool hasActiveSession;
  final VoidCallback onEditPlan;
  final bool glassEffectEnabled;
  final ValueChanged<bool> onGlassEffectChanged;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your fasting preferences and app information.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionLabel(label: 'FASTING PLAN'),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      PhosphorIconsRegular.clock,
                      color: AppColors.primary,
                    ),
                    title: Text('${selectedPlan.label} fasting'),
                    subtitle: Text(
                      '${selectedPlan.fastingHours} hours fasting · '
                      '${selectedPlan.eatingHours} hours eating',
                    ),
                    trailing: const Icon(PhosphorIconsRegular.caretRight),
                    onTap: onEditPlan,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasActiveSession
                      ? 'Plan changes apply to future sessions. Your active '
                            'session keeps its original plan.'
                      : 'Plan changes apply to future sessions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                _SectionLabel(label: 'APPEARANCE'),
                const SizedBox(height: 10),
                Card(
                  child: SwitchListTile(
                    key: const ValueKey('glass-effect-setting'),
                    secondary: const Icon(
                      PhosphorIconsRegular.sparkle,
                      color: AppColors.primary,
                    ),
                    title: const Text('Liquid glass effect'),
                    subtitle: const Text(
                      'Use glass styling for the bottom navigation.',
                    ),
                    value: glassEffectEnabled,
                    onChanged: isBusy ? null : onGlassEffectChanged,
                  ),
                ),
                const SizedBox(height: 28),
                _SectionLabel(label: 'ABOUT'),
                const SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(
                          PhosphorIconsRegular.hourglass,
                          color: AppColors.primary,
                        ),
                        title: Text('Fastise'),
                        subtitle: Text('Fasting session tracker'),
                      ),
                      const Divider(height: 1, indent: 56),
                      ListTile(
                        leading: const Icon(
                          PhosphorIconsRegular.lock,
                          color: AppColors.primary,
                        ),
                        title: const Text('Privacy'),
                        subtitle: const Text(
                          'Your plan and session history are stored on this '
                          'device. No account or cloud sync is used.',
                        ),
                        isThreeLine: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _SectionLabel(label: 'HEALTH & SAFETY'),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          PhosphorIconsRegular.info,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Fasting Tracker is a tracking tool, not medical '
                            'advice. Fasting may not be suitable for everyone. '
                            'Consult a qualified healthcare professional if '
                            'you are unsure whether fasting is appropriate for '
                            'you.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}
