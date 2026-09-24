import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/word_audio_button.dart';
import '../../vocabulary/data/language_storage.dart';
import '../../vocabulary/data/language_word.dart';

class DailyLessonScreen extends StatefulWidget {
  final LanguageWord word;
  const DailyLessonScreen({super.key, required this.word});

  @override
  State<DailyLessonScreen> createState() => _DailyLessonScreenState();
}

class _DailyLessonScreenState extends State<DailyLessonScreen> {
  final LanguageStorage _storage = LanguageStorage();
  late LanguageWord _word;

  @override
  void initState() {
    super.initState();
    _word = widget.word;
  }

  Future<void> _markAsLearned() async {
    await _storage.toggleLearned(_word.id);
    final words = await _storage.getWords();
    final updated = words.firstWhere((w) => w.id == _word.id);
    if (!mounted) return;
    setState(() => _word = updated);

    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _word.isLearned ? l.wordMarkedLearned : l.wordMarkedNotLearned,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.dailyLesson)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 52,
                color: colorScheme.primary,
              ),
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
                WordAudioButton(text: _word.word, iconSize: 30),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _word.translation,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.primary),
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
          const SizedBox(height: 28),
          AppButton(
            text: _word.isLearned ? l.learned : l.markAsLearned,
            icon: _word.isLearned
                ? Icons.check_circle_rounded
                : Icons.school_rounded,
            onPressed: _markAsLearned,
          ),
        ],
      ),
    );
  }
}
