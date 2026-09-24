import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/dictionary_entry.dart';
import 'part_of_speech_badge.dart';

class MeaningSection extends StatelessWidget {
  final List<DictionaryMeaning> meanings;

  const MeaningSection({super.key, required this.meanings});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            l.meaning,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        for (final meaning in meanings) ...[
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PartOfSpeechBadge(text: meaning.partOfSpeech),
                const SizedBox(height: 12),
                for (var i = 0; i < meaning.definitions.length; i++) ...[
                  if (i > 0) const Divider(height: 24),
                  _DefinitionCard(definition: meaning.definitions[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DefinitionCard extends StatelessWidget {
  final DictionaryDefinition definition;

  const _DefinitionCard({required this.definition});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final terms = <String, List<String>>{};
    if (definition.synonyms.isNotEmpty) {
      terms['synonyms'] = definition.synonyms;
    }
    if (definition.antonyms.isNotEmpty) {
      terms['antonyms'] = definition.antonyms;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          definition.definition,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (definition.example != null && definition.example!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            '“${definition.example!}”',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        for (final entry in terms.entries) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                entry.key == 'synonyms' ? 'synonyms:' : 'antonyms:',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (final term in entry.value)
                Chip(
                  label: Text(term),
                  labelStyle: Theme.of(context).textTheme.labelSmall,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
