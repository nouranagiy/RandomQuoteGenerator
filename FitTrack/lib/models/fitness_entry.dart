import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Serializes this entry for storage in a Firestore document at
  /// `users/{uid}/activities/{activityId}`.
  Map<String, dynamic> toFirestore() {
    return {
      'exerciseType': exerciseType,
      'duration': duration,
      'calories': calories,
      'steps': steps,
      'date': date.toIso8601String(),
    };
  }

  /// Builds an entry from a Firestore document under
  /// `users/{uid}/activities/{activityId}`. The document ID is the entry id.
  factory FitnessEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return FitnessEntry(
      id: doc.id,
      exerciseType: data['exerciseType'] ?? 'Workout',
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      steps: (data['steps'] as num?)?.toInt() ?? 0,
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
    );
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