import 'package:flutter/material.dart';
import 'package:quoteflow/models/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onCopy;
  final bool showDelete;
  final VoidCallback? onDelete;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onCopy,
    this.showDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (showDelete) {
      return _buildCompactCard(context, colorScheme);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.format_quote_rounded,
                size: 28,
                color: colorScheme.primary.withValues(alpha: 0.55),
              ),
              if (onFavoriteToggle != null || onCopy != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onFavoriteToggle != null)
                      _ActionChip(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                        onTap: onFavoriteToggle,
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                      ),
                    if (onCopy != null) ...[
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.copy_outlined,
                        onTap: onCopy,
                        tooltip: 'Copy Quote',
                      ),
                    ],
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${quote.text}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '— ${quote.author}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${quote.text}"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— ${quote.author}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? tooltip;

  const _ActionChip({required this.icon, this.color, this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
