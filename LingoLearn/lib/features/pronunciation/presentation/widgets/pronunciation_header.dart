import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class PronunciationHeader extends StatelessWidget {
  final bool isRecording;

  final String? subtitle;

  const PronunciationHeader({
    super.key,
    required this.isRecording,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    final label = isRecording
        ? '${l.listening}${subtitle == null ? '' : ' ${subtitle!}'}'
        : l.pronunciationTip;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isRecording ? Icons.graphic_eq_rounded : Icons.hearing_rounded,
          size: 20,
          color: isRecording ? colorScheme.error : colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
