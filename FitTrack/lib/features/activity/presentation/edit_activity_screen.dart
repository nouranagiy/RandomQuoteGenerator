import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/exercise_types.dart';
import '../../../models/fitness_entry.dart';
import '../data/repositories/activity_repository.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class EditActivityScreen extends StatefulWidget {
  final FitnessEntry entry;
  const EditActivityScreen({super.key, required this.entry});

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _durationController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _stepsController;
  final ActivityRepository _repository = ActivityRepository();
  late String _selectedExercise;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedExercise = widget.entry.exerciseType;
    _durationController = TextEditingController(
      text: widget.entry.duration.toString(),
    );
    _caloriesController = TextEditingController(
      text: widget.entry.calories.toString(),
    );
    _stepsController = TextEditingController(
      text: widget.entry.steps.toString(),
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);

    final updated = FitnessEntry(
      id: widget.entry.id,
      exerciseType: _selectedExercise,
      duration: int.parse(_durationController.text.trim()),
      calories: int.parse(_caloriesController.text.trim()),
      steps: int.parse(_stepsController.text.trim()),
      date: widget.entry.date,
    );

    try {
      await _repository.updateActivity(updated);
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
        title: Text(l10n.editActivity),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.updateActivity,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.changeDetails,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
                validator: _validateNumber,
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
                validator: _validateNumber,
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
                validator: _validateNumber,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.saveChanges,
                onPressed: _updateActivity,
                icon: Icons.save_outlined,
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

  String? _validateNumber(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.errorFieldRequired;
    }
    final number = int.tryParse(value.trim());
    if (number == null) return l10n.errorInvalidNumber;
    return null;
  }
}
