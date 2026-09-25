import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/models/quote.dart';
import 'package:quoteflow/shared/widgets/app_icon_button.dart';
import 'package:quoteflow/shared/widgets/app_status_pill.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';
import 'package:quoteflow/shared/widgets/quote/quote_content.dart';

class FeaturedQuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onCopy;
  final bool isFavoriteBusy;
  final bool isCopyBusy;
  final String? statusLabel;
  final int? statusCount;
  final AppStatusTone statusTone;
  final String? semanticLabel;

  const FeaturedQuoteCard({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onCopy,
    this.isFavoriteBusy = false,
    this.isCopyBusy = false,
    this.statusLabel,
    this.statusCount,
    this.statusTone = AppStatusTone.primary,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final actions = <Widget>[];

    if (onFavoriteToggle != null) {
      actions.add(
        AppIconButton(
          icon: Icons.favorite_border_rounded,
          selectedIcon: Icons.favorite_rounded,
          selected: isFavorite,
          treatment: isFavorite
              ? AppIconButtonTreatment.favorite
              : AppIconButtonTreatment.neutral,
          tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
          onPressed: onFavoriteToggle,
          busy: isFavoriteBusy,
        ),
      );
    }
    if (onCopy != null) {
      actions.add(
        AppIconButton(
          icon: Icons.copy_outlined,
          tooltip: l10n.copyQuote,
          onPressed: onCopy,
          busy: isCopyBusy,
        ),
      );
    }

    return AppSurface(
      level: AppSurfaceLevel.elevated,
      padding: const EdgeInsets.all(AppSpacing.xl),
      semanticLabel: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: AppSizes.iconXl,
                color: colorScheme.primary.withValues(alpha: AppOpacity.strong),
              ),
              Flexible(
                child: AppStatusPill(
                  label: statusLabel ?? l10n.newQuote,
                  count: statusCount,
                  tone: statusTone,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          QuoteContent(quote: quote, centered: true),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: actions,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
