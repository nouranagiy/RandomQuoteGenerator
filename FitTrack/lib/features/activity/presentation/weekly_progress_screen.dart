import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/fitness_entry.dart';
import '../../../services/step_counter_service.dart';
import '../data/repositories/activity_repository.dart';
import '../../../widgets/loading_widget.dart';

class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  final ActivityRepository _repository = ActivityRepository();
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
        setState(() => _automaticSteps = steps);
      },
      onError: (error) => debugPrint('Step Counter Error: $error'),
    );
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _repository.getActivities();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } on ActivityStorageException {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<FitnessEntry> _entriesForDay(DateTime day) {
    final target = _dateOnly(day);
    return _entries.where((e) => _dateOnly(e.date) == target).toList();
  }

  int _stepsForDay(DateTime day) {
    final steps = _entriesForDay(day).fold(0, (sum, e) => sum + e.steps);
    if (_dateOnly(day) == _dateOnly(DateTime.now())) {
      return _automaticSteps > 0 ? _automaticSteps : steps;
    }
    return steps;
  }

  int _caloriesForDay(DateTime day) =>
      _entriesForDay(day).fold(0, (sum, e) => sum + e.calories);

  int _durationForDay(DateTime day) =>
      _entriesForDay(day).fold(0, (sum, e) => sum + e.duration);

  List<DateTime> get _lastSevenDays {
    final today = DateTime.now();
    return List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day - (6 - i)),
    );
  }

  int get _weeklySteps =>
      _lastSevenDays.fold(0, (sum, day) => sum + _stepsForDay(day));

  int get _weeklyCalories =>
      _lastSevenDays.fold(0, (sum, day) => sum + _caloriesForDay(day));

  int get _weeklyDuration =>
      _lastSevenDays.fold(0, (sum, day) => sum + _durationForDay(day));

  String _dayName(DateTime date, AppLocalizations l10n) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final key = keys[date.weekday - 1];
    switch (key) {
      case 'mon':
        return l10n.mon;
      case 'tue':
        return l10n.tue;
      case 'wed':
        return l10n.wed;
      case 'thu':
        return l10n.thu;
      case 'fri':
        return l10n.fri;
      case 'sat':
        return l10n.sat;
      default:
        return l10n.sun;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weeklyProgress),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text(
                  l10n.last7Days,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.trackConsistent,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.directions_walk,
                        title: l10n.steps,
                        value: '$_weeklySteps',
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.local_fire_department,
                        title: l10n.calories,
                        value: '$_weeklyCalories',
                        theme: theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSummaryCard(
                  icon: Icons.timer_outlined,
                  title: l10n.workoutTimeTitle,
                  value: '$_weeklyDuration ${l10n.min}',
                  theme: theme,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  l10n.dailySteps,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildChart(l10n, theme),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  l10n.dailySummary,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ..._lastSevenDays.map(
                  (day) => _buildDayCard(day, l10n, theme),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
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

  Widget _buildChart(AppLocalizations l10n, ThemeData theme) {
    final values = _lastSevenDays.map(_stepsForDay).toList();
    final maxValue = values.fold<int>(1000, (max, v) => v > max ? v : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xxl,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_lastSevenDays.length, (index) {
              final value = values[index];
              final height = value == 0 ? 8.0 : 140 * (value / maxValue);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$value',
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _dayName(_lastSevenDays[index], l10n),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(
    DateTime day,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final steps = _stepsForDay(day);
    final calories = _caloriesForDay(day);
    final duration = _durationForDay(day);
    final isToday = _dateOnly(day) == _dateOnly(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                _dayName(day, l10n),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday
                        ? l10n.today
                        : '${day.day}/${day.month}/${day.year}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$steps ${l10n.steps.toLowerCase()} • '
                    '$calories ${l10n.kcal} • '
                    '$duration ${l10n.min}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
