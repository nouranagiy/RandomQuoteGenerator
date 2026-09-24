import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icon_tile.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/word_audio_button.dart';
import '../data/language_storage.dart';
import '../data/language_word.dart';

class WordDetailsScreen extends StatefulWidget {
  final LanguageWord word;
  const WordDetailsScreen({super.key, required this.word});

  @override
  State<WordDetailsScreen> createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  final LanguageStorage _storage = LanguageStorage();
  late LanguageWord _word;

  @override
  void initState() {
    super.initState();
    _word = widget.word;
  }

  Future<void> _toggleFavorite() async {
    await _storage.toggleFavorite(_word.id);
    final words = await _storage.getWords();
    final index = words.indexWhere((w) => w.id == _word.id);
    if (index == -1 || !mounted) return;
    setState(() => _word = words[index]);
  }

  Future<void> _toggleLearned() async {
    await _storage.toggleLearned(_word.id);
    final words = await _storage.getWords();
    final index = words.indexWhere((w) => w.id == _word.id);
    if (index == -1 || !mounted) return;
    setState(() => _word = words[index]);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.wordDetails),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(
              _word.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _word.isFavorite ? colorScheme.error : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: AppIconTile(
              icon: Icons.translate_rounded,
              size: 100,
              iconSize: 48,
              circle: true,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _word.word,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                WordAudioButton(
                  text: _word.word,
                  audioUrl: _word.audioUrl,
                  iconSize: 30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _word.translation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Chip(label: Text(_word.category))),
          const SizedBox(height: 24),
          InfoCard(
            icon: Icons.record_voice_over_rounded,
            title: l.pronunciation,
            value: _word.pronunciation,
          ),
          const SizedBox(height: 10),
          InfoCard(
            icon: Icons.format_quote_rounded,
            title: l.example,
            value: _word.example,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: l.practicePronunciation,
            icon: Icons.record_voice_over_rounded,
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.pronunciation, arguments: _word),
          ),
          const SizedBox(height: 10),
          AppButton(
            text: _word.isLearned ? '${l.learned} ✓' : l.markAsLearned,
            icon: _word.isLearned
                ? Icons.check_circle_rounded
                : Icons.school_rounded,
            type: AppButtonType.elevated,
            onPressed: _toggleLearned,
          ),
          if (_word.isLearned) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                l.greatJobLearned,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
