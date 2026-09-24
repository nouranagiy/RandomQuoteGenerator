import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../vocabulary/data/language_storage.dart';
import '../../vocabulary/data/language_word.dart';
import '../../vocabulary/presentation/widgets/word_tile.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LanguageStorage _storage = LanguageStorage();
  List<LanguageWord> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final words = await _storage.getWords();
    if (!mounted) return;
    setState(() {
      _favorites = words.where((w) => w.isFavorite).toList();
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(LanguageWord word) async {
    await _storage.toggleFavorite(word.id);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.favorites)),
      body: _isLoading
          ? const AppLoading()
          : _favorites.isEmpty
          ? AppEmptyState(
              icon: Icons.favorite_border_rounded,
              title: l.noFavoritesYet,
              subtitle: l.saveFavoriteWords,
              action: AppButton(
                text: l.browseVocabulary,
                onPressed: () async {
                  await Navigator.of(context).pushNamed(AppRoutes.vocabulary);
                  _loadFavorites();
                },
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _favorites.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final word = _favorites[index];
                return WordTile(
                  word: word,
                  showMenu: false,
                  onTap: () async {
                    await Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.wordDetails, arguments: word);
                    _loadFavorites();
                  },
                  onFavorite: () => _toggleFavorite(word),
                  onEdit: () {},
                  onDelete: () {},
                );
              },
            ),
    );
  }
}
