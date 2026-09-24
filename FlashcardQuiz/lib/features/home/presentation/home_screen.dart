import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/firestore_error.dart';
import '../../../widgets/app_header.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/welcome_header.dart';
import '../../flashcard/data/flashcard_repository.dart';
import '../../flashcard/data/flashcard_storage.dart';
import '../../flashcard/domain/flashcard.dart';
import '../../flashcard/presentation/screens/flashcard_form_screen.dart';
import '../../flashcard/presentation/screens/quiz_screen.dart';
import 'widgets/category_chips.dart';
import 'widgets/flashcard_viewer.dart';
import 'widgets/settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final ValueChanged<ThemeMode> onSetThemeMode;
  final String languageCode;
  final ThemeMode currentThemeMode;
  final ValueChanged<String> onLanguageChanged;

  const HomeScreen({
    super.key,
    required this.onLogout,
    required this.onSetThemeMode,
    required this.languageCode,
    required this.currentThemeMode,
    required this.onLanguageChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlashcardRepository _flashcardRepository = FlashcardRepository();
  final AuthService _authService = AuthService();

  Stream<List<Flashcard>>? _flashcardsStream;
  UserProfile? _userProfile;
  String _selectedCategory = AppConstants.allCategory;
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  bool _isLoading = true;
  bool _isLoadingProfile = true;
  bool _migrationDone = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _subscribeFlashcards();
    _migrateLocalDataOnce();
  }

  @override
  void dispose() {
    _flashcardsStream = null;
    super.dispose();
  }

  /// Migrates locally stored flashcards into Firestore once per session.
  Future<void> _migrateLocalDataOnce() async {
    if (_migrationDone) return;
    _migrationDone = true;
    try {
      final oldStorage = FlashcardStorage();
      final localFlashcards = await oldStorage.getFlashcards();
      if (localFlashcards.isEmpty) return;
      await _flashcardRepository.importLocalFlashcards(localFlashcards);
      await oldStorage.clearFlashcards();
    } catch (_) {
      // Best-effort migration; Firestore remains the source of truth.
    }
  }

  void _subscribeFlashcards() {
    _flashcardsStream = _flashcardRepository.watchFlashcards();
    _flashcardsStream!.listen(
      (flashcards) {
        if (!mounted) return;
        setState(() {
          _flashcards = flashcards;
          _isLoading = false;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        final loc = AppLocalizations.of(context);
        setState(() => _isLoading = false);
        _showErrorSnackbar(loc, error);
      },
    );
  }

  void _showErrorSnackbar(AppLocalizations loc, Object error) {
    final message = firestoreErrorMessage(loc, error);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await _authService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userProfile = null;
        _isLoadingProfile = false;
      });
    }
  }

  List<Flashcard> get _filteredFlashcards {
    if (_selectedCategory == AppConstants.allCategory) {
      return _flashcards;
    }
    return _flashcards.where((fc) => fc.category == _selectedCategory).toList();
  }

  void _nextCard() {
    if (_filteredFlashcards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _filteredFlashcards.length;
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

  Future<void> _editFlashcard(Flashcard flashcard) async {
    final loc = AppLocalizations.of(context);
    final updatedFlashcard = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardFormScreen(flashcard: flashcard),
      ),
    );

    if (updatedFlashcard == null) return;

    try {
      await _flashcardRepository.updateFlashcard(updatedFlashcard);
      if (!mounted) return;
      setState(() => _showAnswer = false);
    } catch (error) {
      if (!mounted) return;
      _showErrorSnackbar(loc, error);
    }
  }

  Future<void> _deleteFlashcard(Flashcard flashcard) async {
    final loc = AppLocalizations.of(context);
    showConfirmDialog(
      context: context,
      title: loc.deleteFlashcard,
      content: loc.deleteConfirmation,
      confirmLabel: loc.delete,
      onConfirm: () async {
        try {
          await _flashcardRepository.deleteFlashcard(flashcard.id);
          if (!mounted) return;
          setState(() {
            if (_filteredFlashcards.isNotEmpty &&
                _currentIndex >= _filteredFlashcards.length) {
              _currentIndex = _filteredFlashcards.length - 1;
            }
            _showAnswer = false;
          });
        } catch (error) {
          if (!mounted) return;
          _showErrorSnackbar(loc, error);
        }
      },
    );
  }

  Future<void> _addFlashcard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FlashcardFormScreen()),
    );

    if (result == true && mounted) {
      setState(() {
        _currentIndex = 0;
        _showAnswer = false;
      });
    }
  }

  Future<void> _toggleFavorite(Flashcard flashcard) async {
    final loc = AppLocalizations.of(context);
    final newValue = !flashcard.isFavorite;
    setState(() {
      final index = _flashcards.indexWhere((item) => item.id == flashcard.id);
      if (index != -1) {
        _flashcards[index].isFavorite = newValue;
      }
    });

    try {
      await _flashcardRepository.updateFavorite(flashcard.id, newValue);
    } catch (error) {
      if (!mounted) return;
      _showErrorSnackbar(loc, error);
    }
  }

  void _logout() async {
    final loc = AppLocalizations.of(context);
    showConfirmDialog(
      context: context,
      title: loc.logout,
      content: '${loc.logout}?',
      confirmLabel: loc.logout,
      isDestructive: true,
      onConfirm: () async {
        await _authService.signOut();
        if (!mounted) return;
        widget.onLogout();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppHeader(
        actions: [
          IconButton(
            onPressed: _filteredFlashcards.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            QuizScreen(flashcards: _filteredFlashcards),
                      ),
                    );
                  },
            tooltip: loc.quizMode,
            icon: const Icon(Icons.quiz_outlined),
          ),
          IconButton(
            onPressed: () => _showSettings(context),
            tooltip: loc.settings,
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        tooltip: loc.addFlashcard,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SettingsSheet(
        onLogout: _logout,
        onSetThemeMode: widget.onSetThemeMode,
        currentThemeMode: widget.currentThemeMode,
        languageCode: widget.languageCode,
        onLanguageChanged: widget.onLanguageChanged,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget();
    }

    final filteredFlashcards = _filteredFlashcards;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeHeader(
            userName: _userProfile?.name ?? '',
            isLoading: _isLoadingProfile,
          ),
          const SizedBox(height: 16),
          CategoryChips(
            categories: AppConstants.categories,
            selected: _selectedCategory,
            onSelected: (category) {
              setState(() {
                _selectedCategory = category;
                _currentIndex = 0;
                _showAnswer = false;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildContent(filteredFlashcards)),
        ],
      ),
    );
  }

  Widget _buildContent(List<Flashcard> filteredFlashcards) {
    final loc = AppLocalizations.of(context);

    if (_flashcards.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.style_outlined,
        title: loc.noFlashcardsYet,
        description: loc.noFlashcardsDescription,
        actionLabel: loc.addFirstFlashcard,
        onAction: _addFlashcard,
      );
    }

    if (filteredFlashcards.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.filter_list_off_outlined,
        title: loc.noFlashcardsInCategory,
        description: loc.tryAnotherCategory,
      );
    }

    if (_currentIndex >= filteredFlashcards.length) {
      _currentIndex = 0;
    }

    final flashcard = filteredFlashcards[_currentIndex];

    return FlashcardViewer(
      flashcards: filteredFlashcards,
      currentIndex: _currentIndex,
      showAnswer: _showAnswer,
      onNext: _nextCard,
      onPrevious: _previousCard,
      onShowAnswer: () => setState(() => _showAnswer = true),
      onEdit: () => _editFlashcard(flashcard),
      onDelete: () => _deleteFlashcard(flashcard),
      onToggleFavorite: () => _toggleFavorite(flashcard),
    );
  }
}
