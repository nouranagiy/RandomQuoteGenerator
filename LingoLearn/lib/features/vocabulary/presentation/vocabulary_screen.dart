import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../data/language_storage.dart';
import '../data/language_word.dart';
import 'widgets/word_tile.dart';

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
    final cats = _words.map((w) => w.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<LanguageWord> get _filteredWords {
    return _words.where((word) {
      final matchesCategory =
          _selectedCategory == 'All' || word.category == _selectedCategory;
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch =
          query.isEmpty ||
          word.word.toLowerCase().contains(query) ||
          word.translation.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _toggleFavorite(LanguageWord word) async {
    await _storage.toggleFavorite(word.id);
    await _loadWords();
  }

  Future<void> _deleteWord(LanguageWord word) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.deleteWord,
      message: l.deleteWordConfirm(word.word),
      confirmLabel: l.delete,
    );
    if (confirmed != true) return;
    await _storage.deleteWord(word.id);
    await _loadWords();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.vocabulary),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(
                context,
              ).pushNamed(AppRoutes.addWord);
              if (result == true) await _loadWords();
            },
            tooltip: l.addWord,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoading()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: l.searchWords,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final cat = _categories[index];
                      final selected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat == 'All' ? l.all : cat),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = cat),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _filteredWords.isEmpty
                      ? AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: l.noWordsFound,
                          subtitle: l.tryAnotherSearch,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredWords.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final word = _filteredWords[index];
                            return WordTile(
                              word: word,
                              onTap: () async {
                                await Navigator.of(context).pushNamed(
                                  AppRoutes.wordDetails,
                                  arguments: word,
                                );
                                _loadWords();
                              },
                              onFavorite: () => _toggleFavorite(word),
                              onEdit: () async {
                                final result = await Navigator.of(context)
                                    .pushNamed(
                                      AppRoutes.editWord,
                                      arguments: word,
                                    );
                                if (result == true) await _loadWords();
                              },
                              onDelete: () => _deleteWord(word),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
