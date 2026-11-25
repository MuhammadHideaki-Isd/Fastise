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

  String get label => '$fastingHours:$eatingHours';
}
