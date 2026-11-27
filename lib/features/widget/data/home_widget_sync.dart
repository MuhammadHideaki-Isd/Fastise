import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/formatters.dart';
import '../../fasting/application/fasting_controller.dart';
import '../../fasting/domain/fasting_session.dart';
import '../../fasting/domain/fasting_stats.dart';

/// Mood states driving the Duolingo-inspired home screen widget mascot,
/// accent color, and motivational micro-copy.
enum WidgetMood {
  idle('idle'),
  fasting('fasting'),
  targetReached('target_reached'),
  doneToday('done_today');

  const WidgetMood(this.wireValue);
  final String wireValue;
}

class WidgetSnapshot {
  const WidgetSnapshot({
    required this.mood,
    required this.headline,
    required this.subtext,
    required this.actionLabel,
    required this.planName,
    required this.fastingHours,
    required this.streakDays,
    required this.startAtEpochMs,
    required this.targetEndEpochMs,
    required this.progressPercent,
    required this.lastDurationLabel,
  });

  final WidgetMood mood;
  final String headline;
  final String subtext;
  final String actionLabel;
  final String planName;
  final int fastingHours;
  final int streakDays;
  final int startAtEpochMs;
  final int targetEndEpochMs;
  final int progressPercent;
  final String lastDurationLabel;

  factory WidgetSnapshot.fromController(FastingController controller) {
    final now = controller.now();
    final plan = controller.selectedPlan;
    final active = controller.activeSession;
    final streak = currentStreakDays(
      controller.sessions,
      now,
      activeSession: active,
    );

    if (active != null) {
      final reached = active.reachedTarget(now);
      final pct = (active.progress(now) * 100).round().clamp(0, 100);
      return WidgetSnapshot(
        mood: reached ? WidgetMood.targetReached : WidgetMood.fasting,
        headline: reached ? 'Goal reached!' : 'Fasting · ${active.planNameSnapshot}',
        subtext: reached
            ? 'End whenever you feel ready'
            : 'Target ${formatWhen(active.targetEndAt, now)}',
        actionLabel: reached ? 'Wrap Up' : 'Live Timer',
        planName: active.planNameSnapshot,
        fastingHours: (active.plannedDurationMinutes / 60).round(),
        streakDays: streak,
        startAtEpochMs: active.startAt.millisecondsSinceEpoch,
        targetEndEpochMs: active.targetEndAt.millisecondsSinceEpoch,
        progressPercent: pct,
        lastDurationLabel: '',
      );
    }

    final completedToday = [
      for (final s in controller.sessions)
        if (s.status == SessionStatus.completed &&
            (isSameDay(s.startAt, now) ||
                (s.endAt != null && isSameDay(s.endAt!, now))))
          s,
    ];

    if (completedToday.isNotEmpty) {
      final latest = completedToday.first;
      final durationText = formatDuration(latest.actualDuration);
      return WidgetSnapshot(
        mood: WidgetMood.doneToday,
        headline: 'Great job today!',
        subtext: 'Logged $durationText · ${latest.planNameSnapshot}',
        actionLabel: 'New Fast',
        planName: plan.name,
        fastingHours: plan.fastingHours,
        streakDays: streak,
        startAtEpochMs: 0,
        targetEndEpochMs: 0,
        progressPercent: 100,
        lastDurationLabel: durationText,
      );
    }

    return WidgetSnapshot(
      mood: WidgetMood.idle,
      headline: streak > 0 ? 'Keep your streak!' : 'Ready to fast?',
      subtext: '${plan.name} · ${plan.fastingHours} h goal',
      actionLabel: 'Start Fast',
      planName: plan.name,
      fastingHours: plan.fastingHours,
      streakDays: streak,
      startAtEpochMs: 0,
      targetEndEpochMs: 0,
      progressPercent: 0,
      lastDurationLabel: '',
    );
  }

  Map<String, Object?> toMap() => {
    'mood': mood.wireValue,
    'headline': headline,
    'subtext': subtext,
    'actionLabel': actionLabel,
    'planName': planName,
    'fastingHours': fastingHours,
    'streakDays': streakDays,
    'startAtEpochMs': startAtEpochMs,
    'targetEndEpochMs': targetEndEpochMs,
    'progressPercent': progressPercent,
    'lastDurationLabel': lastDurationLabel,
  };
}

/// Bridges Flutter fasting state to the native Android AppWidgetProvider.
class HomeWidgetSync {
  HomeWidgetSync({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName = 'com.example.fastise/widget';
  static final HomeWidgetSync instance = HomeWidgetSync();

  final MethodChannel _channel;

  Future<void> sync(FastingController controller) async {
    if (kIsWeb) return;
    final snapshot = WidgetSnapshot.fromController(controller);
    try {
      await _channel.invokeMethod<void>('updateWidget', snapshot.toMap());
    } on MissingPluginException {
      // Expected in host widget/unit tests and unsupported platforms.
    } on PlatformException {
      // Never surface background widget sync errors to the fasting flow.
    }
  }

  Future<bool> requestPinWidget() async {
    if (kIsWeb) return false;
    try {
      final supported = await _channel.invokeMethod<bool>('requestPinWidget');
      return supported ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
