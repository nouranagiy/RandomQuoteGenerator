import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class RecentSearches extends StatelessWidget {
  final List<String> recent;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onRemove;

  const RecentSearches({
    super.key,
    required this.recent,
    required this.onSelected,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l.recentSearches,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final word in recent)
              InputChip(
                label: Text(word),
                onPressed: () => onSelected(word),
                onDeleted: () => onRemove(word),
                deleteIcon: const Icon(Icons.close_rounded, size: 18),
              ),
          ],
        ),
      ],
    );
  }
}
