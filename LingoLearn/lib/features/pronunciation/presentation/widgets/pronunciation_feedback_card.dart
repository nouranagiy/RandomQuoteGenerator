import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/pronunciation_assessment_result_model.dart';

class PronunciationFeedbackCard extends StatelessWidget {
  final PronunciationAssessmentResultModel result;

  const PronunciationFeedbackCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    final acceptable = result.isAcceptable;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                acceptable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: acceptable ? Colors.green.shade600 : colorScheme.error,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  acceptable ? l.soundsGood : l.doesntSoundRight,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: acceptable
                        ? Colors.green.shade700
                        : colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _feedback(l),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          if (result.recognizedText != null &&
              result.recognizedText!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${l.weHeard} "${result.recognizedText!.trim()}"',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _feedback(AppLocalizations l) {
    if (!result.isScorable && result.wordResults.isEmpty) {
      return l.feedbackWrongWord;
    }
    if (result.hasScores) {
      final errors = result.wordResults;
      final hasMispronunciation = errors.any(
        (word) => word.errorType == PronunciationErrorType.mispronunciation,
      );
      final hasOmission = errors.any(
        (word) => word.errorType == PronunciationErrorType.omission,
      );
      final hasInsertion = errors.any(
        (word) => word.errorType == PronunciationErrorType.insertion,
      );
      if (hasMispronunciation) return l.feedbackFocusPhonemes;
      if (hasOmission) return l.feedbackOmission;
      if (hasInsertion) return l.feedbackInsertion;
      if (!result.isAcceptable) return l.feedbackClose;
    }
    return l.soundsGood;
  }
}
