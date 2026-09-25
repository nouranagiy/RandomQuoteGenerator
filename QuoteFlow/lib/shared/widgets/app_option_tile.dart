import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';

class AppOptionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;
  final String? semanticLabel;

  const AppOptionTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.isSelected = false,
    this.onTap,
    this.trailing,
    this.enabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isSelected ? colorScheme.primary : colorScheme.onSurface;
    final iconBackground = isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final iconForeground = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.touchTarget),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Icon(icon, size: AppSizes.iconMd, color: iconForeground),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: foreground),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (isSelected)
            Icon(
              Icons.check_rounded,
              size: AppSizes.iconMd,
              color: colorScheme.primary,
            ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      enabled: enabled,
      selected: isSelected,
      label: semanticLabel ?? title,
      child: AppSurface(
        level: isSelected ? AppSurfaceLevel.raised : AppSurfaceLevel.outlined,
        size: AppSurfaceSize.compact,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        onTap: enabled ? onTap : null,
        child: content,
      ),
    );
  }
}
