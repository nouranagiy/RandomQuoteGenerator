import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}
class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Quote> _favorites = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final texts = prefs.getStringList('favoriteQuotes') ?? [];
    final authors = prefs.getStringList('favoriteAuthors') ?? [];
    final favorites = <Quote>[];
    for (int i = 0; i < texts.length; i++) {
      favorites.add(
        Quote(
          text: texts[i],
          author: i < authors.length ? authors[i] : 'Unknown',
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }
  Future<void> _removeFavorite(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final texts = prefs.getStringList('favoriteQuotes') ?? [];
    final authors = prefs.getStringList('favoriteAuthors') ?? [];
    if (index < texts.length) {
      texts.removeAt(index);
    }
    if (index < authors.length) {
      authors.removeAt(index);
    }
    await prefs.setStringList(
      'favoriteQuotes',
      texts,
    );
    await prefs.setStringList(
      'favoriteAuthors',
      authors,
    );
    setState(() {
      _favorites.removeAt(index);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : _favorites.isEmpty ? _buildEmptyState() : ListView.separated(
        padding: EdgeInsets.all(20),
        itemCount: _favorites.length,
        separatorBuilder: (_, _) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final quote = _favorites[index];
          return Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.favorite,
                    color: Colors.red,
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('"${quote.text}"',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10,),
                        Text('— ${quote.author}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeFavorite(index),
                    tooltip: 'Remove Favorite',
                    icon: Icon(Icons.delete_outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
            Icon(Icons.favorite_border,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 20),
            Text('No Favorites Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text('Save your favorite quotes and find them here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}