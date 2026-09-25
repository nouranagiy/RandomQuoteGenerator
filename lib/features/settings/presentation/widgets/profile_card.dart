import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';

class SettingsProfileCard extends StatelessWidget {
  final String displayName;
  final String displayEmail;
  final String guestName;

  const SettingsProfileCard({
    super.key,
    required this.displayName,
    required this.displayEmail,
    required this.guestName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final trimmedName = displayName.trim();
    final name = trimmedName.isEmpty ? guestName : trimmedName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : guestName[0];
    final hasEmail = displayEmail.trim().isNotEmpty;

    return AppSurface(
      level: AppSurfaceLevel.elevated,
      padding: const EdgeInsets.all(AppSpacing.lg),
      semanticLabel: name,
      child: Row(
        children: [
          SizedBox.square(
            dimension: AppSizes.logoLg,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: textTheme.titleMedium),
                if (hasEmail) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    displayEmail.trim(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
