import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_provider.dart';
import 'package:quoteflow/models/quote.dart';
import 'package:quoteflow/shared/widgets/app_page.dart';
import 'package:quoteflow/shared/widgets/app_page_header.dart';
import 'package:quoteflow/shared/widgets/app_status_banner.dart';
import 'package:quoteflow/shared/widgets/app_status_pill.dart';
import 'package:quoteflow/shared/widgets/custom_button.dart';
import 'package:quoteflow/shared/widgets/empty_state_widget.dart';
import 'package:quoteflow/shared/widgets/loading_widget.dart';
import 'package:quoteflow/shared/widgets/quote/saved_quote_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Set<String> _removingTexts = {};
  final Set<String> _copyingTexts = {};

  Future<void> _retryLoad() async {
    final favorites = context.read<FavoritesProvider>();
    final uid = favorites.uid;
    if (uid != null) await favorites.loadFavorites(uid);
  }

  Future<void> _confirmRemoval(Quote quote) async {
    if (_removingTexts.contains(quote.text)) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeFavoriteTitle),
        content: SelectableText(l10n.removeFavoriteConfirmation(quote.text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _removingTexts.contains(quote.text)) {
      return;
    }

    final favorites = context.read<FavoritesProvider>();
    favorites.clearError();
    setState(() => _removingTexts.add(quote.text));
    try {
      final removed = await favorites.remove(quote.text);
      if (!removed && mounted) {
        _showMessage(_failureMessage(favorites.failure));
      }
    } finally {
      if (mounted) setState(() => _removingTexts.remove(quote.text));
    }
  }

  Future<void> _copyQuote(Quote quote) async {
    if (_copyingTexts.contains(quote.text)) return;
    final l10n = context.l10n;
    setState(() => _copyingTexts.add(quote.text));
    try {
      await Clipboard.setData(
        ClipboardData(
          text: '"${quote.text}"\n${l10n.quoteAttribution(quote.author)}',
        ),
      );
      if (mounted) _showMessage(l10n.quoteCopied);
    } catch (_) {
      if (mounted) _showMessage(l10n.unexpectedError);
    } finally {
      if (mounted) setState(() => _copyingTexts.remove(quote.text));
    }
  }

  String _failureMessage(FavoritesFailure? failure) {
    final l10n = context.l10n;
    return switch (failure) {
      FavoritesFailure.load => l10n.favoritesLoadError,
      FavoritesFailure.add ||
      FavoritesFailure.remove => l10n.failedToSaveFavorite,
      null => l10n.unexpectedError,
    };
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildContent(BuildContext context, FavoritesProvider favorites) {
    if (favorites.isLoading) return const LoadingWidget();
    if (favorites.failure == FavoritesFailure.load) {
      final l10n = context.l10n;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
            child: AppStatusBanner(
              type: AppStatusBannerType.error,
              title: l10n.error,
              message: l10n.favoritesLoadError,
              action: CustomButton(
                label: l10n.retry,
                icon: Icons.refresh_rounded,
                onPressed: _retryLoad,
                isOutlined: true,
              ),
            ),
          ),
        ),
      );
    }

    final quotes = favorites.quotes;
    if (quotes.isEmpty) {
      final l10n = context.l10n;
      return EmptyStateWidget(
        icon: Icons.favorite_border_rounded,
        title: l10n.noFavorites,
        description: l10n.noFavoritesDescription,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: quotes.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return SavedQuoteCard(
          key: ValueKey(quote.text),
          quote: quote,
          onRemove: () => _confirmRemoval(quote),
          onCopy: () => _copyQuote(quote),
          isRemoveBusy: _removingTexts.contains(quote.text),
          isCopyBusy: _copyingTexts.contains(quote.text),
          statusLabel: context.l10n.saved,
          semanticLabel: context.l10n.saved,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favorites = context.watch<FavoritesProvider>();

    return AppPage(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: l10n.favorites,
            subtitle: l10n.favoritesSubtitle,
            trailing: AppStatusPill(
              label: l10n.saved,
              count: favorites.quotes.length,
              icon: Icons.favorite_rounded,
              tone: AppStatusTone.favorite,
              semanticLabel: l10n.favoritesCount(favorites.quotes.length),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _buildContent(context, favorites)),
        ],
      ),
    );
  }
}
