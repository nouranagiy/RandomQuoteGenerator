import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/shared/widgets/quote_card.dart';
import 'package:quoteflow/shared/widgets/empty_state_widget.dart';
import 'package:quoteflow/shared/widgets/loading_widget.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  Future<void> _removeFavorite(BuildContext context, String text) async {
    final favorites = context.read<FavoritesProvider>();
    final l10n = context.l10n;
    await favorites.remove(text);
    if (!context.mounted) return;
    if (favorites.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToSaveFavorite)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favorites = context.watch<FavoritesProvider>();
    final isLoading = favorites.isLoading;
    final quotes = favorites.quotes;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favorites),
      ),
      body: isLoading
          ? const LoadingWidget()
          : quotes.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.favorite_border_rounded,
                  title: l10n.noFavorites,
                  description: l10n.noFavoritesDescription,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: quotes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final quote = quotes[index];
                    return QuoteCard(
                      quote: quote,
                      showDelete: true,
                      onDelete: () => _removeFavorite(context, quote.text),
                    );
                  },
                ),
    );
  }
}
