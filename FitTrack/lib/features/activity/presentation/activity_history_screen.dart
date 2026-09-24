import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/exercise_types.dart';
import '../../../models/fitness_entry.dart';
import '../data/repositories/activity_repository.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/confirmation_dialog.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final ActivityRepository _repository = ActivityRepository();

  Future<void> _deleteActivity(FitnessEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: l10n.deleteActivity,
      content: l10n.deleteActivityConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      onConfirm: () {},
      isDestructive: true,
    );

    if (confirmed != true) return;
    try {
      await _repository.deleteActivity(entry.id);
    } on ActivityStorageException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.saveActivityError}: ${e.message}')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activityHistory),
      ),
      body: StreamBuilder<List<FitnessEntry>>(
        stream: _repository.streamActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: l10n.noActivities,
              description: error is ActivityStorageException
                  ? error.message
                  : l10n.noActivitiesDesc,
              actionLabel: l10n.retry,
              onAction: () {
                setState(() {});
              },
            );
          }

          final entries = snapshot.data ?? <FitnessEntry>[];
          if (entries.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.history_rounded,
              title: l10n.noActivities,
              description: l10n.noActivitiesDesc,
              actionLabel: l10n.addActivity,
              onAction: () async {
                await Navigator.pushNamed(context, AppRouter.addActivity);
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: entries.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                _buildActivityCard(entries[index], l10n, theme),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(
    FitnessEntry entry,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final exerciseIcon = ExerciseTypes.icon(entry.exerciseType);
    final exerciseLabel = ExerciseTypes.label(entry.exerciseType, l10n);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    exerciseIcon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(entry.date),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRouter.editActivity,
                      arguments: entry,
                    );
                  },
                  tooltip: l10n.edit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
                IconButton(
                  onPressed: () => _deleteActivity(entry),
                  tooltip: l10n.delete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.timer_outlined,
                    value: '${entry.duration} ${l10n.min}',
                    label: l10n.duration,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.local_fire_department,
                    value: '${entry.calories} ${l10n.kcal}',
                    label: l10n.calories,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.directions_walk,
                    value: '${entry.steps}',
                    label: l10n.stepsLabel,
                    theme: theme,
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
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
