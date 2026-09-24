import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/pronunciation_assessment_result_model.dart';
import 'pronunciation_articulation_card.dart';
import 'pronunciation_audio_controls.dart';
import 'pronunciation_feedback_card.dart';
import 'pronunciation_score_card.dart';
import 'pronunciation_word_feedback.dart';

class PronunciationResultView extends StatelessWidget {
  final PronunciationAssessmentResultModel result;

  final String? referenceAudioUrl;

  final String? attemptAudioPath;

  final VoidCallback onRetry;
  final VoidCallback onNextWord;

  const PronunciationResultView({
    super.key,
    required this.result,
    required this.referenceAudioUrl,
    required this.attemptAudioPath,
    required this.onRetry,
    required this.onNextWord,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        PronunciationScoreCard(result: result),
        const SizedBox(height: 12),
        PronunciationFeedbackCard(result: result),
        if (result.wordResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          PronunciationWordFeedback(result: result),
        ],
        const SizedBox(height: 12),
        PronunciationArticulationCard(result: result),
        const SizedBox(height: 16),
        PronunciationAudioControls(
          word: result.target,
          referenceAudioUrl: referenceAudioUrl,
          attemptAudioPath: attemptAudioPath,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: l.tryAgain,
                icon: Icons.refresh_rounded,
                type: AppButtonType.outlined,
                onPressed: onRetry,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: l.nextWord,
                icon: Icons.skip_next_rounded,
                onPressed: onNextWord,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          l.attemptLabel(result.attempt),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
