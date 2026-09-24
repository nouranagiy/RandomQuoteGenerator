import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/pronunciation_assessment_result_model.dart';

class PronunciationWordFeedback extends StatelessWidget {
  final PronunciationAssessmentResultModel result;

  const PronunciationWordFeedback({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.wordResults.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.focusSounds,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (final word in result.wordResults) ...[
            _WordAccuracyRow(word: word, colorScheme: colorScheme),
            if (word.phonemes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final phoneme in word.phonemes)
                    _PhonemeChip(phoneme: phoneme),
                ],
              ),
            ],
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(child: _LegendDot(color: Colors.green.shade600)),
              Expanded(child: _LegendDot(color: Colors.amber.shade700)),
              Expanded(child: _LegendDot(color: colorScheme.error)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.soundAccuracyLegend,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordAccuracyRow extends StatelessWidget {
  final AssessmentWordResult word;
  final ColorScheme colorScheme;

  const _WordAccuracyRow({required this.word, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _bandColor(word.accuracy, colorScheme);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            word.word,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: _bandForeground(color, colorScheme),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${word.accuracy}%',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        if (word.errorType != PronunciationErrorType.none) ...[
          _ErrorTag(errorType: word.errorType, colorScheme: colorScheme),
        ],
      ],
    );
  }
}

class _ErrorTag extends StatelessWidget {
  final PronunciationErrorType errorType;
  final ColorScheme colorScheme;

  const _ErrorTag({required this.errorType, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        switch (errorType) {
          PronunciationErrorType.omission => l.omissionTag,
          PronunciationErrorType.insertion => l.insertionTag,
          PronunciationErrorType.mispronunciation => l.mispronunciationTag,
          PronunciationErrorType.none => '',
        },
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PhonemeChip extends StatelessWidget {
  final AssessmentPhoneme phoneme;

  const _PhonemeChip({required this.phoneme});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _bandColor(phoneme.accuracy, colorScheme);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        phoneme.phone,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: _bandForeground(color, colorScheme),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

Color _bandColor(int accuracy, ColorScheme colorScheme) {
  if (accuracy >= 85) return Colors.green.shade600;
  if (accuracy >= 60) return Colors.amber.shade700;
  return colorScheme.error;
}

Color _bandForeground(Color background, ColorScheme colorScheme) {
  if (background == Colors.green.shade600 || background == colorScheme.error) {
    return Colors.white;
  }
  if (background == Colors.amber.shade700) return Colors.white;
  return colorScheme.onPrimaryContainer;
}
