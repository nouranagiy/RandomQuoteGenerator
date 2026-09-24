import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_icon_tile.dart';

Future<void> showQuizResultDialog(
  BuildContext context, {
  required int score,
  required int total,
  required VoidCallback onTryAgain,
}) {
  final l = AppLocalizations.of(context);
  final percentage = total == 0 ? 0 : ((score / total) * 100).round();

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final colorScheme = Theme.of(ctx).colorScheme;
      final textTheme = Theme.of(ctx).textTheme;
      return AlertDialog(
        title: Text(l.quizCompleted),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIconTile(
              icon: Icons.emoji_events_rounded,
              size: 90,
              iconSize: 50,
              circle: true,
            ),
            const SizedBox(height: 20),
            Text(
              '$score / $total',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$percentage%',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(_resultMessage(percentage, l), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onTryAgain();
            },
            child: Text(l.tryAgain),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(l.done),
          ),
        ],
      );
    },
  );
}

String _resultMessage(int percentage, AppLocalizations l) {
  if (percentage >= 90) return l.excellent;
  if (percentage >= 70) return l.greatJob;
  if (percentage >= 50) return l.goodEffort;
  return l.keepPracticing;
}
