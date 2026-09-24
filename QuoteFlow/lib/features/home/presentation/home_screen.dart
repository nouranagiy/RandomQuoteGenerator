import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/features/home/data/quotes_repository.dart';
import 'package:quoteflow/models/quote.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_screen.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_provider.dart';
import 'package:quoteflow/features/settings/presentation/settings_screen.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/widgets/app_logo.dart';
import 'package:quoteflow/shared/widgets/welcome_header.dart';
import 'package:quoteflow/shared/widgets/quote_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Quote _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = QuotesRepository.instance.firstQuote;
  }

  Future<void> _toggleFavorite() async {
    final l10n = context.l10n;
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.signInToSaveFavorites)),
      );
      return;
    }
    final favorites = context.read<FavoritesProvider>();
    final result = await favorites.toggle(_currentQuote);
    if (!mounted || result != null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(favorites.errorMessage ?? l10n.failedToSaveFavorite),
      ),
    );
  }

  Future<void> _copyQuote() async {
    final quoteText = '"${_currentQuote.text}" — ${_currentQuote.author}';
    await Clipboard.setData(ClipboardData(text: quoteText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.quoteCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _getNewQuote() {
    setState(() {
      _currentQuote = QuotesRepository.instance.getRandomQuote(exclude: _currentQuote);
    });
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(_currentQuote.text);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: const AppLogo(size: 32),
        ),
        leadingWidth: 48,
        title: const Text('QuoteFlow'),
        actions: [
          IconButton(
            onPressed: _openFavorites,
            tooltip: l10n.favorites,
            icon: const Icon(Icons.favorite_border_rounded, size: 22),
          ),
          IconButton(
            onPressed: _openSettings,
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome text — comfortable spacing below the logo/AppBar.
              const WelcomeHeader(),
              // Balances the card into the upper-middle region rather than
              // cramming it against the top or dropping it to the exact center.
              const Spacer(flex: 2),
              // The Quote Card is the main element: medium width, centered
              // horizontally, content-adaptive height (not stretched).
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: QuoteCard(
                    quote: _currentQuote,
                    isFavorite: isFavorite,
                    onFavoriteToggle: _toggleFavorite,
                    onCopy: _copyQuote,
                  ),
                ),
              ),
              // Comfortable flow between the card and the primary action.
              const SizedBox(height: 28),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ElevatedButton.icon(
                    onPressed: _getNewQuote,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(l10n.newQuote),
                  ),
                ),
              ),
              // Gentle lower spacing keeping the composition breathing.
              const Spacer(flex: 5),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
