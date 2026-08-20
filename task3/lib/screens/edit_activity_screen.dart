import 'package:flutter/material.dart';
import '../models/fitness_entry.dart';
import '../services/fitness_storage.dart';
class EditActivityScreen extends StatefulWidget {
  final FitnessEntry entry;
  const EditActivityScreen({
    super.key,
    required this.entry,
  });
  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}
class _EditActivityScreenState extends State<EditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _durationController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _stepsController;
  final FitnessStorage _storage = FitnessStorage();
  late String _selectedExercise;
  final List<String> _exerciseTypes = [
    'Walking',
    'Running',
    'Cycling',
    'Gym',
    'Swimming',
    'Yoga',
    'Other',
  ];
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final entries = await _storage.getEntries();
    final index = entries.indexWhere((entry) => entry.id == widget.entry.id,
    );
    if (index == -1) return;
    entries[index] = FitnessEntry(
      id: widget.entry.id,
      exerciseType: _selectedExercise,
      duration: int.parse(_durationController.text.trim(),),
      calories: int.parse(_caloriesController.text.trim(),),
      steps: int.parse(_stepsController.text.trim(),),
      date: widget.entry.date,
    );
    await _storage.saveEntries(entries);
    if (!mounted) return;
    Navigator.pop(context, true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Activity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Change your activity details and save the updates.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 30),
              Text('Exercise Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedExercise,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.fitness_center,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: _exerciseTypes.map((exercise) => DropdownMenuItem<String>(
                        value: exercise,
                        child: Text(exercise),
                      ),
                ).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedExercise = value;
                  });
                },
              ),
              SizedBox(height: 22),
              Text('Workout Duration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 30',
                  suffixText: 'min',
                  prefixIcon: Icon(Icons.timer_outlined,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: _validateNumber,
              ),
              SizedBox(height: 22),
              Text('Calories Burned',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 250',
                  suffixText: 'kcal',
                  prefixIcon: Icon(Icons.local_fire_department,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: _validateNumber,
              ),
              SizedBox(height: 22),
              Text('Steps',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 3000',
                  suffixText: 'steps',
                  prefixIcon: Icon(Icons.directions_walk,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: _validateNumber,
              ),
              SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _updateActivity,
                  icon: Icon(Icons.save_outlined,),
                  label: Text('Save Changes',),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a value';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    if (number < 0) {
      return 'Value cannot be negative';
    }
    return null;
  }
}