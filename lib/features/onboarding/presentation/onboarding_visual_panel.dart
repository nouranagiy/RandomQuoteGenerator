import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';

enum OnboardingVisualAccent { primary, secondary, tertiary }

class OnboardingVisualPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final OnboardingVisualAccent accent;

  const OnboardingVisualPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _PanelColors.from(context, accent);
    return AppSurface(
      level: AppSurfaceLevel.elevated,
      padding: EdgeInsets.zero,
      semanticLabel: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SizedBox(
            height: AppSizes.logoHero + AppSpacing.giant + AppSpacing.xl,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PositionedDirectional(
                  top: AppSpacing.lg,
                  end: AppSpacing.lg,
                  child: _TintOrb(
                    size: AppSizes.logoLg,
                    color: colors.accent.withValues(alpha: AppOpacity.subtle),
                  ),
                ),
                PositionedDirectional(
                  bottom: AppSpacing.lg,
                  start: AppSpacing.lg,
                  child: _TintOrb(
                    size: AppSpacing.giant,
                    color: colors.surface.withValues(alpha: AppOpacity.muted),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.center,
                  child: _IconBadge(icon: icon, colors: colors),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: AppSizes.iconLg,
                    color: colors.foreground.withValues(
                      alpha: AppOpacity.strong,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final _PanelColors colors;

  const _IconBadge({required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: AppOpacity.strong),
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Icon(icon, size: AppSizes.iconXl, color: colors.foreground),
      ),
    );
  }
}

class _TintOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _TintOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(dimension: size),
    );
  }
}

class _PanelColors {
  final Color accent;
  final Color container;
  final Color foreground;
  final Color surface;

  const _PanelColors({
    required this.accent,
    required this.container,
    required this.foreground,
    required this.surface,
  });

  factory _PanelColors.from(
    BuildContext context,
    OnboardingVisualAccent value,
  ) {
    final colors = Theme.of(context).colorScheme;
    return switch (value) {
      OnboardingVisualAccent.primary => _PanelColors(
        accent: colors.primary,
        container: colors.primaryContainer,
        foreground: colors.onPrimary,
        surface: colors.surface,
      ),
      OnboardingVisualAccent.secondary => _PanelColors(
        accent: colors.secondary,
        container: colors.secondaryContainer,
        foreground: colors.onSecondary,
        surface: colors.surface,
      ),
      OnboardingVisualAccent.tertiary => _PanelColors(
        accent: colors.tertiary,
        container: colors.tertiaryContainer,
        foreground: colors.onTertiary,
        surface: colors.surface,
      ),
    };
  }
}
