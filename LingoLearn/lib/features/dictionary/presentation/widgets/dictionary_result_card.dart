import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/word_audio_button.dart';
import '../../data/dictionary_entry.dart';
import 'part_of_speech_badge.dart';

class DictionaryResultCard extends StatelessWidget {
  final DictionaryEntry entry;
  final VoidCallback onTap;

  const DictionaryResultCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (entry.phonetic != null &&
                        entry.phonetic!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.phonetic!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (entry.primaryMeaning != null)
                      PartOfSpeechBadge(
                        text: entry.primaryMeaning!.partOfSpeech,
                      ),
                  ],
                ),
              ),
              WordAudioButton(
                text: entry.word,
                audioUrl: entry.audioUrl,
                iconSize: 28,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(entry.summary, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context).viewDetails,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
