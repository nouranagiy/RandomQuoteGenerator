import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

enum AppIconButtonTreatment { neutral, selected, favorite, danger }

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppIconButtonTreatment treatment;
  final bool selected;
  final bool busy;
  final IconData? selectedIcon;
  final double? iconSize;
  final String? semanticLabel;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.treatment = AppIconButtonTreatment.neutral,
    this.selected = false,
    this.busy = false,
    this.selectedIcon,
    this.iconSize,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _treatmentColors(context, treatment);
    final enabled = onPressed != null && !busy;
    final displayColor = enabled
        ? colors.foreground
        : colors.foreground.withValues(alpha: AppOpacity.disabled);
    final background = colors.background;
    final pressedBackground = colors.foreground.withValues(
      alpha: AppOpacity.muted,
    );
    final hoverBackground = colors.foreground.withValues(
      alpha: AppOpacity.subtle,
    );
    final currentIcon = selected && selectedIcon != null ? selectedIcon! : icon;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected || treatment == AppIconButtonTreatment.selected,
      label: semanticLabel ?? tooltip,
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          icon: AnimatedSwitcher(
            duration: AppMotion.fast,
            switchInCurve: AppMotion.standardCurve,
            switchOutCurve: AppMotion.standardCurve,
            child: busy
                ? SizedBox.square(
                    key: const ValueKey(true),
                    dimension: AppSizes.iconMd,
                    child: CircularProgressIndicator(color: displayColor),
                  )
                : Icon(
                    currentIcon,
                    key: const ValueKey(false),
                    size: iconSize ?? AppSizes.iconMd,
                    color: displayColor,
                  ),
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          constraints: const BoxConstraints(
            minWidth: AppSizes.touchTarget,
            minHeight: AppSizes.touchTarget,
          ),
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(
              Size.square(AppSizes.touchTarget),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
            foregroundColor: WidgetStatePropertyAll(displayColor),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (!enabled) {
                return background.withValues(alpha: AppOpacity.disabled);
              }
              if (states.contains(WidgetState.pressed)) {
                return pressedBackground;
              }
              if (states.contains(WidgetState.hovered)) {
                return hoverBackground;
              }
              return background;
            }),
            overlayColor: WidgetStatePropertyAll(
              colors.foreground.withValues(alpha: AppOpacity.muted),
            ),
          ),
        ),
      ),
    );
  }

  _IconButtonColors _treatmentColors(
    BuildContext context,
    AppIconButtonTreatment value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final semanticColors =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppPalette.semanticColors(Theme.of(context).brightness);
    return switch (value) {
      AppIconButtonTreatment.neutral => _IconButtonColors(
        colorScheme.onSurfaceVariant,
        colorScheme.surfaceContainerHigh,
      ),
      AppIconButtonTreatment.selected => _IconButtonColors(
        colorScheme.primary,
        colorScheme.primaryContainer,
      ),
      AppIconButtonTreatment.favorite => _IconButtonColors(
        semanticColors.favorite,
        semanticColors.favoriteContainer,
      ),
      AppIconButtonTreatment.danger => _IconButtonColors(
        colorScheme.error,
        colorScheme.errorContainer,
      ),
    };
  }
}

class _IconButtonColors {
  final Color foreground;
  final Color background;

  const _IconButtonColors(this.foreground, this.background);
}
