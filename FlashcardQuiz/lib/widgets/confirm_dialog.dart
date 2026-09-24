import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';

void showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmLabel,
  required VoidCallback onConfirm,
  bool isDestructive = true,
}) {
  final loc = AppLocalizations.of(context);
  final colorScheme = Theme.of(context).colorScheme;

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive
                ? colorScheme.error
                : colorScheme.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
