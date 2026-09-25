import 'package:flutter/material.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_status_pill.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';

class SettingsAboutCard extends StatelessWidget {
  const SettingsAboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      level: AppSurfaceLevel.raised,
      padding: const EdgeInsets.all(AppSpacing.lg),
      semanticLabel: l10n.about,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: AppSizes.iconMd,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.about, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l10n.aboutSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              AppStatusPill(
                label: l10n.version,
                icon: Icons.tag_rounded,
                tone: AppStatusTone.infoPrimary,
              ),
              const Spacer(),
              Text(
                AppConstants.appVersion,
                textAlign: TextAlign.end,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
