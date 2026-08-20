import 'package:flutter/material.dart';
import '../models/language_word.dart';
import '../services/language_storage.dart';
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}
class _ProgressScreenState extends State<ProgressScreen> {
  final LanguageStorage _storage = LanguageStorage();
  List<LanguageWord> _words = [];
  int _quizCount = 0;
  int _bestScore = 0;
  int _lastScore = 0;
  int _bestTotal = 0;
  int _lastTotal = 0;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }
  Future<void> _loadProgress() async {
    await _storage.initializeDefaultWords();
    final words = await _storage.getWords();
    final quizCount = await _storage.getQuizCount();
    final bestScore = await _storage.getBestQuizScore();
    final lastScore = await _storage.getLastQuizScore();
    final bestTotal = await _storage.getBestQuizTotal();
    final lastTotal = await _storage.getLastQuizTotal();
    if (!mounted) return;
    setState(() {
      _words = words;
      _quizCount = quizCount;
      _bestScore = bestScore;
      _lastScore = lastScore;
      _bestTotal = bestTotal;
      _lastTotal = lastTotal;
      _isLoading = false;
    });
  }
  int get _totalWords => _words.length;
  int get _learnedWords => _words.where((word) => word.isLearned).length;
  int get _favoriteWords => _words.where((word) => word.isFavorite).length;
  double get _progress {
    if (_totalWords == 0) return 0;
    return (_learnedWords / _totalWords).clamp(0.0, 1.0);
  }
  Map<String, int> get _categoryCounts {
    final Map<String, int> counts = {};
    for (final word in _words) {
      counts[word.category] = (counts[word.category] ?? 0) + 1;
    }
    return counts;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: _loadProgress,
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          children: [
            Text('Learning Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text('Keep learning and build your vocabulary every day.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 25),
            _buildProgressOverview(),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Total Words',
                    value: '$_totalWords',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.school_rounded,
                    title: 'Learned',
                    value: '$_learnedWords',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.favorite_rounded,
                    title: 'Favorites',
                    value: '$_favoriteWords',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.quiz_rounded,
                    title: 'Quizzes',
                    value: '$_quizCount',
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text('Quiz Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _buildQuizPerformance(),
            SizedBox(height: 30),
            Text('Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            ..._categoryCounts.entries.map((entry) => _buildCategoryCard(
                entry.key,
                entry.value,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget _buildProgressOverview() {
    final percentage = (_progress * 100).round();
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$percentage%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Your Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text('$_learnedWords of $_totalWords words learned',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuizPerformance() {
    final bestPercentage = _bestTotal == 0 ? 0 : ((_bestScore / _bestTotal) * 100).round();
    final lastPercentage = _lastTotal == 0 ? 0 : ((_lastScore / _lastTotal) * 100).round();
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildQuizStat(
                    icon: Icons.emoji_events_rounded,
                    title: 'Best Score',
                    value: '$_bestScore / $_bestTotal',
                    percentage: '$bestPercentage%',
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildQuizStat(
                    icon: Icons.history_rounded,
                    title: 'Last Score',
                    value: '$_lastScore / $_lastTotal',
                    percentage: '$lastPercentage%',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_quizCount == 0)
              Text('Take your first quiz to see your performance here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              Text('You have completed $_quizCount quiz${_quizCount == 1 ? '' : 'zes'}.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildQuizStat({
    required IconData icon,
    required String title,
    required String value,
    required String percentage,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 10),
          Text(title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3),
          Text(percentage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 15),
            Text(title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 5),
            Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildCategoryCard(String category, int count) {
    final categoryProgress = _totalWords == 0 ? 0.0 : count / _totalWords;
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.category_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: categoryProgress,
                      minHeight: 7,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Text('$count',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}