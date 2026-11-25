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

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'fastingHours': fastingHours,
    'eatingHours': eatingHours,
  };

  factory FastingPlan.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final fastingHours = json['fastingHours'];
    final eatingHours = json['eatingHours'];

    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        name.isEmpty ||
        fastingHours is! int ||
        eatingHours is! int ||
        fastingHours <= 0 ||
        eatingHours <= 0) {
      throw const FormatException('Saved fasting plan is invalid.');
    }

    return FastingPlan(
      id: id,
      name: name,
      fastingHours: fastingHours,
      eatingHours: eatingHours,
    );
  }
}
