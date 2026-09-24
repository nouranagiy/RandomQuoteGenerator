import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon_tile.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../vocabulary/data/language_storage.dart';
import '../../vocabulary/data/language_word.dart';
import 'widgets/progress_stat_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final LanguageStorage _storage = LanguageStorage();
  bool _isLoading = true;

  List<LanguageWord> _words = [];
  int _quizCount = 0;
  int _bestScore = 0;
  int _bestTotal = 0;
  int _lastScore = 0;
  int _lastTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final words = await _storage.getWords();
    final quizCount = await _storage.getQuizCount();
    final bestScore = await _storage.getBestQuizScore();
    final bestTotal = await _storage.getBestQuizTotal();
    final lastScore = await _storage.getLastQuizScore();
    final lastTotal = await _storage.getLastQuizTotal();
    if (!mounted) return;
    setState(() {
      _words = words;
      _quizCount = quizCount;
      _bestScore = bestScore;
      _bestTotal = bestTotal;
      _lastScore = lastScore;
      _lastTotal = lastTotal;
      _isLoading = false;
    });
  }

  int get _totalWords => _words.length;
  int get _learnedWords => _words.where((w) => w.isLearned).length;
  int get _favoriteWords => _words.where((w) => w.isFavorite).length;

  List<MapEntry<String, int>> get _categoryCounts {
    final map = <String, int>{};
    for (final w in _words) {
      map[w.category] = (map[w.category] ?? 0) + 1;
    }
    return map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final learningProgress = _totalWords == 0
        ? 0.0
        : _learnedWords / _totalWords;

    return Scaffold(
      appBar: AppBar(title: Text(l.myProgress)),
      body: _isLoading
          ? const AppLoading()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SectionHeader(title: l.learningProgress),
                StatRow(
                  children: [
                    ProgressStatCard(
                      icon: Icons.style_rounded,
                      title: l.totalWords,
                      value: '$_totalWords',
                      color: colorScheme.primary,
                    ),
                    ProgressStatCard(
                      icon: Icons.school_rounded,
                      title: l.learned,
                      value: '$_learnedWords',
                      color: Colors.green,
                    ),
                    ProgressStatCard(
                      icon: Icons.favorite_rounded,
                      title: l.favorites,
                      value: '$_favoriteWords',
                      color: colorScheme.error,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.wordsOfTotal(_learnedWords, _totalWords),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppProgressBar(value: learningProgress, minHeight: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SectionHeader(title: l.quizPerformance),
                if (_quizCount == 0)
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l.takeFirstQuiz,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else ...[
                  StatRow(
                    children: [
                      ProgressStatCard(
                        icon: Icons.quiz_rounded,
                        title: l.quizzes,
                        value: '$_quizCount',
                        color: colorScheme.primary,
                      ),
                      ProgressStatCard(
                        icon: Icons.emoji_events_rounded,
                        title: l.bestScore,
                        value: _bestTotal == 0
                            ? '0%'
                            : '${((_bestScore / _bestTotal) * 100).round()}%',
                        color: Colors.amber,
                      ),
                      ProgressStatCard(
                        icon: Icons.history_rounded,
                        title: l.lastScore,
                        value: _lastTotal == 0
                            ? '0%'
                            : '${((_lastScore / _lastTotal) * 100).round()}%',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l.quizzesCompleted(_quizCount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SectionHeader(title: l.categories),
                if (_categoryCounts.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l.noWordsFound,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...List.generate(_categoryCounts.length, (index) {
                    final entry = _categoryCounts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: ListTile(
                          leading: const AppIconTile(
                            icon: Icons.category_rounded,
                            size: 40,
                            iconSize: 20,
                            borderRadius: 10,
                          ),
                          title: Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Text(
                            l.wordsCount(entry.value),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
