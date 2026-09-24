import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/articulation_guide.dart';
import '../../data/pronunciation_assessment_result_model.dart';

/// Shows concrete articulation coaching only for the sounds that actually
/// scored low in the attempt. Unknown phones get a generic imitation tip.
class PronunciationArticulationCard extends StatelessWidget {
  final PronunciationAssessmentResultModel result;

  const PronunciationArticulationCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final entries = <_FailingSound>[];
    for (final word in result.wordResults) {
      for (final phoneme in word.phonemes) {
        if (phoneme.accuracy >= 60) continue;
        final tip = ArticulationGuide.forPhone(phoneme.phone);
        if (tip == null) continue;
        final key = phoneme.phone;
        if (entries.any((e) => e.phone == key)) continue;
        entries.add(
          _FailingSound(phone: key, accuracy: phoneme.accuracy, tip: tip),
        );
      }
    }

    if (entries.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.howToProduceSound,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final entry in entries) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.phone,
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.isArabic ? entry.tip.ar : entry.tip.en,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FailingSound {
  final String phone;
  final int accuracy;
  final ArticulationTip tip;

  const _FailingSound({
    required this.phone,
    required this.accuracy,
    required this.tip,
  });
}
