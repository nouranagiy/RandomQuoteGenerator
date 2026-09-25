import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';

class SettingsOptionGroup extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Widget> options;

  const SettingsOptionGroup({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      level: AppSurfaceLevel.outlined,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsGroupIcon(icon: icon),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < options.length; index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.xs),
            options[index],
          ],
        ],
      ),
    );
  }
}

class _SettingsGroupIcon extends StatelessWidget {
  final IconData icon;

  const _SettingsGroupIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(icon, size: AppSizes.iconMd, color: colorScheme.primary),
      ),
    );
  }
}
