import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/fastise_logo_mark.dart';
import '../../fasting/application/fasting_scope.dart';
import '../../fasting/domain/fasting_plan.dart';

/// Concise 3-step first-time user guide introducing Fastise's timestamp
/// timer, local-first privacy, and initial fasting schedule selection.
///
/// When [isReplay] is true (opened from Profile), finishing or skipping
/// closes the route without modifying or resetting existing session history.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.isReplay = false,
    this.onFinished,
  });

  final bool isReplay;
  final VoidCallback? onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  FastingPlan? _draftPlan;

  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish({required bool applyPlan}) {
    final controller = FastingScope.of(context);
    if (applyPlan && _draftPlan != null) {
      controller.selectPlan(_draftPlan!);
    }
    if (!widget.isReplay) {
      controller.completeOnboarding();
    }
    if (widget.onFinished != null) {
      widget.onFinished!();
    } else if (widget.isReplay && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (_page < _totalPages - 1) {
      final target = _page + 1;
      setState(() => _page = target);
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish(applyPlan: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = FastingScope.of(context);
    final selectedPlan = _draftPlan ?? controller.selectedPlan;
    final theme = Theme.of(context);
    final isLastPage = _page == _totalPages - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
                  child: Row(
                    children: [
                      const FastiseLogoMark(size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fastise Guide',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: AppColors.fontDisplay,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _finish(applyPlan: false),
                        child: Text(widget.isReplay ? 'Close' : 'Skip'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < _totalPages; i++) ...[
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOut,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: i <= _page
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        if (i != _totalPages - 1) const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _page = index),
                    children: [
                      const _TimerGuideSlide(),
                      const _InsightsPrivacySlide(),
                      _PlanSetupSlide(
                        selectedPlan: selectedPlan,
                        onSelect: (plan) => setState(() => _draftPlan = plan),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _next,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  isLastPage
                                      ? (widget.isReplay
                                            ? 'Done'
                                            : 'Start using Fastise')
                                      : 'Continue',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _TimerGuideSlide extends StatelessWidget {
  const _TimerGuideSlide();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.borderHighlight),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.6, 1.0],
                colors: [
                  AppColors.surfaceTint(AppColors.primary, 0.18),
                  AppColors.surfaceTint(AppColors.primary, 0.05),
                  AppColors.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            'Step 1 · Track effortlessly',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryBright,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FastiseLogoMark(size: 86, sweepProgress: 0.72),
                  const SizedBox(height: 18),
                  Text(
                    '16:00:00',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: AppColors.fontDisplay,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Timestamp-accurate fasting ring',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Track every fast with calm clarity',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppColors.fontDisplay,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap Start Fasting when your fast begins. Your progress is '
            'calculated from the real start timestamp, so the timer stays '
            'exact even if you close the app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.52,
            ),
          ),
          const SizedBox(height: 18),
          const _GuideTipRow(
            icon: Icons.play_circle_outline_rounded,
            title: 'One-tap session control',
            subtitle: 'Start, check remaining hours, and end when ready.',
          ),
          const SizedBox(height: 10),
          const _GuideTipRow(
            icon: Icons.flag_outlined,
            useWarmAccent: true,
            title: 'You stay in charge',
            subtitle:
                'Reaching your goal highlights the ring without auto-stopping.',
          ),
        ],
      ),
    );
  }
}

class _InsightsPrivacySlide extends StatelessWidget {
  const _InsightsPrivacySlide();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.borderHighlight),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.55, 1.0],
                colors: [
                  AppColors.surfaceTint(AppColors.accentWarm, 0.16),
                  AppColors.surfaceTint(AppColors.primary, 0.06),
                  AppColors.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentWarmSoft,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.accentWarm.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      'Step 2 · Rhythm & privacy',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.accentWarm,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: i == 3
                                      ? AppColors.primaryBright
                                      : AppColors.textSecondary,
                                  fontWeight: i == 3
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i <= 2
                                      ? AppColors.primarySoft
                                      : (i == 3
                                            ? AppColors.accentWarmSoft
                                            : AppColors.surfaceSubtle),
                                  border: Border.all(
                                    color: i <= 2
                                        ? AppColors.primary
                                        : (i == 3
                                              ? AppColors.accentWarm
                                              : AppColors.border),
                                    width: 2,
                                  ),
                                ),
                                child: i <= 2
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: AppColors.primaryBright,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Stored only on this device · Zero accounts',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Honest progress, privately yours',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppColors.fontDisplay,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build steady consistency with your Weekly Rhythm strip, 7/30-day '
            'Progress charts, and a clean History log—with no forced sign-in '
            'or cloud tracking.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.52,
            ),
          ),
          const SizedBox(height: 18),
          const _GuideTipRow(
            icon: Icons.insights_rounded,
            title: 'Real numbers only',
            subtitle: 'Every chart and duration reflects sessions you logged.',
          ),
          const SizedBox(height: 10),
          const _GuideTipRow(
            icon: Icons.health_and_safety_outlined,
            useWarmAccent: true,
            title: 'Simple companion, not medical advice',
            subtitle:
                'Fastise tracks schedules. Consult a clinician if unsure.',
          ),
        ],
      ),
    );
  }
}

class _PlanSetupSlide extends StatelessWidget {
  const _PlanSetupSlide({
    required this.selectedPlan,
    required this.onSelect,
  });

  final FastingPlan selectedPlan;
  final ValueChanged<FastingPlan> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'Step 3 · Choose your starting schedule',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryBright,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Pick a fasting plan',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppColors.fontDisplay,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can switch plans anytime from the Home dashboard or Profile.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.48,
            ),
          ),
          const SizedBox(height: 16),
          for (final plan in FastingPlan.presets) ...[
            _CompactPlanOption(
              plan: plan,
              selected: plan.id == selectedPlan.id,
              onTap: () => onSelect(plan),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
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
                  size: 18,
                  color: AppColors.accentWarm,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Fastise is a personal tracking tool, not medical advice. '
                    'Choose a rhythm that feels safe and comfortable for you.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPlanOption extends StatelessWidget {
  const _CompactPlanOption({
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        gradient: selected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceTint(
                    AppColors.primary,
                    0.18,
                    AppColors.surfaceElevated,
                  ),
                  AppColors.surfaceElevated,
                ],
              )
            : null,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: AppColors.fontDisplay,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.primaryBright
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${plan.fastingHours} h fasting · '
                            '${plan.eatingHours} h eating window',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderHighlight,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: AppColors.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 5,
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
                        const SizedBox(width: 3),
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
    );
  }
}

class _GuideTipRow extends StatelessWidget {
  const _GuideTipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.useWarmAccent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool useWarmAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = useWarmAccent ? AppColors.accentWarm : AppColors.primary;
    final accentSoft = useWarmAccent
        ? AppColors.accentWarmSoft
        : AppColors.primarySoft;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: accent.withValues(alpha: 0.30)),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppColors.fontDisplay,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
