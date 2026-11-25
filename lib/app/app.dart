import 'package:flutter/material.dart';

import '../features/fasting/data/fasting_repository.dart';
import '../features/fasting/domain/fasting_plan.dart';
import '../features/fasting/domain/fasting_session_state.dart';
import '../features/fasting/presentation/plan_selection_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'theme/app_theme.dart';

class FastiseApp extends StatelessWidget {
  const FastiseApp({super.key, this.repository});

  final FastingRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fasting Tracker',
      theme: AppTheme.light(),
      home: AppShell(repository: repository),
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
  late final FastingRepository _repository;
  final FastingSessionState _sessionState = FastingSessionState();
  FastingPlan _selectedPlan = FastingAppData.defaultPlan;
  bool _isLoading = true;
  bool _isBusy = false;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? FastingRepository();
    _sessionState.addListener(_handleSessionChanged);
    _loadData();
  }

  @override
  void dispose() {
    _sessionState.removeListener(_handleSessionChanged);
    _sessionState.dispose();
    super.dispose();
  }

  void _handleSessionChanged() {
    if (mounted && !_isLoading && !_isBusy) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    try {
      final data = await _repository.load();
      if (!mounted) return;
      _selectedPlan = data.selectedPlan;
      _sessionState.restore(
        activeSession: data.activeSession,
        completedSessions: data.completedSessions,
      );
      setState(() {
        _isLoading = false;
        _loadError = null;
      });
    } on FastingStorageException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error;
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  Future<void> _startFasting() =>
      _persistSessionChange(() => _sessionState.start(_selectedPlan));

  Future<void> _endFasting() => _persistSessionChange(_sessionState.complete);

  Future<void> _persistSessionChange(bool Function() change) async {
    if (_isBusy || _isLoading || _loadError != null) return;
    final oldActiveSession = _sessionState.activeSession;
    final oldCompletedSessions = _sessionState.completedSessions;
    setState(() => _isBusy = true);

    try {
      if (!change()) return;
      await _repository.save(_currentData());
    } on FastingStorageException catch (error) {
      _sessionState.restore(
        activeSession: oldActiveSession,
        completedSessions: oldCompletedSessions,
      );
      _showMessage(error.message);
    } on ArgumentError catch (error) {
      _showMessage(error.message?.toString() ?? 'The session time is invalid.');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  FastingAppData _currentData({FastingPlan? selectedPlan}) {
    return FastingAppData(
      selectedPlan: selectedPlan ?? _selectedPlan,
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
                  const Icon(Icons.error_outline, size: 40),
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
        activeSession: _sessionState.activeSession,
        onStart: _startFasting,
        onEnd: _endFasting,
        isBusy: _isBusy,
      ),
      const ProgressScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
