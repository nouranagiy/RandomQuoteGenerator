import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/word_audio_service.dart';
import '../../../../core/widgets/word_audio_button.dart';
import '../../data/pronunciation_config.dart';

class PronunciationAudioControls extends StatelessWidget {
  final String word;
  final String? referenceAudioUrl;
  final String? attemptAudioPath;

  const PronunciationAudioControls({
    super.key,
    required this.word,
    required this.referenceAudioUrl,
    required this.attemptAudioPath,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: WordAudioButton(
                text: word,
                playOverride: attemptAudioPath == null
                    ? null
                    : () => WordAudioService().playAttempt(attemptAudioPath!),
                label: l.yourAttempt,
                idleIcon: Icons.record_voice_over_rounded,
                enabled: attemptAudioPath != null,
                compact: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WordAudioButton(
                text: word,
                playOverride: () => WordAudioService().playReference(
                  word,
                  audioUrl: referenceAudioUrl,
                  languageCode: PronunciationConfig.languageCode,
                ),
                label: l.reference,
                compact: false,
              ),
            ),
          ],
        ),
        if (attemptAudioPath == null) ...[
          const SizedBox(height: 8),
          Text(
            l.attemptAudioUnavailable,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
