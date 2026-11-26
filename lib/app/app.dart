import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/fasting/application/fasting_controller.dart';
import '../features/fasting/application/fasting_scope.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class FastiseApp extends StatelessWidget {
  const FastiseApp({super.key, required this.controller});

  final FastingController controller;

  @override
  Widget build(BuildContext context) {
    return FastingScope(
      controller: controller,
      child: MaterialApp(
        title: 'Fastise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.repository});

  final FastingRepository? repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _profileIndex = 3;

  @override
  Widget build(BuildContext context) {
    final isFasting = FastingScope.of(context).isFasting;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalInset = screenWidth < 360 ? 8.0 : 16.0;
    final bottomInset = screenWidth < 360 ? 6.0 : 12.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(
              onProfileTap: () =>
                  setState(() => _selectedIndex = _profileIndex),
            ),
            const ProgressScreen(),
            const HistoryScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              4,
              horizontalInset,
              bottomInset,
            ),
            child: Align(
              heightFactor: 1,
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.borderHighlight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      destinations: [
                        NavigationDestination(
                          icon: Badge(
                            isLabelVisible: isFasting && _selectedIndex != 0,
                            backgroundColor: AppColors.primary,
                            smallSize: 8,
                            child: const Icon(Icons.timer_outlined),
                          ),
                          selectedIcon: const Icon(Icons.timer_rounded),
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
          ),
        ),
      ),
    );
    if (!mounted || shouldEnd != true) return;

    final saved = await _persistSessionChange(_sessionState.complete);
    if (!mounted || !saved) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(
          session: _sessionState.completedSessions.first,
        ),
      ),
    );
  }

  Future<bool> _persistSessionChange(bool Function() change) async {
    if (_isBusy || _isLoading || _loadError != null) return false;
    final oldActiveSession = _sessionState.activeSession;
    final oldCompletedSessions = _sessionState.completedSessions;
    setState(() => _isBusy = true);

    try {
      if (!change()) return false;
      await _repository.save(_currentData());
      return true;
    } on FastingStorageException catch (error) {
      _sessionState.restore(
        activeSession: oldActiveSession,
        completedSessions: oldCompletedSessions,
      );
      _showMessage(error.message);
      return false;
    } on ArgumentError catch (error) {
      _showMessage(error.message?.toString() ?? 'The session time is invalid.');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  FastingAppData _currentData({
    FastingPlan? selectedPlan,
    bool? glassEffectEnabled,
  }) {
    return FastingAppData(
      selectedPlan: selectedPlan ?? _selectedPlan,
      glassEffectEnabled: glassEffectEnabled ?? _glassEffectEnabled,
      sessions: [
        ?_sessionState.activeSession,
        ..._sessionState.completedSessions,
      ],
    );
  }

  Future<bool> _savePlan(FastingPlan plan) async {
    if (_isBusy || _isLoading || _loadError != null) return false;
    setState(() => _isBusy = true);
    try {
      await _repository.save(_currentData(selectedPlan: plan));
      if (!mounted) return false;
      setState(() => _selectedPlan = plan);
      return true;
    } on FastingStorageException catch (error) {
      _showMessage(error.message);
      return false;
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _setGlassEffectEnabled(bool enabled) async {
    if (_isBusy || _isLoading || _loadError != null) return;
    setState(() => _isBusy = true);
    try {
      await _repository.save(_currentData(glassEffectEnabled: enabled));
      if (!mounted) return;
      setState(() => _glassEffectEnabled = enabled);
    } on FastingStorageException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openPlanSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PlanSelectionScreen(initialPlan: _selectedPlan, onSave: _savePlan),
      ),
    );
  }

  Future<void> _clearSavedData() async {
    setState(() => _isBusy = true);
    try {
      await _repository.clear();
      _sessionState.restore(activeSession: null, completedSessions: []);
      if (!mounted) return;
      setState(() {
        _selectedPlan = FastingAppData.defaultPlan;
        _glassEffectEnabled = true;
        _loadError = null;
        _isLoading = false;
      });
    } on FastingStorageException catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(PhosphorIconsRegular.warningCircle, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load saved data',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(_loadError.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isBusy ? null : _loadData,
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: _isBusy ? null : _clearSavedData,
                    child: const Text('Clear local app data and continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        selectedPlan: _selectedPlan,
        onSelectPlan: _openPlanSelection,
        onOpenProfile: () => setState(() => _selectedIndex = 3),
        activeSession: _sessionState.activeSession,
        onStart: _startFasting,
        onEnd: _endFasting,
        completedSessions: _sessionState.completedSessions,
        isBusy: _isBusy,
      ),
      ProgressScreen(sessions: _sessionState.completedSessions),
      HistoryScreen(sessions: _sessionState.completedSessions),
      ProfileScreen(
        selectedPlan: _selectedPlan,
        hasActiveSession: _sessionState.activeSession != null,
        onEditPlan: _openPlanSelection,
        glassEffectEnabled: _glassEffectEnabled,
        onGlassEffectChanged: _setGlassEffectEnabled,
        isBusy: _isBusy,
      ),
    ];

    return Scaffold(
      body: _glassEffectEnabled
          ? GlassScaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              extendBody: false,
              body: IndexedStack(index: _selectedIndex, children: screens),
              bottomBar: GlassTabBar.bottom(
                selectedIndex: _selectedIndex,
                onTabSelected: _selectTab,
                selectedIconColor: AppColors.primary,
                unselectedIconColor: AppColors.textSecondary,
                selectedLabelColor: AppColors.primaryDark,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary.withValues(alpha: 0.12),
                tabs: const [
                  GlassTab(
                    icon: Icon(PhosphorIconsRegular.house),
                    activeIcon: Icon(PhosphorIconsFill.house),
                    label: 'Home',
                  ),
                  GlassTab(
                    icon: Icon(PhosphorIconsRegular.chartLineUp),
                    activeIcon: Icon(PhosphorIconsFill.chartLineUp),
                    label: 'Progress',
                  ),
                  GlassTab(
                    icon: Icon(PhosphorIconsRegular.clockCounterClockwise),
                    activeIcon: Icon(PhosphorIconsFill.clockCounterClockwise),
                    label: 'History',
                  ),
                  GlassTab(
                    icon: Icon(PhosphorIconsRegular.userCircle),
                    activeIcon: Icon(PhosphorIconsFill.userCircle),
                    label: 'Profile',
                  ),
                ],
              ),
            )
          : IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: _glassEffectEnabled
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(PhosphorIconsRegular.house),
                  selectedIcon: Icon(PhosphorIconsFill.house),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(PhosphorIconsRegular.chartLineUp),
                  selectedIcon: Icon(PhosphorIconsFill.chartLineUp),
                  label: 'Progress',
                ),
                NavigationDestination(
                  icon: Icon(PhosphorIconsRegular.clockCounterClockwise),
                  selectedIcon: Icon(PhosphorIconsFill.clockCounterClockwise),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(PhosphorIconsRegular.userCircle),
                  selectedIcon: Icon(PhosphorIconsFill.userCircle),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}
