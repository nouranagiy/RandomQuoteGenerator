import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_provider.dart';
import 'package:quoteflow/features/home/data/quotes_repository.dart';
import 'package:quoteflow/models/quote.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/widgets/app_logo.dart';
import 'package:quoteflow/shared/widgets/app_page.dart';
import 'package:quoteflow/shared/widgets/app_page_header.dart';
import 'package:quoteflow/shared/widgets/app_status_banner.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';
import 'package:quoteflow/shared/widgets/custom_button.dart';
import 'package:quoteflow/shared/widgets/quote/featured_quote_card.dart';
import 'package:quoteflow/shared/widgets/welcome_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Quote _currentQuote;
  Locale _locale = const Locale('en');
  bool _isFavoriteBusy = false;
  bool _isCopyBusy = false;

  @override
  void initState() {
    super.initState();
    _currentQuote = QuotesRepository.instance.getRandomQuote(_locale);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final locale = Localizations.localeOf(context);
    if (locale != _locale) {
      _locale = locale;
      _getNewQuote();
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteBusy) return;
    final l10n = context.l10n;
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      _showMessage(l10n.signInToSaveFavorites);
      return;
    }

    setState(() => _isFavoriteBusy = true);
    final favorites = context.read<FavoritesProvider>();
    try {
      final result = await favorites.toggle(_currentQuote);
      if (!mounted) return;
      if (result == null) {
        _showMessage(l10n.signInToSaveFavorites);
      } else if (!result) {
        _showMessage(_failureMessage(favorites.failure));
      }
    } finally {
      if (mounted) setState(() => _isFavoriteBusy = false);
    }
  }

  Future<void> _copyQuote() async {
    if (_isCopyBusy) return;
    final l10n = context.l10n;
    final quote = _currentQuote;
    setState(() => _isCopyBusy = true);
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
      if (mounted) setState(() => _isCopyBusy = false);
    }
  }

  void _getNewQuote() {
    setState(() {
      _currentQuote = QuotesRepository.instance.getRandomQuote(
        _locale,
        exclude: _currentQuote,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthProvider>();
    final favorites = context.watch<FavoritesProvider>();

    return AppPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSurface(
            level: AppSurfaceLevel.raised,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const ExcludeSemantics(child: AppLogo(size: AppSizes.logoMd)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppPageHeader(
                    title: l10n.appTitle,
                    subtitle: l10n.inspireYourDay,
                    semanticLabel: l10n.appTitle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const WelcomeHeader(),
          const SizedBox(height: AppSpacing.lg),
          if (!auth.isAuthenticated) ...[
            AppStatusBanner(
              type: AppStatusBannerType.infoPrimary,
              message: l10n.signInToSaveFavorites,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          FeaturedQuoteCard(
            quote: _currentQuote,
            isFavorite: favorites.isFavorite(_currentQuote.text),
            onFavoriteToggle: _toggleFavorite,
            onCopy: _copyQuote,
            isFavoriteBusy: _isFavoriteBusy,
            isCopyBusy: _isCopyBusy,
            statusLabel: l10n.dailyInspiration,
            semanticLabel: l10n.dailyInspiration,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomButton(
            label: l10n.newQuote,
            icon: Icons.auto_awesome_rounded,
            onPressed: _getNewQuote,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
