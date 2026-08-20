import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/fitness_entry.dart';
import '../services/fitness_storage.dart';
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
  final FitnessStorage _storage = FitnessStorage();
  String _selectedExercise = 'Walking';
  bool _isAutomatic = false;
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
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final entry = FitnessEntry(
      id: const Uuid().v4(),
      exerciseType: _selectedExercise,
      duration: int.parse(_durationController.text,),
      calories: int.parse(_caloriesController.text,),
      steps: int.parse(_stepsController.text,),
      date: DateTime.now(),
    );
    final entries = await _storage.getEntries();
    entries.add(entry);
    await _storage.saveEntries(entries);
    if (!mounted) return;
    Navigator.pop(context, true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Activity',
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
              Text('Log Your Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Add your workout details to track your progress.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: SwitchListTile(
                  value: _isAutomatic,
                  onChanged: (value) {
                    setState(() {
                      _isAutomatic = value;
                    });
                  },
                  title: Text('Automatic Tracking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('Track your activity automatically using your device sensors.',),
                  secondary: Icon(Icons.sensors_rounded,),
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
                items: _exerciseTypes.map((exercise) => DropdownMenuItem(
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter workout duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter calories burned';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter steps';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveActivity,
                  icon: Icon(Icons.check_rounded,),
                  label: Text('Save Activity',),
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
                  child: Text('Cancel',),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}