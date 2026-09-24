import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_tile.dart';
import '../../../../core/widgets/word_audio_button.dart';
import '../../data/language_word.dart';

class WordTile extends StatelessWidget {
  final LanguageWord word;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showMenu;

  const WordTile({
    super.key,
    required this.word,
    required this.onTap,
    required this.onFavorite,
    required this.onEdit,
    required this.onDelete,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          const AppIconTile(
            icon: Icons.translate_rounded,
            size: 48,
            iconSize: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.word,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    WordAudioButton(
                      text: word.word,
                      audioUrl: word.audioUrl,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  word.translation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  word.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFavorite,
            icon: Icon(
              word.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: word.isFavorite ? colorScheme.error : null,
            ),
          ),
          if (showMenu)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      const SizedBox(width: 10),
                      Text(l.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline),
                      const SizedBox(width: 10),
                      Text(l.delete),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
