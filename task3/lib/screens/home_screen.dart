import 'package:flutter/material.dart';
import 'package:task3/screens/activity_history_screen.dart';
import 'package:task3/screens/weekly_progress_screen.dart';
import 'package:task3/services/activity_recognition_service.dart';
import '../services/step_counter_service.dart';
import '../models/fitness_entry.dart';
import '../services/fitness_storage.dart';
import 'add_activity_screen.dart';
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final FitnessStorage _storage = FitnessStorage();
  final ActivityRecognitionService _activityService = ActivityRecognitionService();
  String _detectedActivity = 'Unknown';
  final StepCounterService _stepCounterService = StepCounterService();
  int _automaticSteps = 0;
  List<FitnessEntry> _entries = [];
  bool _isLoading = true;
  static const int stepGoal = 10000;
  static const int calorieGoal = 500;
  static const int workoutGoal = 60;
  @override
  void initState() {
    super.initState();
    _loadEntries();
    _startStepCounter();
    _startActivityRecognition();
  }
  @override
  void dispose() {
    _activityService.dispose();
    _stepCounterService.dispose();
    super.dispose();
  }
  void _startActivityRecognition() {
    _activityService.start(
      onActivityChanged: (activity) {
        if (!mounted) return;
        setState(() {
          _detectedActivity = activity;
        });
      },
    );
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
        debugPrint('Step Counter Error: $error',);
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
  List<FitnessEntry> get _todayEntries {
    final now = DateTime.now();
    return _entries.where((entry) {
      return entry.date.year == now.year && entry.date.month == now.month && entry.date.day == now.day;
    }).toList();
  }
  int get _todaySteps {
    return _automaticSteps > 0 ? _automaticSteps : _todayEntries.fold(
      0,
          (sum, entry) => sum + entry.steps,
    );
  }
  int get _todayCalories {
    return _todayEntries.fold(
      0,
          (sum, entry) => sum + entry.calories,
    );
  }
  int get _todayWorkoutTime {
    return _todayEntries.fold(
      0,
          (sum, entry) => sum + entry.duration,
    );
  }
  double _progress(int value, int goal) {
    if (goal == 0) return 0;
    return (value / goal).clamp(0.0, 1.0);
  }
  Future<void> _addActivity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddActivityScreen(),
      ),
    );
    if (result == true) {
      await _loadEntries();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FitTrack',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyProgressScreen(),
                ),
              );
            },
            tooltip: 'Weekly Progress',
            icon: Icon(Icons.bar_chart_rounded,),),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActivityHistoryScreen(),
                ),
              );
              await _loadEntries();
            },
            tooltip: 'Activity History',
            icon: Icon(Icons.history_rounded,),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : RefreshIndicator(
        onRefresh: _loadEntries,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Text('Today',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text('Keep moving and reach your goals!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.directions_walk,
                    title: 'Steps',
                    value: '$_todaySteps',
                    subtitle: 'Goal: $stepGoal',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    title: 'Calories',
                    value: '$_todayCalories',
                    subtitle: 'Goal: $calorieGoal kcal',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer_outlined,
                    title: 'Workout',
                    value: '$_todayWorkoutTime',
                    subtitle: 'Minutes',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.fitness_center,
                    title: 'Activities',
                    value: '${_todayEntries.length}',
                    subtitle: 'Today',
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text('Daily Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 18),
            Card(
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _detectedActivity == 'Running' ? Icons.directions_run
                            : _detectedActivity == 'Walking' ? Icons.directions_walk
                            : _detectedActivity == 'Cycling' ? Icons.directions_bike
                            : Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Activity Detection',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(_detectedActivity == 'Unknown' ? 'Detecting activity...' : _detectedActivity,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 3),
                          Text('Estimated from device movement',
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
            ),
            _buildProgressCard(
              icon: Icons.directions_walk,
              title: 'Steps',
              current: _todaySteps,
              goal: stepGoal,
              unit: 'steps',
            ),
            SizedBox(height: 12),
            _buildProgressCard(
              icon: Icons.local_fire_department,
              title: 'Calories',
              current: _todayCalories,
              goal: calorieGoal,
              unit: 'kcal',
            ),
            SizedBox(height: 12),
            _buildProgressCard(
              icon: Icons.timer_outlined,
              title: 'Workout Time',
              current: _todayWorkoutTime,
              goal: workoutGoal,
              unit: 'min',
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _addActivity,
                icon: Icon(Icons.add),
                label: Text('Add Activity',),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        tooltip: 'Add Activity',
        child: Icon(Icons.add),
      ),
    );
  }
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 14),
          Text(title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 5),
          Text(value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3),
          Text(subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProgressCard({
    required IconData icon,
    required String title,
    required int current,
    required int goal,
    required String unit,
  }) {
    final progress = _progress(current, goal);
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text('$current / $goal $unit',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}