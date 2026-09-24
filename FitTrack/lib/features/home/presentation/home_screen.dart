import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../models/fitness_entry.dart';
import '../../activity/data/repositories/activity_repository.dart';
import '../../../services/activity_recognition_service.dart';
import '../../../services/step_counter_service.dart';
import '../../../widgets/welcome_header.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/progress_card.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityRepository _repository = ActivityRepository();
  final ActivityRecognitionService _activityService = ActivityRecognitionService();
  final StepCounterService _stepCounterService = StepCounterService();
  String _detectedActivity = 'Unknown';
  int _automaticSteps = 0;
  List<FitnessEntry> _entries = [];
  bool _isLoading = true;
  bool _stepCounterAvailable = true;

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
        setState(() => _detectedActivity = activity);
      },
    );
  }

  void _startStepCounter() {
    _stepCounterService.start(
      onStepsChanged: (steps) {
        if (!mounted) return;
        setState(() {
          _automaticSteps = steps;
          _stepCounterAvailable = true;
        });
      },
      onError: (error) {
        debugPrint('Step Counter Error: $error');
        if (mounted) {
          setState(() => _stepCounterAvailable = false);
        }
      },
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

  List<FitnessEntry> get _todayEntries {
    final now = DateTime.now();
    return _entries.where((entry) {
      return entry.date.year == now.year &&
          entry.date.month == now.month &&
          entry.date.day == now.day;
    }).toList();
  }

  int get _todaySteps => _automaticSteps > 0
      ? _automaticSteps
      : _todayEntries.fold(0, (sum, entry) => sum + entry.steps);

  int get _todayCalories =>
      _todayEntries.fold(0, (sum, entry) => sum + entry.calories);

  int get _todayWorkoutTime =>
      _todayEntries.fold(0, (sum, entry) => sum + entry.duration);

  IconData _getActivityIcon(String activity) {
    switch (activity) {
      case 'Running':
        return Icons.directions_run;
      case 'Walking':
        return Icons.directions_walk;
      case 'Cycling':
        return Icons.directions_bike;
      default:
        return Icons.fitness_center;
    }
  }

  String _localizeActivity(String activity, AppLocalizations l10n) {
    switch (activity) {
      case 'Walking':
        return l10n.walking;
      case 'Running':
        return l10n.running;
      case 'Cycling':
        return l10n.cycling;
      case 'Still':
        return l10n.still;
      default:
        return l10n.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  size: 18,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'FitTrack',
                    maxLines: 1,
                    softWrap: false,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.weeklyProgress),
            tooltip: l10n.weeklyProgress,
            icon: const Icon(Icons.bar_chart_rounded, size: 22),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, AppRouter.activityHistory);
              await _loadEntries();
            },
            tooltip: l10n.activityHistory,
            icon: const Icon(Icons.history_rounded, size: 22),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.settingsPage),
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  const WelcomeHeader(),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildStatCards(l10n, theme),
                  const SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: l10n.dailyProgress,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildActivityDetection(l10n, theme),
                  if (!_stepCounterAvailable) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildStepCounterNotice(l10n, theme),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  ProgressCard(
                    icon: Icons.directions_walk,
                    title: l10n.stepsTitle,
                    current: _todaySteps,
                    goal: stepGoal,
                    unit: l10n.steps.toLowerCase(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProgressCard(
                    icon: Icons.local_fire_department,
                    title: l10n.caloriesTitle,
                    current: _todayCalories,
                    goal: calorieGoal,
                    unit: l10n.kcal,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProgressCard(
                    icon: Icons.timer_outlined,
                    title: l10n.workoutTime,
                    current: _todayWorkoutTime,
                    goal: workoutGoal,
                    unit: l10n.min,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.pushNamed(
                            context, AppRouter.addActivity);
                        if (result == true) await _loadEntries();
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: Text(l10n.addActivity),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, AppRouter.addActivity);
          if (result == true) await _loadEntries();
        },
        tooltip: l10n.addActivity,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCards(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.directions_walk,
                title: l10n.steps,
                value: '$_todaySteps',
                subtitle: l10n.goal(stepGoal.toString()),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                icon: Icons.local_fire_department,
                title: l10n.calories,
                value: '$_todayCalories',
                subtitle: l10n.goal('$calorieGoal ${l10n.kcal}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.timer_outlined,
                title: l10n.workout,
                value: '$_todayWorkoutTime',
                subtitle: l10n.minutes,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                icon: Icons.fitness_center,
                title: l10n.activities,
                value: '${_todayEntries.length}',
                subtitle: l10n.todayLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityDetection(AppLocalizations l10n, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getActivityIcon(_detectedActivity),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.activityDetection,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _detectedActivity == 'Unknown'
                        ? l10n.detectingActivity
                        : _localizeActivity(_detectedActivity, l10n),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.estimatedFromDevice,
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

  Widget _buildStepCounterNotice(
      AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.stepCounterUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
