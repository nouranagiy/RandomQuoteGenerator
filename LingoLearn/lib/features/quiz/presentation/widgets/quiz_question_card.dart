import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_tile.dart';

class QuizQuestionCard extends StatelessWidget {
  final String word;
  final String pronunciation;

  const QuizQuestionCard({
    super.key,
    required this.word,
    required this.pronunciation,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return AppCard(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const AppIconTile(
            icon: Icons.translate_rounded,
            size: 64,
            iconSize: 34,
          ),
          const SizedBox(height: 20),
          Text(
            l.whatIsTheMeaning,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Text(
            word,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            pronunciation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
