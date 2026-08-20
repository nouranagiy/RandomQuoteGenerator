import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
class ActivityRecognitionService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  String _currentActivity = 'Unknown';
  String get currentActivity => _currentActivity;
  void start({
    required void Function(String activity) onActivityChanged,
  }) {
    _subscription = accelerometerEventStream(
      samplingPeriod: Duration(milliseconds: 300,),
    ).listen((event) {
        final magnitude = sqrt(
          event.x * event.x +
              event.y * event.y +
              event.z * event.z,
        );
        final movement = (magnitude - 9.8).abs();
        String activity;
        if (movement < 1.2) {
          activity = 'Still';
        } else if (movement < 3.0) {
          activity = 'Walking';
        } else if (movement < 6.0) {
          activity = 'Running';
        } else {
          activity = 'Other';
        }
        if (activity != _currentActivity) {
          _currentActivity = activity;
          onActivityChanged(activity);
        }
      },
      onError: (_) {
        _currentActivity = 'Unknown';
        onActivityChanged('Unknown');
      },
    );
  }
  void dispose() {
    _subscription?.cancel();
  }
}