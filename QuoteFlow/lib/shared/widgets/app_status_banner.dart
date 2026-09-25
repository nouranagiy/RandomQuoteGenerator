import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

enum AppStatusBannerType { success, warning, error, info, infoPrimary }

class AppStatusBanner extends StatelessWidget {
  final AppStatusBannerType type;
  final String message;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;

  const AppStatusBanner({
    super.key,
    required this.type,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _bannerColors(context, type);
    final textTheme = Theme.of(context).textTheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: textTheme.titleSmall?.copyWith(color: colors.foreground),
          ),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: colors.foreground),
        ),
      ],
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: title == null ? message : '${title!} $message',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: colors.foreground.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_icon, size: AppSizes.iconMd, color: colors.foreground),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: content),
                ],
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Align(alignment: AlignmentDirectional.centerEnd, child: action),
              ] else if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (type) {
      AppStatusBannerType.success => Icons.check_circle_outline_rounded,
      AppStatusBannerType.warning => Icons.warning_amber_rounded,
      AppStatusBannerType.error => Icons.error_outline_rounded,
      AppStatusBannerType.info => Icons.info_outline_rounded,
      AppStatusBannerType.infoPrimary => Icons.auto_awesome_outlined,
    };
  }

  _BannerColors _bannerColors(BuildContext context, AppStatusBannerType value) {
    final colorScheme = Theme.of(context).colorScheme;
    final semanticColors =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppPalette.semanticColors(Theme.of(context).brightness);
    return switch (value) {
      AppStatusBannerType.success => _BannerColors(
        semanticColors.successContainer,
        semanticColors.success,
      ),
      AppStatusBannerType.warning => _BannerColors(
        semanticColors.warningContainer,
        semanticColors.warning,
      ),
      AppStatusBannerType.error => _BannerColors(
        colorScheme.errorContainer,
        colorScheme.error,
      ),
      AppStatusBannerType.info => _BannerColors(
        colorScheme.surfaceContainerHigh,
        colorScheme.onSurfaceVariant,
      ),
      AppStatusBannerType.infoPrimary => _BannerColors(
        colorScheme.primaryContainer,
        colorScheme.primary,
      ),
    };
  }
}

class _BannerColors {
  final Color background;
  final Color foreground;

  const _BannerColors(this.background, this.foreground);
}
