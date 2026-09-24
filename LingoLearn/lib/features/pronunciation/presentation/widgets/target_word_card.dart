import 'package:flutter/material.dart';

import '../../../../core/services/word_audio_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/word_audio_button.dart';
import '../../../../features/vocabulary/data/language_word.dart';
import '../../data/pronunciation_config.dart';

class TargetWordCard extends StatelessWidget {
  final LanguageWord word;

  const TargetWordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.record_voice_over_rounded,
              size: 30,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            word.word,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (word.phonetic == null || word.phonetic!.trim().isEmpty) ...[
            if (word.pronunciation.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                word.pronunciation,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 6),
            Text(
              '/${word.phonetic!.trim()}/',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            word.translation,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Chip(label: Text(word.category)),
          const SizedBox(height: 20),
          WordAudioButton(
            text: word.word,
            playOverride: () => WordAudioService().playReference(
              word.word,
              audioUrl: word.audioUrl,
              languageCode: PronunciationConfig.languageCode,
            ),
            compact: false,
          ),
        ],
      ),
    );
  }
}
