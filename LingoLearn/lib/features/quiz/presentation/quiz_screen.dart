import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../vocabulary/data/language_storage.dart';
import '../../vocabulary/data/language_word.dart';
import 'widgets/quiz_answer_option.dart';
import 'widgets/quiz_question_card.dart';
import 'widgets/quiz_result_dialog.dart';
import 'widgets/quiz_setup_choice.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final LanguageStorage _storage = LanguageStorage();
  int _quizLength = 10;
  List<LanguageWord> _allWords = [];
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
      _allWords = words;
      _words = words;
      _isLoading = false;
    });
    if (_words.isNotEmpty) _showCategoryDialog();
  }

  Future<void> _showCategoryDialog() async {
    final l = AppLocalizations.of(context);
    final categories = _allWords.map((w) => w.category).toSet().toList()
      ..sort();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.chooseCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.whatToPractice),
            const SizedBox(height: 20),
            QuizSetupChoice(title: l.allCategories, value: 'All'),
            ...categories.map((c) => QuizSetupChoice(title: c, value: c)),
          ],
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _selectedCategory = result);
    _showQuizLengthDialog();
  }

  Future<void> _showQuizLengthDialog() async {
    final l = AppLocalizations.of(context);
    final categoryWords = _allWords.where((w) {
      return _selectedCategory == 'All' || w.category == _selectedCategory;
    }).toList();
    final available = categoryWords.length;

    final result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.chooseQuizLength),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.howManyQuestions),
            const SizedBox(height: 20),
            if (available >= 5)
              QuizSetupChoice(title: l.questionsCount(5), value: 5),
            if (available >= 10)
              QuizSetupChoice(title: l.questionsCount(10), value: 10),
            QuizSetupChoice(title: l.allQuestions, value: available),
          ],
        ),
      ),
    );
    if (!mounted || result == null) return;
    _quizLength = result;
    _startQuiz(categoryWords);
  }

  void _startQuiz(List<LanguageWord> categoryWords) {
    categoryWords.shuffle();
    final count = _quizLength > categoryWords.length
        ? categoryWords.length
        : _quizLength;
    final quizWords = categoryWords.take(count).toList();
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
    final otherWords = _allWords.where((w) => w.id != correctWord.id).toList()
      ..shuffle();
    final options = <String>[correctWord.translation];
    for (final w in otherWords) {
      if (!options.contains(w.translation)) options.add(w.translation);
      if (options.length == 4) break;
    }
    options.shuffle();
    return options;
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == _words[_currentQuestion].translation) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _words.length - 1) {
      final next = _currentQuestion + 1;
      setState(() {
        _currentQuestion = next;
        _selectedAnswer = null;
        _answered = false;
        _currentOptions = _getOptions(_words[next]);
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    await _storage.saveQuizResult(_score, _words.length);
    if (!mounted) return;
    showQuizResultDialog(
      context,
      score: _score,
      total: _words.length,
      onTryAgain: _restartQuiz,
    );
  }

  void _restartQuiz() {
    final words = [..._words]..shuffle();
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.practiceQuiz)),
      body: _isLoading
          ? const AppLoading()
          : _words.isEmpty
          ? AppEmptyState(
              icon: Icons.quiz_outlined,
              title: l.noWordsForQuiz,
              subtitle: l.addWordsBeforeQuiz,
            )
          : _buildQuiz(),
    );
  }

  Widget _buildQuiz() {
    final l = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final word = _words[_currentQuestion];
    final progress = (_currentQuestion + 1) / _words.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.questionNumber(_currentQuestion + 1),
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(l.correctCount(_score), style: textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        AppProgressBar(value: progress, minHeight: 9, radius: 10),
        const SizedBox(height: 35),
        QuizQuestionCard(word: word.word, pronunciation: word.pronunciation),
        const SizedBox(height: 25),
        SectionHeader(title: l.chooseCorrectAnswer),
        ..._currentOptions.map(
          (option) => QuizAnswerOption(
            option: option,
            isCorrect: option == word.translation,
            isSelected: _selectedAnswer == option,
            revealed: _answered,
            onTap: () => _selectAnswer(option),
          ),
        ),
        const SizedBox(height: 25),
        AppButton(
          text: _currentQuestion == _words.length - 1
              ? l.showResult
              : l.nextQuestion,
          onPressed: _answered ? _nextQuestion : null,
        ),
      ],
    );
  }
}
