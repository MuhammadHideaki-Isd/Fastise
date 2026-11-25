import 'package:flutter/foundation.dart';

import '../domain/fasting_plan.dart';
import '../domain/fasting_session.dart';

/// App-wide fasting state: selected plan, the single active session, and
/// completed sessions. Persistence is added in Task 7.
class FastingController extends ChangeNotifier {
  FastingController({
    FastingPlan plan = FastingPlan.defaultPlan,
    DateTime Function()? clock,
  }) : _selectedPlan = plan,
       now = clock ?? DateTime.now;

  /// Injectable clock so timer logic can be tested.
  final DateTime Function() now;

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
    notifyListeners();
    return done;
  }

  /// Discards the active session without saving it to history.
  void cancelFasting() {
    if (_active == null) return;
    _active = null;
    notifyListeners();
  }
}
