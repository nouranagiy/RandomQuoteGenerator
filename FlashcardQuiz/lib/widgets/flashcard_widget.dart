import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../features/flashcard/domain/flashcard.dart';

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final bool showAnswer;
  final VoidCallback onShowAnswer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.showAnswer,
    required this.onShowAnswer,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashcard.id != widget.flashcard.id) {
      _controller.reset();
      setState(() => _isFront = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
    widget.onShowAnswer();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159265359;
          final isBack = _animation.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(3.14159265359),
                    child: _buildCard(
                      context,
                      title: loc.answerLabel,
                      text: widget.flashcard.answer,
                      isAnswer: true,
                    ),
                  )
                : _buildCard(
                    context,
                    title: loc.questionLabel,
                    text: widget.flashcard.question,
                    isAnswer: false,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String text,
    required bool isAnswer,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isAnswer
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onToggleFavorite,
                icon: Icon(
                  widget.flashcard.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.flashcard.isFavorite ? Colors.red : null,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                onSelected: (value) {
                  if (value == 'edit') {
                    widget.onEdit();
                  } else if (value == 'delete') {
                    widget.onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined),
                        const SizedBox(width: 10),
                        Text(loc.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline),
                        const SizedBox(width: 10),
                        Text(loc.delete),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          if (!isAnswer)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _flipCard,
                icon: const Icon(Icons.flip),
                label: Text(
                  loc.showAnswer,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
