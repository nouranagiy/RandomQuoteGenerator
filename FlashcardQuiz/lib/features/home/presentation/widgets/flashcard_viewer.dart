import 'package:flutter/material.dart';

import '../../../flashcard/domain/flashcard.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../widgets/flashcard_widget.dart';

class FlashcardViewer extends StatelessWidget {
  final List<Flashcard> flashcards;
  final int currentIndex;
  final bool showAnswer;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShowAnswer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const FlashcardViewer({
    super.key,
    required this.flashcards,
    required this.currentIndex,
    required this.showAnswer,
    required this.onNext,
    required this.onPrevious,
    required this.onShowAnswer,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final flashcard = flashcards[currentIndex];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${loc.card} ${currentIndex + 1}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${flashcards.length} ${loc.cards}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / flashcards.length,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FlashcardWidget(
            key: ValueKey(flashcard.id),
            flashcard: flashcard,
            showAnswer: showAnswer,
            onShowAnswer: onShowAnswer,
            onEdit: onEdit,
            onDelete: onDelete,
            onToggleFavorite: onToggleFavorite,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrevious,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(loc.previous),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(loc.next),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
