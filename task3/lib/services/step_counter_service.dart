import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
class StepCounterService {
  StreamSubscription<StepCount>? _subscription;
  int _baseSteps = 0;
  int _todaySteps = 0;
  int get todaySteps => _todaySteps;
  Future<void> start({
    required void Function(int steps) onStepsChanged,
    required void Function(String error) onError,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final savedDate = prefs.getString('step_counter_date');
    final hasBase = prefs.containsKey('step_counter_base');
    if (savedDate != today || !hasBase) {
      _baseSteps = 0;
      _todaySteps = 0;
      await prefs.setString(
        'step_counter_date',
        today,
      );
      await prefs.setInt(
        'step_counter_base',
        0,
      );
      await prefs.setBool(
        'step_counter_initialized',
        false,
      );
    } else {
      _baseSteps = prefs.getInt('step_counter_base') ?? 0;
      _todaySteps = prefs.getInt('step_counter_today') ?? 0;
    }
    final initialized = prefs.getBool('step_counter_initialized') ?? false;
    _subscription?.cancel();
    _subscription = Pedometer.stepCountStream.listen(
              (StepCount event) async {
            if (!initialized && !prefs.containsKey('step_counter_initialized')) {
              _baseSteps = event.steps;
              await prefs.setInt(
                'step_counter_base',
                _baseSteps,
              );
              await prefs.setBool(
                'step_counter_initialized',
                true,
              );
              _todaySteps = 0;
              onStepsChanged(_todaySteps);
              return;
            }
            if (!prefs.getBool('step_counter_initialized',)!) {
              _baseSteps = event.steps;
              await prefs.setInt(
                'step_counter_base',
                _baseSteps,
              );
              await prefs.setBool(
                'step_counter_initialized',
                true,
              );
              _todaySteps = 0;
              onStepsChanged(_todaySteps);
              return;
            }
            _todaySteps = event.steps - _baseSteps;
            if (_todaySteps < 0) {_todaySteps = 0;}
            await prefs.setInt(
              'step_counter_today',
              _todaySteps,
            );
            onStepsChanged(_todaySteps);
          },
          onError: (error) {
            onError('Step counter is not available on this device.',);
          },
          cancelOnError: false,
        );
  }
  String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}