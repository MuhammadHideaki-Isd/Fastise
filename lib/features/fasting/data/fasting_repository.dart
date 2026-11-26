import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/fasting_plan.dart';
import '../domain/fasting_session.dart';

abstract interface class StringStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesStringStore implements StringStore {
  SharedPreferencesStringStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) async {
    try {
      return await _preferences.getString(key);
    } on PlatformException catch (error) {
      throw FastingStorageException('Could not read local app data.', error);
    } on MissingPluginException catch (error) {
      throw FastingStorageException('Local storage is unavailable.', error);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _preferences.setString(key, value);
    } on PlatformException catch (error) {
      throw FastingStorageException('Could not save local app data.', error);
    } on MissingPluginException catch (error) {
      throw FastingStorageException('Local storage is unavailable.', error);
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _preferences.remove(key);
    } on PlatformException catch (error) {
      throw FastingStorageException('Could not clear local app data.', error);
    } on MissingPluginException catch (error) {
      throw FastingStorageException('Local storage is unavailable.', error);
    }
  }
}

class FastingStorageException implements Exception {
  const FastingStorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class FastingAppData {
  const FastingAppData({
    required this.selectedPlan,
    required this.sessions,
    this.glassEffectEnabled = true,
  });

  static const defaultPlan = FastingPlan(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );

  final FastingPlan selectedPlan;
  final List<FastingSession> sessions;
  final bool glassEffectEnabled;

  FastingSession? get activeSession {
    for (final session in sessions) {
      if (session.status == FastingSessionStatus.active) {
        return session;
      }
    }
    return null;
  }

  List<FastingSession> get completedSessions => List.unmodifiable(
    sessions.where(
      (session) => session.status == FastingSessionStatus.completed,
    ),
  );

  Map<String, Object?> toJson() => {
    'version': 1,
    'selectedPlan': selectedPlan.toJson(),
    'sessions': sessions.map((session) => session.toJson()).toList(),
    'glassEffectEnabled': glassEffectEnabled,
  };

  factory FastingAppData.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Saved app data has an unsupported version.');
    }

    final selectedPlanData = json['selectedPlan'];
    final sessionsData = json['sessions'];
    final glassEffectEnabled = json['glassEffectEnabled'];
    if (selectedPlanData is! Map ||
        sessionsData is! List ||
        sessionsData.any((item) => item is! Map) ||
        (glassEffectEnabled != null && glassEffectEnabled is! bool)) {
      throw const FormatException('Saved app data has an invalid structure.');
    }

    final plan = FastingPlan.fromJson(
      Map<String, dynamic>.from(selectedPlanData),
    );
    final sessions = sessionsData
        .map(
          (item) =>
              FastingSession.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    final ids = sessions.map((session) => session.id).toSet();
    final activeCount = sessions
        .where((session) => session.status == FastingSessionStatus.active)
        .length;

    if (ids.length != sessions.length || activeCount > 1) {
      throw const FormatException('Saved sessions violate state constraints.');
    }

    return FastingAppData(
      selectedPlan: plan,
      sessions: sessions,
      glassEffectEnabled: glassEffectEnabled as bool? ?? true,
    );
  }
}

class FastingRepository {
  FastingRepository({StringStore? store})
    : _store = store ?? SharedPreferencesStringStore();

  static const _storageKey = 'fastise.app_data.v1';
  final StringStore _store;

  Future<FastingAppData> load() async {
    final value = await _store.read(_storageKey);
    if (value == null) {
      return const FastingAppData(
        selectedPlan: FastingAppData.defaultPlan,
        sessions: [],
      );
    }

    final decoded = jsonDecode(value);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved app data must be a JSON object.');
    }
    return FastingAppData.fromJson(decoded);
  }

  Future<void> save(FastingAppData data) async {
    await _store.write(_storageKey, jsonEncode(data.toJson()));
  }

  Future<void> clear() => _store.remove(_storageKey);
}
