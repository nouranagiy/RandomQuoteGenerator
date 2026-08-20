import 'package:flutter/material.dart';
import 'edit_word_screen.dart';
import '../models/language_word.dart';
import '../services/language_storage.dart';
import 'add_word_screen.dart';
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});
  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}
class _VocabularyScreenState extends State<VocabularyScreen> {
  final LanguageStorage _storage = LanguageStorage();
  List<LanguageWord> _words = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _loadWords();
  }
  Future<void> _loadWords() async {
    await _storage.initializeDefaultWords();
    final words = await _storage.getWords();
    if (!mounted) return;
    setState(() {
      _words = words;
      _isLoading = false;
    });
  }
  List<String> get _categories {
    final categories = _words.map((word) => word.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }
  List<LanguageWord> get _filteredWords {
    return _words.where((word) {
      final matchesCategory = _selectedCategory == 'All' || word.category == _selectedCategory;
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch = query.isEmpty || word.word.toLowerCase().contains(query) ||
              word.translation.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }
  Future<void> _toggleFavorite(LanguageWord word,) async {
    await _storage.toggleFavorite(word.id);
    await _loadWords();
  }
  void _openWordDetails(LanguageWord word,) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordDetailsScreen(
          word: word,
        ),
      ),
    );
  }
  Future<void> _deleteWord(LanguageWord word) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Word'),
          content: Text('Are you sure you want to delete "${word.word}"?',),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) return;
    await _storage.deleteWord(word.id);
    await _loadWords();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddWordScreen(),
                ),
              );
              if (result == true) {
                await _loadWords();
              }
            },
            tooltip: 'Add Word',
            icon: Icon(Icons.add_rounded,),
          ),
        ],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              15,
              20,
              10,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: Icon(Icons.search_rounded,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _filteredWords.isEmpty ? _buildEmptyState() : ListView.separated(
              padding: EdgeInsets.all(20,),
              itemCount: _filteredWords.length,
              separatorBuilder: (_, _) => SizedBox(
                height: 10,
              ),
              itemBuilder: (context, index) {
                final word = _filteredWords[index];
                return _buildWordCard(
                  word,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildWordCard(LanguageWord word) {
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _toggleFavorite(word);
                },
                tooltip: 'Favorite',
                icon: Icon(
                  word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: word.isFavorite ? Theme.of(context).colorScheme.error : null,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'More options',
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditWordScreen(word: word),
                      ),
                    );
                    if (result == true) {
                      await _loadWords();
                    }
                  }
                  if (value == 'delete') {
                    await _deleteWord(word);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
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
            Icon(Icons.search_off_rounded,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 15),
            Text('No Words Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text('Try another search or category.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
class WordDetailsScreen extends StatefulWidget {
  final LanguageWord word;
  const WordDetailsScreen({
    super.key,
    required this.word,
  });
  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}
class _WordDetailsScreenState extends State<WordDetailsScreen> {
  final LanguageStorage _storage = LanguageStorage();
  late LanguageWord _word;
  @override
  void initState() {
    super.initState();
    _word = widget.word;
  }
  Future<void> _toggleFavorite() async {
    await _storage.toggleFavorite(_word.id);
    final words = await _storage.getWords();
    final index = words.indexWhere((word) => word.id == _word.id,
    );
    if (index == -1 || !mounted) return;
    setState(() {
      _word = words[index];
    });
  }
  Future<void> _toggleLearned() async {
    await _storage.toggleLearned(_word.id);
    final words = await _storage.getWords();
    final index = words.indexWhere((word) => word.id == _word.id,
    );
    if (index == -1 || !mounted) return;
    setState(() {
      _word = words[index];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: 'Favorite',
            icon: Icon(
              _word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _word.isFavorite ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 25),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.translate_rounded,
                size: 55,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 25),
          Center(
            child: Text(_word.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(_word.translation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12),
          Center(
            child: Chip(
              label: Text(_word.category),
            ),
          ),
          SizedBox(height: 30),
          _buildDetailCard(
            icon: Icons.record_voice_over_rounded,
            title: 'Pronunciation',
            value: _word.pronunciation,
          ),
          SizedBox(height: 12),
          _buildDetailCard(
            icon: Icons.format_quote_rounded,
            title: 'Example',
            value: _word.example,
          ),
          SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _toggleLearned,
              icon: Icon(_word.isLearned ? Icons.check_circle_rounded : Icons.school_rounded,),
              label: Text(_word.isLearned ? 'Learned ✓' : 'Mark as Learned',),
            ),
          ),
          SizedBox(height: 10),
          if (_word.isLearned)
            Center(
              child: Text('Great job! You learned this word 🎉',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}