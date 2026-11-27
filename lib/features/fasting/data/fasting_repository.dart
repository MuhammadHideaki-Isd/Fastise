import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/fasting_plan.dart';
import '../domain/fasting_session.dart';

/// Local storage for the selected plan, sessions, and onboarding flag.
/// Reads never throw: missing or malformed data falls back to defaults
/// (or drops bad entries).
class FastingRepository {
  FastingRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _planKey = 'selected_plan_id';
  static const _activeKey = 'active_session';
  static const _completedKey = 'completed_sessions';
  static const _onboardingKey = 'has_seen_onboarding';

  bool loadHasSeenOnboarding() {
    try {
      return _prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      return false; // stored with an unexpected type
    }
  }

  FastingPlan loadPlan() =>
      FastingPlan.byId(_readString(_planKey)) ?? FastingPlan.defaultPlan;

  FastingSession? loadActive() {
    final session = FastingSession.tryFromJson(_decode(_activeKey));
    return session?.status == SessionStatus.active ? session : null;
  }

  /// Valid completed sessions, newest first.
  List<FastingSession> loadCompleted() {
    final raw = _decode(_completedKey);
    if (raw is! List) return [];
    final sessions = [
      for (final item in raw)
        if (FastingSession.tryFromJson(item) case final s?)
          if (s.status == SessionStatus.completed) s,
    ];
    sessions.sort((a, b) => b.startAt.compareTo(a.startAt));
    return sessions;
  }

  Future<void> saveHasSeenOnboarding(bool seen) =>
      _prefs.setBool(_onboardingKey, seen);

  Future<void> savePlan(FastingPlan plan) =>
      _prefs.setString(_planKey, plan.id);

  Future<void> saveActive(FastingSession? session) => session == null
      ? _prefs.remove(_activeKey)
      : _prefs.setString(_activeKey, jsonEncode(session.toJson()));

  Future<void> saveCompleted(List<FastingSession> sessions) => _prefs.setString(
    _completedKey,
    jsonEncode([for (final s in sessions) s.toJson()]),
  );

  Future<void> clearAll() async {
    await _prefs.remove(_planKey);
    await _prefs.remove(_activeKey);
    await _prefs.remove(_completedKey);
    await _prefs.remove(_onboardingKey);
  }

  String? _readString(String key) {
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null; // stored with an unexpected type
    }
  }

  Object? _decode(String key) {
    final text = _readString(key);
    if (text == null) return null;
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }
}
