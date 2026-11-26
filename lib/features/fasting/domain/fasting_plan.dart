class FastingPlan {
  const FastingPlan({
    required this.id,
    required this.name,
    required this.fastingHours,
    required this.eatingHours,
  });

  final String id;
  final String name;
  final int fastingHours;
  final int eatingHours;

  Duration get fastingDuration => Duration(hours: fastingHours);

  static const presets = <FastingPlan>[
    FastingPlan(id: '14-10', name: '14:10', fastingHours: 14, eatingHours: 10),
    FastingPlan(id: '16-8', name: '16:8', fastingHours: 16, eatingHours: 8),
    FastingPlan(id: '18-6', name: '18:6', fastingHours: 18, eatingHours: 6),
    FastingPlan(id: '20-4', name: '20:4', fastingHours: 20, eatingHours: 4),
  ];

  static const defaultPlan = FastingPlan(
    id: '16-8',
    name: '16:8',
    fastingHours: 16,
    eatingHours: 8,
  );

  /// Returns null for unknown ids (e.g. malformed stored data).
  static FastingPlan? byId(String? id) {
    for (final plan in presets) {
      if (plan.id == id) return plan;
    }
    return null;
  }
}
