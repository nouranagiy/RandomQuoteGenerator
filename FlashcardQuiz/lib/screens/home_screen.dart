import 'package:flutter/material.dart';
import 'package:task1/screens/add_flashcard_screen.dart';
import 'package:task1/screens/edit_flashcard_screen.dart';
import 'package:task1/screens/quiz_screen.dart';
import 'package:task1/widgets/flashcard_widget.dart';

import '../models/flashcard.dart';
import '../services/flashcard_storage.dart';

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
  final FlashcardStorage _storage = FlashcardStorage();

  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'General',
    'Flutter',
    'Dart',
    'Programming',
    'Database',
  ];

  List<Flashcard> _flashcards = [];

  int _currentIndex = 0;

  bool _showAnswer = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final flashcards = await _storage.getFlashcards();

    if (!mounted) return;

    setState(() {
      _flashcards = flashcards;
      _isLoading = false;
    });
  }

  List<Flashcard> get _filteredFlashcards {
    if (_selectedCategory == 'All') {
      return _flashcards;
    }

    return _flashcards
        .where(
          (flashcard) =>
      flashcard.category == _selectedCategory,
    )
        .toList();
  }

  void _nextCard() {
    if (_filteredFlashcards.isEmpty) return;

    setState(() {
      _currentIndex =
          (_currentIndex + 1) % _filteredFlashcards.length;

      _showAnswer = false;
    });
  }

  void _previousCard() {
    if (_filteredFlashcards.isEmpty) return;

    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _filteredFlashcards.length) %
              _filteredFlashcards.length;

      _showAnswer = false;
    });
  }

  Future<void> _editFlashcard(
      Flashcard flashcard,
      ) async {
    final updatedFlashcard = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditFlashcardScreen(
          flashcard: flashcard,
        ),
      ),
    );

    if (updatedFlashcard == null) return;

    final index = _flashcards.indexWhere(
          (item) => item.id == updatedFlashcard.id,
    );

    if (index == -1) return;

    setState(() {
      _flashcards[index] = updatedFlashcard;
      _showAnswer = false;
    });

    await _storage.saveFlashcards(_flashcards);
  }

  Future<void> _deleteFlashcard(
      Flashcard flashcard,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard'),
          content: const Text(
            'Are you sure you want to delete this flashcard?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _flashcards.removeWhere(
            (item) => item.id == flashcard.id,
      );

      if (_flashcards.isEmpty) {
        _currentIndex = 0;
        _showAnswer = false;
      } else if (_currentIndex >= _filteredFlashcards.length) {
        _currentIndex =
            _filteredFlashcards.length - 1;

        if (_currentIndex < 0) {
          _currentIndex = 0;
        }

        _showAnswer = false;
      }
    });

    await _storage.saveFlashcards(_flashcards);
  }

  Future<void> _addFlashcard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFlashcardScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      await _loadFlashcards();

      if (!mounted) return;

      setState(() {
        _currentIndex = 0;
        _showAnswer = false;
      });
    }
  }

  void _toggleFavorite(Flashcard flashcard) async {
    final index = _flashcards.indexWhere(
          (item) => item.id == flashcard.id,
    );

    if (index == -1) return;

    setState(() {
      _flashcards[index].isFavorite =
      !_flashcards[index].isFavorite;
    });

    await _storage.saveFlashcards(_flashcards);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _filteredFlashcards.isEmpty
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    flashcards: _filteredFlashcards,
                  ),
                ),
              );
            },
            tooltip: 'Quiz Mode',
            icon: const Icon(
              Icons.quiz_outlined,
            ),
          ),

          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Light Mode'
                : 'Dark Mode',
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: _buildBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredFlashcards = _filteredFlashcards;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Categories
          SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) =>
              const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];

                final isSelected =
                    _selectedCategory == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                      _currentIndex = 0;
                      _showAnswer = false;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // No flashcards at all
          if (_flashcards.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.style_outlined,
                          size: 50,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'No Flashcards Yet',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Create your first flashcard and start learning.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 25),

                      ElevatedButton.icon(
                        onPressed: _addFlashcard,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Add Your First Flashcard',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )

          // Category has no cards
          else if (filteredFlashcards.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.style_outlined,
                          size: 50,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'No Flashcards in This Category',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Try another category or add a new flashcard.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )

          // Cards exist
          else
            Expanded(
              child: _buildFlashcardsContent(
                filteredFlashcards,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsContent(
      List<Flashcard> filteredFlashcards,
      ) {
    if (_currentIndex >= filteredFlashcards.length) {
      _currentIndex = 0;
    }

    final flashcard = filteredFlashcards[_currentIndex];

    return Column(
      children: [
        const SizedBox(height: 0),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Card ${_currentIndex + 1}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              '${filteredFlashcards.length} Cards',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) /
                filteredFlashcards.length,
            minHeight: 7,
          ),
        ),

        const SizedBox(height: 20),

        // Flashcard
        Center(
          child: FlashcardWidget(
            key: ValueKey(flashcard.id),
            flashcard: flashcard,
            showAnswer: _showAnswer,
            onShowAnswer: () {
              setState(() {
                _showAnswer = true;
              });
            },
            onEdit: () {
              _editFlashcard(flashcard);
            },
            onDelete: () {
              _deleteFlashcard(flashcard);
            },
            onToggleFavorite: () {
              _toggleFavorite(flashcard);
            },
          ),
        ),

        const SizedBox(height: 20),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousCard,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: _nextCard,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}