import 'package:flutter/material.dart';

import '../../../../core/widgets/word_audio_button.dart';
import '../../data/dictionary_entry.dart';

class WordHeader extends StatelessWidget {
  final DictionaryEntry entry;

  const WordHeader({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasPhonetic = entry.phonetic != null && entry.phonetic!.isNotEmpty;

    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.menu_book_rounded,
            size: 36,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                entry.word,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            WordAudioButton(
              text: entry.word,
              audioUrl: entry.audioUrl,
              iconSize: 30,
            ),
          ],
        ),
        if (hasPhonetic) ...[
          const SizedBox(height: 4),
          Text(
            entry.phonetic!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
