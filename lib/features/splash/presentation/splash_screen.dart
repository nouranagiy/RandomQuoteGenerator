import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_logo.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.splashBackground(colorScheme),
            ),
            child: const SizedBox.expand(),
          ),
          PositionedDirectional(
            top: AppSpacing.xxl,
            end: AppSpacing.xxl,
            child: IgnorePointer(
              child: _SplashOrb(
                size: AppSizes.logoHero,
                color: colorScheme.primary.withValues(alpha: AppOpacity.subtle),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: AppSpacing.xxxl,
            start: AppSpacing.xl,
            child: IgnorePointer(
              child: _SplashOrb(
                size: AppSizes.logoLg,
                color: colorScheme.secondary.withValues(
                  alpha: AppOpacity.muted,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.formMaxWidth,
                  ),
                  child: AppSurface(
                    level: AppSurfaceLevel.elevated,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: AppSizes.logoHero),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.appTitle,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.inspireYourDay,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SplashSignal(colorScheme: colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _SplashOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: SizedBox.square(dimension: size),
    );
  }
}

class _SplashSignal extends StatelessWidget {
  final ColorScheme colorScheme;

  const _SplashSignal({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SignalBar(width: AppSizes.logoSm, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        _SignalBar(width: AppSizes.logoMd, color: colorScheme.secondary),
        const SizedBox(width: AppSpacing.xs),
        _SignalBar(width: AppSizes.logoLg, color: colorScheme.primaryContainer),
      ],
    );
  }
}

class _SignalBar extends StatelessWidget {
  final double width;
  final Color color;

  const _SignalBar({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: SizedBox(width: width, height: AppSpacing.xs),
    );
  }
}
