import 'dart:math';

import 'package:flutter/material.dart';

import '../models/flashcard.dart';

class QuizScreen extends StatefulWidget {
  final List<Flashcard> flashcards;

  const QuizScreen({
    super.key,
    required this.flashcards,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Random _random = Random();

  late List<Flashcard> _quizCards;
  late List<String> _options;

  int _currentIndex = 0;
  int _score = 0;

  String? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();

    _quizCards = List<Flashcard>.from(widget.flashcards);
    _quizCards.shuffle(_random);

    _generateOptions();
  }

  Flashcard get _currentCard => _quizCards[_currentIndex];

  void _generateOptions() {
    final correctAnswer = _currentCard.answer;

    final allAnswers = widget.flashcards
        .map((card) => card.answer.trim())
        .where(
          (answer) =>
      answer.isNotEmpty &&
          answer != correctAnswer,
    )
        .toSet()
        .toList();

    allAnswers.shuffle(_random);

    final wrongAnswers = <String>[];

    // Add real answers from other flashcards
    wrongAnswers.addAll(
      allAnswers.take(3),
    );

    // Fallback answers if there are less than 3
    // different answers in the flashcards.
    final fallbackAnswers = [
      'I don\'t know',
      'None of the above',
      'Not sure',
    ];

    for (final fallback in fallbackAnswers) {
      if (wrongAnswers.length >= 3) break;

      if (fallback != correctAnswer &&
          !wrongAnswers.contains(fallback)) {
        wrongAnswers.add(fallback);
      }
    }

    _options = [
      correctAnswer,
      ...wrongAnswers.take(3),
    ];

    _options.shuffle(_random);
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;

      if (answer == _currentCard.answer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _quizCards.length - 1) {
      _showResult();
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });

    _generateOptions();
  }

  void _showResult() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          score: _score,
          total: _quizCards.length,
          onTryAgain: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  flashcards: widget.flashcards,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _optionColor(String option) {
    if (!_answered) {
      return Theme.of(context)
          .colorScheme
          .surfaceContainerHighest;
    }

    if (option == _currentCard.answer) {
      return Colors.green.withValues(alpha: 0.15);
    }

    if (option == _selectedAnswer) {
      return Colors.red.withValues(alpha: 0.15);
    }

    return Theme.of(context)
        .colorScheme
        .surfaceContainerHighest;
  }

  Color _borderColor(String option) {
    if (!_answered) {
      return Theme.of(context)
          .colorScheme
          .outlineVariant;
    }

    if (option == _currentCard.answer) {
      return Colors.green;
    }

    if (option == _selectedAnswer) {
      return Colors.red;
    }

    return Theme.of(context)
        .colorScheme
        .outlineVariant;
  }

  IconData? _optionIcon(String option) {
    if (!_answered) {
      return null;
    }

    if (option == _currentCard.answer) {
      return Icons.check_circle;
    }

    if (option == _selectedAnswer) {
      return Icons.cancel;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final card = _currentCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Mode'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_currentIndex + 1}/${_quizCards.length}',
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

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) /
                    _quizCards.length,
                minHeight: 7,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 45,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    card.question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Text(
                      card.category,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final icon = _optionIcon(option);

                  return InkWell(
                    onTap: () {
                      _selectAnswer(option);
                    },
                    borderRadius:
                    BorderRadius.circular(15),
                    child: Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: _optionColor(option),
                        borderRadius:
                        BorderRadius.circular(15),
                        border: Border.all(
                          color: _borderColor(option),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            alignment:
                            Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(
                              String.fromCharCode(
                                65 + index,
                              ),
                              style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Text(
                              option,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                          ),

                          if (icon != null)
                            Icon(
                              icon,
                              color:
                              option ==
                                  _currentCard
                                      .answer
                                  ? Colors.green
                                  : Colors.red,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_answered) ...[
              const SizedBox(height: 12),

              Text(
                _selectedAnswer ==
                    _currentCard.answer
                    ? 'Correct! 🎉'
                    : 'Wrong answer',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _selectedAnswer ==
                      _currentCard.answer
                      ? Colors.green
                      : Colors.red,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: Icon(
                    _currentIndex ==
                        _quizCards.length - 1
                        ? Icons.flag_outlined
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _currentIndex ==
                        _quizCards.length - 1
                        ? 'Finish Quiz'
                        : 'Next Question',
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onTryAgain;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0
        ? 0
        : ((score / total) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70
                    ? Icons.emoji_events_outlined
                    : Icons.sentiment_dissatisfied_outlined,
                size: 90,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),

              const SizedBox(height: 25),

              Text(
                'Quiz Completed!',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                '$percentage%',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '$score correct out of $total',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTryAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Flashcards',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}