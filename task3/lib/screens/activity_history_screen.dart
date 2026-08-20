import 'package:flutter/material.dart';
import 'package:task3/screens/add_activity_screen.dart';
import 'package:task3/screens/edit_activity_screen.dart';
import '../models/fitness_entry.dart';
import '../services/fitness_storage.dart';
class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});
  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}
class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final FitnessStorage _storage = FitnessStorage();
  List<FitnessEntry> _entries = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }
  Future<void> _loadEntries() async {
    final entries = await _storage.getEntries();
    entries.sort((a, b) => b.date.compareTo(a.date),
    );
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }
  Future<void> _deleteActivity(
      FitnessEntry entry,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Activity'),
          content: Text('Are you sure you want to delete this activity?',),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) return;
    _entries.removeWhere((item) => item.id == entry.id,
    );
    await _storage.saveEntries(_entries);
    if (!mounted) return;
    setState(() {});
  }
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
  IconData _getExerciseIcon(String exercise) {
    switch (exercise) {
      case 'Walking':return Icons.directions_walk;
      case 'Running':return Icons.directions_run;
      case 'Cycling':return Icons.directions_bike;
      case 'Gym':return Icons.fitness_center;
      case 'Swimming':return Icons.pool;
      case 'Yoga':return Icons.self_improvement;
      default:return Icons.sports;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : _entries.isEmpty ? _buildEmptyState() : ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: _entries.length,
        separatorBuilder: (_, _) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return _buildActivityCard(entry);
        },
      ),
    );
  }
  Widget _buildActivityCard(
      FitnessEntry entry,) {
    final exerciseIcon = _getExerciseIcon(entry.exerciseType);
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(exerciseIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.exerciseType,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(entry.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditActivityScreen(
                              entry: entry,
                            ),
                      ),
                    );
                    if (result == true) {
                      await _loadEntries();
                    }
                  },
                  tooltip: 'Edit',
                  icon: Icon(Icons.edit_outlined,),
                ),
                IconButton(
                  onPressed: () {
                    _deleteActivity(entry);
                  },
                  tooltip: 'Delete',
                  icon: Icon(Icons.delete_outline,),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.timer_outlined,
                    value: '${entry.duration} min',
                    label: 'Duration',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.local_fire_department,
                    value: '${entry.calories} kcal',
                    label: 'Calories',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.directions_walk,
                    value: '${entry.steps}',
                    label: 'Steps',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 6),
        Text(value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 25),
            Text('No Activities Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Start tracking your activities and they will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddActivityScreen(),
                  ),
                );
                if (result == true) {
                  await _loadEntries();
                }
              },
              icon: Icon(Icons.add),
              label: Text('Add Activity',),
            ),
          ],
        ),
      ),
    );
  }
}