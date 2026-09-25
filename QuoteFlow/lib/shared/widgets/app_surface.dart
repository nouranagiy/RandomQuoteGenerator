import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

enum AppSurfaceLevel { flat, outlined, raised, elevated }

enum AppSurfaceSize { compact, standard }

class AppSurface extends StatelessWidget {
  final AppSurfaceLevel level;
  final AppSurfaceSize size;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const AppSurface({
    super.key,
    required this.child,
    this.level = AppSurfaceLevel.flat,
    this.size = AppSurfaceSize.standard,
    this.padding,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = size == AppSurfaceSize.compact ? AppRadii.md : AppRadii.lg;
    final borderRadius = BorderRadius.circular(radius);
    final decoration = BoxDecoration(
      color: _background(colorScheme, level),
      borderRadius: borderRadius,
      border: level == AppSurfaceLevel.outlined
          ? Border.all(color: colorScheme.outlineVariant)
          : null,
      boxShadow: _shadow(context, level),
    );
    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);

    if (onTap == null) {
      final surface = DecoratedBox(decoration: decoration, child: content);
      if (semanticLabel == null) return surface;
      return Semantics(container: true, label: semanticLabel, child: surface);
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: DecoratedBox(decoration: decoration, child: content),
        ),
      ),
    );
  }

  Color _background(ColorScheme colorScheme, AppSurfaceLevel value) {
    return switch (value) {
      AppSurfaceLevel.flat => colorScheme.surfaceContainerLowest,
      AppSurfaceLevel.outlined => colorScheme.surface,
      AppSurfaceLevel.raised => colorScheme.surfaceContainerLow,
      AppSurfaceLevel.elevated => colorScheme.surfaceContainerHigh,
    };
  }

  List<BoxShadow> _shadow(BuildContext context, AppSurfaceLevel value) {
    return switch (value) {
      AppSurfaceLevel.flat || AppSurfaceLevel.outlined => const [],
      AppSurfaceLevel.raised => AppShadows.low(Theme.of(context).brightness),
      AppSurfaceLevel.elevated => AppShadows.medium(
        Theme.of(context).brightness,
      ),
    };
  }
}
