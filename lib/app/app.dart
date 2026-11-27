import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/fasting/application/fasting_controller.dart';
import '../features/fasting/application/fasting_scope.dart';
import '../features/fasting/presentation/session_summary_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/widget/data/home_widget_sync.dart';
import '../shared/widgets/confirmation_dialog.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class FastiseApp extends StatefulWidget {
  const FastiseApp({
    super.key,
    required this.controller,
    this.showLaunchFlow = false,
    this.splashDuration = const Duration(milliseconds: 1350),
    this.widgetSync,
  });

  final FastingController controller;

  /// Enables the branded splash screen and first-time user guide on startup.
  /// Left false by default so widget tests targeting dashboard flows directly
  /// remain fast and deterministic.
  final bool showLaunchFlow;
  final Duration splashDuration;
  final HomeWidgetSync? widgetSync;

  @override
  State<FastiseApp> createState() => _FastiseAppState();
}

class _FastiseAppState extends State<FastiseApp> with WidgetsBindingObserver {
  HomeWidgetSync get _sync => widget.widgetSync ?? HomeWidgetSync.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onControllerChanged);
    unawaited(_sync.sync(widget.controller));
  }

  @override
  void didUpdateWidget(covariant FastiseApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      unawaited(_sync.sync(widget.controller));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_sync.sync(widget.controller));
    }
  }

  void _onControllerChanged() {
    unawaited(_sync.sync(widget.controller));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FastingScope(
      controller: widget.controller,
      child: MaterialApp(
        title: 'Fastise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: widget.showLaunchFlow
            ? _LaunchCoordinator(
                controller: widget.controller,
                splashDuration: widget.splashDuration,
              )
            : const AppShell(),
      ),
    );
  }
}

class _LaunchCoordinator extends StatefulWidget {
  const _LaunchCoordinator({
    required this.controller,
    required this.splashDuration,
  });

  final FastingController controller;
  final Duration splashDuration;

  @override
  State<_LaunchCoordinator> createState() => _LaunchCoordinatorState();
}

class _LaunchCoordinatorState extends State<_LaunchCoordinator> {
  Timer? _splashTimer;
  bool _showingSplash = true;
  bool _showingOnboarding = false;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(widget.splashDuration, _finishSplash);
  }

  void _finishSplash() {
    if (!mounted) return;
    setState(() {
      _showingSplash = false;
      _showingOnboarding = !widget.controller.hasSeenOnboarding;
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget screen;
    if (_showingSplash) {
      screen = const SplashScreen(key: ValueKey('splash'));
    } else if (_showingOnboarding) {
      screen = OnboardingScreen(
        key: const ValueKey('onboarding'),
        onFinished: () => setState(() => _showingOnboarding = false),
      );
    } else {
      screen = const AppShell(key: ValueKey('app-shell'));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: screen,
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _homeIndex = 0;
  static const _progressIndex = 1;
  static const _profileIndex = 3;

  Future<void> _onQuickActionTap(FastingController controller) async {
    if (_selectedIndex != _homeIndex) {
      setState(() => _selectedIndex = _homeIndex);
    }
    if (!controller.isFasting) {
      controller.startFasting();
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final controller = FastingScope.of(context);
    final isFasting = controller.isFasting;
    final reached =
        isFasting && controller.activeSession!.reachedTarget(controller.now());
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final showCompactCenter = screenWidth < 340 && textScale > 1.3;
    final centerSize = showCompactCenter ? 44.0 : 50.0;
    final ringAccent = reached ? AppColors.accentWarm : AppColors.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(
              onProfileTap: () =>
                  setState(() => _selectedIndex = _profileIndex),
              onProgressTap: () =>
                  setState(() => _selectedIndex = _progressIndex),
            ),
            const ProgressScreen(),
            const HistoryScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: SizedBox(
            height: 82,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // Sleek dark curved bottom bar matching the reference dock
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF171A18),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      border: const Border(
                        top: BorderSide(color: AppColors.border),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Align(
                      heightFactor: 1,
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: NavigationBar(
                          selectedIndex: _selectedIndex,
                          onDestinationSelected: (index) {
                            setState(() => _selectedIndex = index);
                          },
                          destinations: [
                            NavigationDestination(
                              icon: Badge(
                                isLabelVisible:
                                    isFasting && _selectedIndex != 0,
                                backgroundColor: AppColors.primary,
                                smallSize: 7,
                                child: const Icon(Icons.home_outlined),
                              ),
                              selectedIcon: const Icon(Icons.home_rounded),
                              label: 'Home',
                            ),
                            const NavigationDestination(
                              icon: Icon(Icons.insights_outlined),
                              selectedIcon: Icon(Icons.insights_rounded),
                              label: 'Progress',
                            ),
                            const NavigationDestination(
                              icon: Icon(Icons.history_outlined),
                              selectedIcon: Icon(Icons.history_rounded),
                              label: 'History',
                            ),
                            const NavigationDestination(
                              icon: Icon(Icons.person_outline_rounded),
                              selectedIcon: Icon(Icons.person_rounded),
                              label: 'Profile',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Signature raised circular ring button in the center
                Positioned(
                  top: 0,
                  child: Tooltip(
                    message: isFasting
                        ? 'Quick end fasting'
                        : 'Quick start fasting',
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _onQuickActionTap(controller),
                        child: Container(
                          width: centerSize + 8,
                          height: centerSize + 8,
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            width: centerSize,
                            height: centerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.background,
                              border: Border.all(
                                color: ringAccent,
                                width: 6.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ringAccent.withValues(alpha: 0.30),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFasting
                                  ? Icons.stop_rounded
                                  : Icons.add_rounded,
                              size: showCompactCenter ? 22 : 26,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
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
