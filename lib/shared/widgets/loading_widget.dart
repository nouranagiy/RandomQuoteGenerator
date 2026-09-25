import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final EdgeInsetsGeometry? padding;

  const LoadingWidget({super.key, this.message, this.padding});

  @override
  Widget build(BuildContext context) {
    final label = message ?? context.l10n.loading;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: AppSizes.iconXl,
          child: CircularProgressIndicator(),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
        child: Center(child: content),
      ),
    );
  }
}
