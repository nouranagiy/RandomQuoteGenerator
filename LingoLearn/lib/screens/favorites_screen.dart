import 'package:flutter/material.dart';
import '../models/language_word.dart';
import '../services/language_storage.dart';
import 'vocabulary_screen.dart';
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}
class _FavoritesScreenState extends State<FavoritesScreen> {
  final LanguageStorage _storage = LanguageStorage();
  List<LanguageWord> _favoriteWords = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  Future<void> _loadFavorites() async {
    final words = await _storage.getWords();
    final favorites = words.where((word) => word.isFavorite).toList();
    if (!mounted) return;
    setState(() {
      _favoriteWords = favorites;
      _isLoading = false;
    });
  }
  Future<void> _removeFavorite(
      LanguageWord word,
      ) async {
    await _storage.toggleFavorite(word.id);
    await _loadFavorites();
  }
  void _openWordDetails(
      LanguageWord word,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordDetailsScreen(word: word,),
      ),
    ).then((_) {
      _loadFavorites();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : _favoriteWords.isEmpty ? _buildEmptyState() : ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: _favoriteWords.length,
        separatorBuilder: (_, _) => SizedBox(height: 10),
        itemBuilder: (context, index) {
          final word = _favoriteWords[index];
          return _buildFavoriteCard(
            word,
          );
        },
      ),
    );
  }
  Widget _buildFavoriteCard(
      LanguageWord word,
      ) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _openWordDetails(word);
        },
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.translate_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word.word,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(word.translation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 4),
                    Text(word.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _removeFavorite(word);
                },
                tooltip: 'Remove from favorites',
                icon: Icon(Icons.favorite_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_border_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 25),
            Text('No Favorites Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Save your favorite words to review them later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VocabularyScreen(),
                  ),
                ).then((_) {
                  _loadFavorites();
                });
              },
              icon: Icon(Icons.menu_book_rounded),
              label: Text('Browse Vocabulary',),
            ),
          ],
        ),
      ),
    );
  }
}