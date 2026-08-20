import 'package:flutter/material.dart';
import 'package:lingolearn/screens/settings_screen.dart';
import '../models/language_word.dart';
import '../services/language_storage.dart';
import 'vocabulary_screen.dart';
import 'quiz_screen.dart';
import 'favorites_screen.dart';
import 'progress_screen.dart';
class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });
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
  int get _learnedWords => _words.where((word) => word.isLearned).length;
  int get _favoriteWords => _words.where((word) => word.isFavorite).length;
  double get _progress {
    if (_totalWords == 0) return 0;
    return (_learnedWords / _totalWords).clamp(0.0, 1.0);
  }
  Future<void> _openVocabulary() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VocabularyScreen(),
      ),
    );

    _loadData();
  }
  Future<void> _openFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(),
      ),
    );
    _loadData();
  }
  Future<void> _openProgress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgressScreen(),
      ),
    );
    _loadData();
  }
  Future<void> _openQuiz() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(),
      ),
    );
    _loadData();
  }
  Future<void> _openDailyLesson() async {
    if (_words.isEmpty) {
      return;
    }
    LanguageWord? lessonWord;
    try {
      lessonWord = _words.firstWhere((word) => !word.isLearned,
      );
    } catch (_) {
      lessonWord = _words.first;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyLessonScreen(
          word: lessonWord!,
        ),
      ),
    );
    _loadData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LingoLearn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  isDarkMode: widget.isDarkMode,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            );
          },
          tooltip: 'Settings',
          icon: Icon(Icons.settings_outlined,),
        ),
      ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading ? Center(
          child: CircularProgressIndicator(),) : ListView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20),
          children: [
            Text('Learn a new language',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Build your vocabulary and improve your language skills every day.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 25),
            _buildProgressCard(),
            SizedBox(height: 25),
            _buildDailyLessonCard(),
            SizedBox(height: 28),
            Text('Quick Practice',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.style_rounded,
                    title: 'Vocabulary',
                    subtitle: '$_totalWords words',
                    onTap: _openVocabulary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.quiz_rounded,
                    title: 'Quiz',
                    subtitle: 'Test yourself',
                    onTap: _openQuiz,
                  ),
                ),
              ],
            ), SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.favorite_rounded,
                    title: 'Favorites',
                    subtitle: '$_favoriteWords saved',
                    onTap: _openFavorites,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Progress',
                    subtitle: '$_learnedWords learned',
                    onTap: _openProgress,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  Widget _buildProgressCard() {
    final percentage = (_progress * 100).round();
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.trending_up_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Progress',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('$_learnedWords of $_totalWords words learned',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('$percentage%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDailyLessonCard() {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _openDailyLesson,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.menu_book_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Lesson',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(_words.isEmpty ? 'No words available' : 'Continue learning a new word',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 15),
              Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class DailyLessonScreen extends StatefulWidget {
  final LanguageWord word;
  const DailyLessonScreen({
    super.key,
    required this.word,
  });
  @override
  State<DailyLessonScreen> createState() => _DailyLessonScreenState();
}
class _DailyLessonScreenState extends State<DailyLessonScreen> {
  final LanguageStorage _storage = LanguageStorage();
  late LanguageWord _word;
  @override
  void initState() {
    super.initState();
    _word = widget.word;
  }
  Future<void> _markAsLearned() async {
    await _storage.toggleLearned(_word.id);
    final words = await _storage.getWords();
    final updatedWord = words.firstWhere((word) => word.id == _word.id,
    );
    if (!mounted) return;
    setState(() {
      _word = updatedWord;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _word.isLearned ? 'Word marked as learned! 🎉' : 'Word marked as not learned.',
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Lesson',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 30),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded,
                size: 55,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 25),
          Center(
            child: Text(
              _word.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(_word.translation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Chip(
              label: Text(_word.category),
            ),
          ),
          SizedBox(height: 25),
          _buildInfoCard(
            icon: Icons.record_voice_over_rounded,
            title: 'Pronunciation',
            value: _word.pronunciation,
          ),
          SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.format_quote_rounded,
            title: 'Example',
            value: _word.example,
          ),
          SizedBox(height: 30),
          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: _markAsLearned,
              icon: Icon(
                _word.isLearned ? Icons.check_circle_rounded : Icons.school_rounded,
              ),
              label: Text(
                _word.isLearned ? 'Learned' : 'Mark as Learned',
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoCard({
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    value,
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