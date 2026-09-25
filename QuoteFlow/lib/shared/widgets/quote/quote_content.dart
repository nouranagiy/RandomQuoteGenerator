import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/models/quote.dart';

class QuoteContent extends StatelessWidget {
  final Quote quote;
  final bool centered;
  final bool compact;
  final int? maxLines;

  const QuoteContent({
    super.key,
    required this.quote,
    this.centered = false,
    this.compact = false,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final textStyle = compact ? textTheme.titleMedium : textTheme.headlineSmall;
    final authorStyle = compact ? textTheme.bodySmall : textTheme.titleMedium;
    final alignment = centered ? TextAlign.center : TextAlign.left;
    final crossAxisAlignment = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    return Semantics(
      label: '${quote.text} ${quote.author}',
      child: ExcludeSemantics(
        child: Directionality(
          textDirection: textDirection,
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quote.text,
                textAlign: alignment,
                textDirection: textDirection,
                style: textStyle?.copyWith(color: colorScheme.onSurface),
                maxLines: maxLines,
                overflow: maxLines == null
                    ? TextOverflow.clip
                    : TextOverflow.ellipsis,
              ),
              SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
              Text(
                l10n.quoteAttribution(quote.author),
                textAlign: alignment,
                textDirection: textDirection,
                style: authorStyle?.copyWith(
                  color: centered
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
