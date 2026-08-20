import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quotes_data.dart';
import '../models/quote.dart';
import 'favorites_screen.dart';
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final Random _random = Random();
  late Quote _currentQuote;
  bool _isFavorite = false;
  @override
  void initState() {
    super.initState();
    _currentQuote = quotes.first;
    _checkFavorite();
  }
  Future<void> _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteQuotes') ?? [];
    if (!mounted) return;
    setState(() {
      _isFavorite = favorites.contains(_currentQuote.text);
    });
  }
  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteQuotes = prefs.getStringList('favoriteQuotes') ?? [];
    final favoriteAuthors = prefs.getStringList('favoriteAuthors') ?? [];
    final index = favoriteQuotes.indexOf(_currentQuote.text);
    if (index != -1) {
      favoriteQuotes.removeAt(index);
      if (index < favoriteAuthors.length) {
        favoriteAuthors.removeAt(index);
      }
      setState(() {
        _isFavorite = false;
      });
    } else {
      favoriteQuotes.add(_currentQuote.text);
      favoriteAuthors.add(_currentQuote.author);
      setState(() {
        _isFavorite = true;
      });
    }
    await prefs.setStringList('favoriteQuotes',
      favoriteQuotes,
    );
    await prefs.setStringList('favoriteAuthors',
      favoriteAuthors,
    );
  }
  Future<void> _copyQuote() async {
    final quoteText = '"${_currentQuote.text}" — ${_currentQuote.author}';
    await Clipboard.setData(
      ClipboardData(text: quoteText),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quote copied to clipboard',),
        duration: Duration(seconds: 2),
      ),
    );
  }
  Future<void> _getNewQuote() async {
    if (quotes.length <= 1) return;
    int newIndex;
    do {
      newIndex = _random.nextInt(quotes.length);
    } while (quotes[newIndex] == _currentQuote);
    setState(() {
      _currentQuote = quotes[newIndex];
      _isFavorite = false;
    });
    await _checkFavorite();
  }
  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(),
      ),
    );
    await _checkFavorite();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuoteFlow',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _openFavorites,
            tooltip: 'Favorites',
            icon: Icon(Icons.favorite_border,),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'Light Mode' : 'Dark Mode',
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Icon(Icons.format_quote_rounded,
                    size: 55,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 25),
                  Text('"${_currentQuote.text}"',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 25),
                  Text('— ${_currentQuote.author}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _toggleFavorite,
                        tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        color: _isFavorite ? Colors.red : null,
                      ),
                      SizedBox(width: 15),
                      IconButton(
                        onPressed: _copyQuote,
                        tooltip: 'Copy Quote',
                        icon: Icon(Icons.copy_outlined,),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getNewQuote,
                icon: Icon(Icons.refresh_rounded,),
                label: Text('New Quote',),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}