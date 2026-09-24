import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/welcome_header.dart';
import '../../vocabulary/data/language_storage.dart';
import '../../vocabulary/data/language_word.dart';
import 'widgets/daily_lesson_card.dart';
import 'widgets/home_feature_card.dart';
import 'widgets/progress_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LanguageStorage _storage = LanguageStorage();
  List<LanguageWord> _words = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storage.initializeDefaultWords();
    final words = await _storage.getWords();
    if (!mounted) return;
    setState(() {
      _words = words;
      _isLoading = false;
    });
  }

  int get _totalWords => _words.length;
  int get _learnedWords => _words.where((w) => w.isLearned).length;
  int get _favoriteWords => _words.where((w) => w.isFavorite).length;
  double get _progress {
    if (_totalWords == 0) return 0;
    return (_learnedWords / _totalWords).clamp(0.0, 1.0);
  }

  Future<void> _openScreen(String route) async {
    await Navigator.of(context).pushNamed(route);
    _loadData();
  }

  Future<void> _openDailyLesson() async {
    if (_words.isEmpty) return;
    try {
      final lessonWord = _words.firstWhere((w) => !w.isLearned);
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.dailyLesson, arguments: lessonWord);
      _loadData();
    } catch (_) {
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushNamed(AppRoutes.dailyLesson, arguments: _words.first);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: const AppHeader(actions: [_SettingsButton()]),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const AppLoading()
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const WelcomeHeader(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: HomeFeatureCard(
                          icon: Icons.search_rounded,
                          title: l.dictionary,
                          subtitle: l.searchAnyWord,
                          onTap: () => _openScreen(AppRoutes.dictionary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ProgressCard(
                    progress: _progress,
                    learned: _learnedWords,
                    total: _totalWords,
                  ),
                  const SizedBox(height: 16),
                  DailyLessonCard(
                    hasWords: _words.isNotEmpty,
                    onTap: _openDailyLesson,
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(title: l.quickPractice),
                  Row(
                    children: [
                      Expanded(
                        child: HomeFeatureCard(
                          icon: Icons.style_rounded,
                          title: l.vocabulary,
                          subtitle: l.wordsCount(_totalWords),
                          onTap: () => _openScreen(AppRoutes.vocabulary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HomeFeatureCard(
                          icon: Icons.quiz_rounded,
                          title: l.quiz,
                          subtitle: l.testYourself,
                          onTap: () => _openScreen(AppRoutes.quiz),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: HomeFeatureCard(
                          icon: Icons.favorite_rounded,
                          title: l.favorites,
                          subtitle: l.savedCount(_favoriteWords),
                          onTap: () => _openScreen(AppRoutes.favorites),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HomeFeatureCard(
                          icon: Icons.bar_chart_rounded,
                          title: l.progress,
                          subtitle: l.learnedCount(_learnedWords),
                          onTap: () => _openScreen(AppRoutes.progress),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
      tooltip: l.settings,
      icon: const Icon(Icons.settings_outlined),
    );
  }
}
