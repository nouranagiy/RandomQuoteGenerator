import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_button.dart';

class PracticePronunciationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const PracticePronunciationButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: AppLocalizations.of(context).practicePronunciation,
      icon: Icons.record_voice_over_rounded,
      onPressed: onPressed,
      disabled: !enabled,
    );
  }
}

class AddToWordsButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool isLoading;

  const AddToWordsButton({
    super.key,
    required this.isSaved,
    required this.onAdd,
    required this.onRemove,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppButton(
      text: isSaved ? l.removeFromMyWords : l.addToMyWords,
      icon: isSaved
          ? Icons.remove_circle_outline_rounded
          : Icons.playlist_add_rounded,
      type: isSaved ? AppButtonType.outlined : AppButtonType.filled,
      onPressed: isSaved ? onRemove : onAdd,
      isLoading: isLoading,
    );
  }
}
