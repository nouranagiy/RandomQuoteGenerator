import 'package:flutter/material.dart';
import '../models/language_word.dart';
import '../services/language_storage.dart';
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}
class _QuizScreenState extends State<QuizScreen> {
  final LanguageStorage _storage = LanguageStorage();
  int _quizLength = 10;
  List<LanguageWord> _words = [];
  String _selectedCategory = 'All';
  int _currentQuestion = 0;
  int _score = 0;
  List<String> _currentOptions = [];
  String? _selectedAnswer;
  bool _answered = false;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }
  Future<void> _loadQuiz() async {
    await _storage.initializeDefaultWords();
    final words = await _storage.getWords();
    if (!mounted) return;
    setState(() {
      _words = words;
      _isLoading = false;
    });
    if (_words.isNotEmpty) {
      _showCategoryDialog();
    }
  }
  Future<void> _showCategoryDialog() async {
    final categories = _words.map((word) => word.category).toSet().toList();
    categories.sort();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Category',
            style: TextStyle(fontWeight: FontWeight.bold,),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What do you want to practice?',),
              SizedBox(height: 20),
              _buildCategoryOption(
                context,
                'All',
                'All Categories',
              ),
              ...categories.map((category) => _buildCategoryOption(
                  context,
                  category,
                  category,
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      _selectedCategory = result;
    });
    _showQuizLengthDialog();
  }
  Widget _buildCategoryOption(
      BuildContext context,
      String value,
      String title,
      ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context, value);
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
        child: Text(title),
      ),
    );
  }
  Future<void> _showQuizLengthDialog() async {
    final categoryWords = _words.where((word) {
      return _selectedCategory == 'All' || word.category == _selectedCategory;
    }).toList();
    final availableQuestions = categoryWords.length;
    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Quiz Length',
            style: TextStyle(fontWeight: FontWeight.bold,),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How many questions do you want?',),
              SizedBox(height: 20),
              if (availableQuestions >= 5)
                _buildQuizLengthOption(
                  context,
                  5,
                  '5 Questions',
                ),
              if (availableQuestions >= 10)
                _buildQuizLengthOption(
                  context,
                  10,
                  '10 Questions',
                ),
              _buildQuizLengthOption(
                context,
                availableQuestions,
                'All Questions',
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || result == null) return;
    _quizLength = result;
    _startQuiz();
  }
  Widget _buildQuizLengthOption(
      BuildContext context,
      int length,
      String title,
      ) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context, length);
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
        child: Text(title),
      ),
    );
  }
  void _startQuiz() {
    final categoryWords = _words.where((word) {
      return _selectedCategory == 'All' || word.category == _selectedCategory;
    }).toList();
    categoryWords.shuffle();
    final questionCount = _quizLength > categoryWords.length ? categoryWords.length : _quizLength;
    final quizWords = categoryWords.take(questionCount).toList();
    setState(() {
      _words = quizWords;
      _currentQuestion = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
      _currentOptions = quizWords.isEmpty ? [] : _getOptions(quizWords[0]);
    });
  }
  List<String> _getOptions(LanguageWord correctWord) {
    final otherWords = _words.where((word) => word.id != correctWord.id).toList();
    otherWords.shuffle();
    final options = <String>[
      correctWord.translation,
    ];
    for (final word in otherWords) {
      if (!options.contains(word.translation)) {
        options.add(word.translation);
      }
      if (options.length == 4) {
        break;
      }
    }
    options.shuffle();
    return options;
  }
  void _selectAnswer(String answer) {
    if (_answered) return;
    final correctAnswer = _words[_currentQuestion].translation;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == correctAnswer) {
        _score++;
      }
    });
  }
  void _nextQuestion() {
    if (_currentQuestion < _words.length - 1) {
      final nextQuestion = _currentQuestion + 1;
      setState(() {
        _currentQuestion = nextQuestion;
        _selectedAnswer = null;
        _answered = false;
        _currentOptions = _getOptions(_words[nextQuestion]);
      });
    } else {
      _showResult();
    }
  }
  void _showResult() async {
    final percentage = _words.isEmpty ? 0 : ((_score / _words.length) * 100).round();
    await _storage.saveQuizResult(
      _score,
      _words.length,
    );
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Quiz Completed!',),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events_rounded,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 20),
              Text('$_score / ${_words.length}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text('$percentage%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _getResultMessage(percentage),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restartQuiz();
              },
              child: Text('Try Again',),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('Done',),
            ),
          ],
        );
      },
    );
  }
  String _getResultMessage(int percentage) {
    if (percentage >= 90) {
      return 'Excellent! You are doing great! 🎉';
    }
    if (percentage >= 70) {
      return 'Great job! Keep practicing! 👏';
    }
    if (percentage >= 50) {
      return 'Good effort! A little more practice will help.';
    }
    return 'Keep practicing and you will improve! 💪';
  }
  void _restartQuiz() {
    final words = [..._words];
    words.shuffle();
    final newWords = words.take(_quizLength).toList();
    setState(() {
      _words = newWords;
      _currentQuestion = 0;
      _score = 0;
      _selectedAnswer = null;
      _answered = false;
      _currentOptions = newWords.isEmpty ? [] : _getOptions(newWords[0]);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice Quiz',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : _words.isEmpty ? _buildEmptyState() : _buildQuiz(),
    );
  }
  Widget _buildQuiz() {
    final word = _words[_currentQuestion];
    final options = _currentOptions;
    final progress = (_currentQuestion + 1) / _words.length;
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${_currentQuestion + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('$_score correct',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 9,
          ),
        ),
        SizedBox(height: 35),
        Card(
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              children: [
                Icon(Icons.translate_rounded,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 20),
                Text('What is the meaning of:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 12),
                Text(word.word,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(word.pronunciation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 25),
        Text('Choose the correct answer:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        ...options.map((option) => _buildAnswerOption(
            option,
            word.translation,
          ),
        ),
        SizedBox(height: 25),
        SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _answered ? _nextQuestion : null,
            child: Text(
              _currentQuestion == _words.length - 1 ? 'Show Result' : 'Next Question',
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildAnswerOption(
      String option,
      String correctAnswer,) {
    final isSelected = _selectedAnswer == option;
    final isCorrect = option == correctAnswer;
    Color? backgroundColor;
    Color? borderColor;
    IconData? statusIcon;
    Color? iconColor;
    if (_answered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.12);
        borderColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        iconColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withValues(alpha: 0.12);
        borderColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        iconColor = Colors.red;
      } else {
        borderColor = Theme.of(context).colorScheme.outlineVariant;
      }
    } else {
      borderColor = Theme.of(context).colorScheme.outlineVariant;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _answered ? null : () {
          _selectAnswer(option);
        },
        child: Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(option,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (statusIcon != null)
                Icon(statusIcon,
                  color: iconColor,
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
            Icon(Icons.quiz_outlined,
              size: 70,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 20),
            Text('No Words Available',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Add some vocabulary words before starting the quiz.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}