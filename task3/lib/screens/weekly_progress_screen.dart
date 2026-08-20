import 'package:flutter/material.dart';
import '../services/step_counter_service.dart';
import '../models/fitness_entry.dart';
import '../services/fitness_storage.dart';
class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});
  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}
class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  final FitnessStorage _storage = FitnessStorage();
  final StepCounterService _stepCounterService = StepCounterService();
  int _automaticSteps = 0;
  List<FitnessEntry> _entries = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadEntries();
    _startStepCounter();
  }
  @override
  void dispose() {
    _stepCounterService.dispose();
    super.dispose();
  }
  void _startStepCounter() {
    _stepCounterService.start(
      onStepsChanged: (steps) {
        if (!mounted) return;
        setState(() {
          _automaticSteps = steps;
        });
      },
      onError: (error) {
        debugPrint('Step Counter Error: $error');
      },
    );
  }
  Future<void> _loadEntries() async {
    final entries = await _storage.getEntries();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }
  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }
  List<FitnessEntry> _entriesForDay(
      DateTime day,) {
    return _entries.where((entry) {
      final entryDate = _dateOnly(entry.date);
      final targetDate = _dateOnly(day);
      return entryDate == targetDate;
    }).toList();
  }
  int _stepsForDay(DateTime day) {
    final steps = _entriesForDay(day).fold(
      0,
          (sum, entry) => sum + entry.steps,
    );
    final today = _dateOnly(DateTime.now());
    final targetDay = _dateOnly(day);
    if (targetDay == today) {
      return _automaticSteps > 0 ? _automaticSteps : steps;
    }
    return steps;
  }
  int _caloriesForDay(DateTime day) {
    return _entriesForDay(day).fold(
      0,
          (sum, entry) => sum + entry.calories,
    );
  }
  int _durationForDay(DateTime day) {
    return _entriesForDay(day).fold(
      0,
          (sum, entry) => sum + entry.duration,
    );
  }
  int get _weeklySteps {
    return _lastSevenDays.fold(
      0,
          (sum, day) => sum + _stepsForDay(day),
    );
  }
  int get _weeklyCalories {
    return _lastSevenDays.fold(
      0,
          (sum, day) => sum + _caloriesForDay(day),
    );
  }
  int get _weeklyDuration {
    return _lastSevenDays.fold(
      0,
          (sum, day) => sum + _durationForDay(day),
    );
  }
  List<DateTime> get _lastSevenDays {
    final today = DateTime.now();
    return List.generate(
      7,
          (index) => DateTime(
        today.year,
        today.month,
        today.day - (6 - index),
      ),
    );
  }
  String _dayName(DateTime date) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return days[date.weekday - 1];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) : ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('Last 7 Days',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text('Track your activity and stay consistent.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.directions_walk,
                  title: 'Steps',
                  value: '$_weeklySteps',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.local_fire_department,
                  title: 'Calories',
                  value: '$_weeklyCalories',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildSummaryCard(
            icon: Icons.timer_outlined,
            title: 'Workout Time',
            value: '$_weeklyDuration min',
          ),
          SizedBox(height: 30),
          Text('Daily Steps',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 18),
          _buildChart(),
          SizedBox(height: 30),
          Text('Daily Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          ..._lastSevenDays.map((day) => _buildDayCard(day),
          ),
        ],
      ),
    );
  }
  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 4),
                  Text(value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildChart() {
    final values = _lastSevenDays.map(_stepsForDay).toList();
    final maxValue = values.fold<int>(
      1000,
          (max, value) => value > max ? value : max,
    );
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          15,
          25,
          15,
          15,
        ),
        child: SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_lastSevenDays.length,
                  (index) {
                final value = values[index];
                final height = value == 0 ? 8.0 : 150 * (value / maxValue);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$value',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: 6),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                8,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _dayName(_lastSevenDays[index],),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDayCard(DateTime day) {
    final steps = _stepsForDay(day);
    final calories = _caloriesForDay(day);
    final duration = _durationForDay(day);
    final isToday = _dateOnly(day) == _dateOnly(DateTime.now());
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_dayName(day),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isToday ? 'Today' : '${day.day}/${day.month}/${day.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '$steps steps • '
                        '$calories kcal • '
                        '$duration min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}