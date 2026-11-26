import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/fasting_repository.dart';
import '../domain/fasting_plan.dart';
import '../domain/fasting_session.dart';

/// App-wide fasting state: selected plan, the single active session, and
/// completed sessions. With a [repository], state is restored on creation
/// and saved after every change.
class FastingController extends ChangeNotifier {
  FastingController({
    FastingPlan plan = FastingPlan.defaultPlan,
    DateTime Function()? clock,
    FastingRepository? repository,
  }) : _repo = repository,
       _selectedPlan = repository?.loadPlan() ?? plan,
       _active = repository?.loadActive(),
       now = clock ?? DateTime.now {
    if (repository != null) _completed.addAll(repository.loadCompleted());
  }

  /// Injectable clock so timer logic can be tested.
  final DateTime Function() now;

  final FastingRepository? _repo;
  FastingPlan _selectedPlan;
  FastingSession? _active;
  final List<FastingSession> _completed = [];

  FastingPlan get selectedPlan => _selectedPlan;
  FastingSession? get activeSession => _active;
  bool get isFasting => _active != null;

  /// Completed sessions, newest first.
  List<FastingSession> get sessions => List.unmodifiable(_completed);

  /// Changing the plan never touches a running session: it keeps its snapshot.
  void selectPlan(FastingPlan plan) {
    if (plan.id == _selectedPlan.id) return;
    _selectedPlan = plan;
    unawaited(_repo?.savePlan(plan));
    notifyListeners();
  }

  /// Starts a session with the selected plan. No-op (returns null) when one
  /// is already active, so double taps cannot create two sessions.
  FastingSession? startFasting() {
    if (_active != null) return null;
    final start = now();
    final plan = _selectedPlan;
    _active = FastingSession(
      id: start.microsecondsSinceEpoch.toString(),
      planId: plan.id,
      planNameSnapshot: plan.name,
      startAt: start,
      plannedDurationMinutes: plan.fastingHours * 60,
    );
    unawaited(_repo?.saveActive(_active));
    notifyListeners();
    return _active;
  }

  /// Completes the active session and returns it, or null if none is active.
  FastingSession? endFasting() {
    final active = _active;
    if (active == null) return null;
    final done = active.complete(now());
    _completed.insert(0, done);
    _active = null;
    // History first, then clear active: a crash in between never loses it.
    unawaited(_repo?.saveCompleted(_completed));
    unawaited(_repo?.saveActive(null));
    notifyListeners();
    return done;
  }

  /// Deletes the plan choice, the active session, and all history.
  void resetData() {
    _selectedPlan = FastingPlan.defaultPlan;
    _active = null;
    _completed.clear();
    unawaited(_repo?.clearAll());
    notifyListeners();
  }

  /// Discards the active session without saving it to history.
  void cancelFasting() {
    if (_active == null) return;
    _active = null;
    unawaited(_repo?.saveActive(null));
    notifyListeners();
  }
}
