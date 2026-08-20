class FitnessEntry {
  final String id;
  String exerciseType;
  int duration;
  int calories;
  int steps;
  DateTime date;
  FitnessEntry({
    required this.id,
    required this.exerciseType,
    required this.duration,
    required this.calories,
    required this.steps,
    required this.date,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseType': exerciseType,
      'duration': duration,
      'calories': calories,
      'steps': steps,
      'date': date.toIso8601String(),
    };
  }
  factory FitnessEntry.fromMap(
      Map<String, dynamic> map,) {
    return FitnessEntry(
      id: map['id'] ?? '',
      exerciseType:
      map['exerciseType'] ?? 'Workout',
      duration: map['duration'] ?? 0,
      calories: map['calories'] ?? 0,
      steps: map['steps'] ?? 0,
      date: DateTime.tryParse(
        map['date'] ?? '',
      ) ?? DateTime.now(),
    );
  }
}