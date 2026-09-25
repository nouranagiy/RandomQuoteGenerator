import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final String? semanticLabel;

  const AppLogo({super.key, this.size = AppSizes.logoMd, this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = semanticLabel ?? context.l10n.appTitle;
    final iconSize = size <= AppSizes.logoSm
        ? AppSizes.iconSm
        : size <= AppSizes.logoMd
        ? AppSizes.iconMd
        : AppSizes.iconLg;

    return Semantics(
      image: true,
      label: label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppGradients.logo(colorScheme),
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Icon(
          Icons.format_quote_rounded,
          color: colorScheme.onPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}
