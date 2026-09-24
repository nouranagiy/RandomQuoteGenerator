import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../../../core/widgets/app_progress_bar.dart';

class ProgressCard extends StatelessWidget {
  final double progress;
  final int learned;
  final int total;

  const ProgressCard({
    super.key,
    required this.progress,
    required this.learned,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final percentage = (progress * 100).round();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const AppIconTile(
                icon: Icons.trending_up_rounded,
                size: 48,
                iconSize: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.yourProgress,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.wordsOfTotal(learned, total),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppProgressBar(value: progress),
        ],
      ),
    );
  }
}
