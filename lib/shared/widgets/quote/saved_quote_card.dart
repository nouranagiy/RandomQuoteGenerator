import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/models/quote.dart';
import 'package:quoteflow/shared/widgets/app_icon_button.dart';
import 'package:quoteflow/shared/widgets/app_status_pill.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';
import 'package:quoteflow/shared/widgets/quote/quote_content.dart';

class SavedQuoteCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback? onRemove;
  final VoidCallback? onCopy;
  final bool isRemoveBusy;
  final bool isCopyBusy;
  final String? statusLabel;
  final int? statusCount;
  final AppStatusTone statusTone;
  final String? semanticLabel;

  const SavedQuoteCard({
    super.key,
    required this.quote,
    this.onRemove,
    this.onCopy,
    this.isRemoveBusy = false,
    this.isCopyBusy = false,
    this.statusLabel,
    this.statusCount,
    this.statusTone = AppStatusTone.favorite,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = <Widget>[];

    if (onRemove != null) {
      actions.add(
        AppIconButton(
          icon: Icons.delete_outline_rounded,
          tooltip: l10n.removeFavorite,
          treatment: AppIconButtonTreatment.danger,
          onPressed: onRemove,
          busy: isRemoveBusy,
        ),
      );
    }
    if (onCopy != null) {
      actions.add(
        AppIconButton(
          icon: Icons.copy_outlined,
          tooltip: l10n.copyToClipboard,
          onPressed: onCopy,
          busy: isCopyBusy,
        ),
      );
    }

    final statusPill = AppStatusPill(
      label: statusLabel ?? l10n.favorites,
      count: statusCount,
      icon: Icons.favorite_rounded,
      tone: statusTone,
    );
    final content = QuoteContent(quote: quote, compact: true);
    final actionWrap = Wrap(
      alignment: WrapAlignment.end,
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: actions,
    );

    return AppSurface(
      level: AppSurfaceLevel.outlined,
      size: AppSurfaceSize.compact,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticLabel: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackActions =
              !constraints.maxWidth.isFinite ||
              constraints.maxWidth < AppSizes.formMaxWidth;
          if (stackActions) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    statusPill,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: content),
                  ],
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: actionWrap,
                  ),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statusPill,
              const SizedBox(width: AppSpacing.md),
              Expanded(child: content),
              if (actions.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                actionWrap,
              ],
            ],
          );
        },
      ),
    );
  }
}
