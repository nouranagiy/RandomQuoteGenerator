import 'package:flutter/material.dart';
import '../../generated/l10n/app_localizations.dart';

class ExerciseTypes {
  ExerciseTypes._();

  static const List<String> values = [
    'Walking',
    'Running',
    'Cycling',
    'Gym',
    'Swimming',
    'Yoga',
    'Other',
  ];

  static String label(String key, AppLocalizations l10n) {
    switch (key) {
      case 'Walking':
        return l10n.walking;
      case 'Running':
        return l10n.running;
      case 'Cycling':
        return l10n.cycling;
      case 'Gym':
        return l10n.gym;
      case 'Swimming':
        return l10n.swimming;
      case 'Yoga':
        return l10n.yoga;
      default:
        return l10n.other;
    }
  }

  static String keyFromLabel(String label, AppLocalizations l10n) {
    for (final value in values) {
      if (label == ExerciseTypes.label(value, l10n)) {
        return value;
      }
    }
    return 'Other';
  }

  static IconData icon(String key) {
    switch (key) {
      case 'Walking':
        return Icons.directions_walk;
      case 'Running':
        return Icons.directions_run;
      case 'Cycling':
        return Icons.directions_bike;
      case 'Gym':
        return Icons.fitness_center;
      case 'Swimming':
        return Icons.pool;
      case 'Yoga':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }
}
