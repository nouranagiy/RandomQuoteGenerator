import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

enum AppStatusTone {
  neutral,
  info,
  infoPrimary,
  primary,
  success,
  warning,
  error,
  favorite,
}

class AppStatusPill extends StatelessWidget {
  final String label;
  final int? count;
  final IconData? icon;
  final AppStatusTone tone;
  final String? semanticLabel;

  const AppStatusPill({
    super.key,
    required this.label,
    this.count,
    this.icon,
    this.tone = AppStatusTone.neutral,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(context, tone);
    final countLabel = count?.toString();

    return Semantics(
      container: true,
      label:
          semanticLabel ?? (countLabel == null ? label : '$label $countLabel'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: colors.foreground.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSm, color: colors.foreground),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: colors.foreground),
              ),
              if (countLabel != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  countLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colors.foreground),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _StatusColors _toneColors(BuildContext context, AppStatusTone value) {
    final colorScheme = Theme.of(context).colorScheme;
    final semanticColors =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppPalette.semanticColors(Theme.of(context).brightness);
    return switch (value) {
      AppStatusTone.neutral => _StatusColors(
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
      ),
      AppStatusTone.info => _StatusColors(
        colorScheme.surfaceContainerHigh,
        colorScheme.onSurfaceVariant,
      ),
      AppStatusTone.infoPrimary => _StatusColors(
        colorScheme.primaryContainer,
        colorScheme.primary,
      ),
      AppStatusTone.primary => _StatusColors(
        colorScheme.primaryContainer,
        colorScheme.primary,
      ),
      AppStatusTone.success => _StatusColors(
        semanticColors.successContainer,
        semanticColors.success,
      ),
      AppStatusTone.warning => _StatusColors(
        semanticColors.warningContainer,
        semanticColors.warning,
      ),
      AppStatusTone.error => _StatusColors(
        colorScheme.errorContainer,
        colorScheme.error,
      ),
      AppStatusTone.favorite => _StatusColors(
        semanticColors.favoriteContainer,
        semanticColors.favorite,
      ),
    };
  }
}

class _StatusColors {
  final Color background;
  final Color foreground;

  const _StatusColors(this.background, this.foreground);
}
