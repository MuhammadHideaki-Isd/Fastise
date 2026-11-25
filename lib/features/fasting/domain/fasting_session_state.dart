import 'package:flutter/foundation.dart';

import 'fasting_plan.dart';
import 'fasting_session.dart';

typedef SessionClock = DateTime Function();
typedef SessionIdFactory = String Function();

class FastingSessionState extends ChangeNotifier {
  FastingSessionState({SessionClock? clock, SessionIdFactory? idFactory})
    : _clock = clock ?? DateTime.now,
      _idFactory =
          idFactory ?? (() => DateTime.now().microsecondsSinceEpoch.toString());

  final SessionClock _clock;
  final SessionIdFactory _idFactory;

  FastingSession? _activeSession;
  final List<FastingSession> _completedSessions = [];

  FastingSession? get activeSession => _activeSession;
  bool get isActive => _activeSession != null;
  List<FastingSession> get completedSessions =>
      List.unmodifiable(_completedSessions);

  bool start(FastingPlan plan) {
    if (_activeSession != null) {
      return false;
    }

    _activeSession = FastingSession.start(
      id: _idFactory(),
      plan: plan,
      startAt: _clock(),
    );
    notifyListeners();
    return true;
  }

  bool complete({DateTime? endAt}) {
    final activeSession = _activeSession;
    if (activeSession == null) {
      return false;
    }

    final completedSession = activeSession.completeAt(endAt ?? _clock());
    _activeSession = null;
    _completedSessions.insert(0, completedSession);
    notifyListeners();
    return true;
  }

  void cancel() {
    if (_activeSession == null) {
      return;
    }

    _activeSession = null;
    notifyListeners();
  }
}
