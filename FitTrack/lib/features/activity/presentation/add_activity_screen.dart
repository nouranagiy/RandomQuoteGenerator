import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/exercise_types.dart';
import '../../../models/fitness_entry.dart';
import '../data/repositories/activity_repository.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _stepsController = TextEditingController();
  final ActivityRepository _repository = ActivityRepository();
  String _selectedExercise = ExerciseTypes.values.first;
  bool _isAutomatic = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);

    final entry = FitnessEntry(
      id: const Uuid().v4(),
      exerciseType: _selectedExercise,
      duration: int.parse(_durationController.text),
      calories: int.parse(_caloriesController.text),
      steps: int.parse(_stepsController.text),
      date: DateTime.now(),
    );

    try {
      await _repository.addActivity(entry);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ActivityStorageException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.saveActivityError}: ${e.message}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addActivityTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.logYourActivity,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.addWorkoutDetails,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Card(
                child: SwitchListTile(
                  value: _isAutomatic,
                  onChanged: (value) => setState(() => _isAutomatic = value),
                  title: Text(
                    l10n.automaticTracking,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(l10n.automaticTrackingDesc),
                  secondary: const Icon(Icons.sensors_rounded),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                l10n.exerciseType,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _selectedExercise,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.fitness_center, size: 20),
                ),
                items: ExerciseTypes.values
                    .map((exercise) => DropdownMenuItem(
                          value: exercise,
                          child: Text(ExerciseTypes.label(exercise, l10n)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedExercise = value);
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.workoutDuration,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _durationController,
                hintText: l10n.durationHint,
                suffixText: l10n.min,
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.errorFieldRequired;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.errorInvalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.caloriesBurned,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _caloriesController,
                hintText: l10n.caloriesHint,
                suffixText: l10n.kcal,
                prefixIcon: Icons.local_fire_department,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.errorFieldRequired;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.errorInvalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.stepsLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _stepsController,
                hintText: l10n.stepsHint,
                prefixIcon: Icons.directions_walk,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.errorFieldRequired;
                  }
                  if (int.tryParse(value) == null) {
                    return l10n.errorInvalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.saveActivity,
                onPressed: _saveActivity,
                icon: Icons.check_rounded,
                isLoading: _isSaving,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.cancel,
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
