import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

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
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = total == 0 ? 0 : ((score / total) * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(loc.quizMode), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70
                    ? Icons.emoji_events_outlined
                    : Icons.sentiment_dissatisfied_outlined,
                size: 90,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 25),
              Text(
                loc.quizCompleted,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$score ${loc.correctOutOf} $total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTryAgain,
                  icon: const Icon(Icons.refresh),
                  label: Text(loc.tryAgain),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.backToFlashcards),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
