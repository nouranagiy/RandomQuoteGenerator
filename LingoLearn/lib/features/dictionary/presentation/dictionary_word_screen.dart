import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/debug_log.dart';
import '../../vocabulary/data/language_storage.dart';
import '../../vocabulary/data/language_word.dart';
import '../data/dictionary_entry.dart';
import '../data/language_word_mapper.dart';
import 'widgets/meaning_section.dart';
import 'widgets/word_actions.dart';
import 'widgets/word_header.dart';

class DictionaryWordScreen extends StatefulWidget {
  final DictionaryEntry entry;

  const DictionaryWordScreen({super.key, required this.entry});

  @override
  State<DictionaryWordScreen> createState() => _DictionaryWordScreenState();
}

class _DictionaryWordScreenState extends State<DictionaryWordScreen> {
  final LanguageStorage _storage = LanguageStorage();
  final LanguageWordMapper _mapper = const LanguageWordMapper();
  late bool _isSaved;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isSaved = false;
    _refreshSavedState();
  }

  Future<void> _refreshSavedState() async {
    var saved = false;
    try {
      final words = await _storage.getWords();
      saved = words.any(
        (w) => w.word.toLowerCase() == widget.entry.word.toLowerCase(),
      );
    } catch (e) {
      debugLog('DictionaryWord', 'saved-state refresh failed: $e');
      saved = false;
    }
    if (!mounted) return;
    setState(() => _isSaved = saved);
  }

  Future<void> _addToMyWords() async {
    setState(() => _isSaving = true);
    final word = _buildWord();
    try {
      await _storage.addWord(word);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).saveWordFailed)),
      );
      return;
    }
    if (!mounted) return;

    setState(() {
      _isSaved = true;
      _isSaving = false;
    });
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.wordAddedToMyWords)));
  }

  Future<void> _removeFromMyWords() async {
    try {
      final words = await _storage.getWords();
      for (final word in words) {
        if (word.word.toLowerCase() == widget.entry.word.toLowerCase()) {
          await _storage.deleteWord(word.id);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).saveWordFailed)),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isSaved = false);
  }

  LanguageWord _buildWord() {
    return _mapper.toLanguageWord(widget.entry, id: const Uuid().v4());
  }

  void _openPractice() {
    debugLog(
      'DictionaryWord',
      'opening pronunciation practice for "${widget.entry.word}"',
    );
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.pronunciation, arguments: _buildWord());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.entry.word)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          WordHeader(entry: widget.entry),
          const SizedBox(height: 24),
          MeaningSection(meanings: widget.entry.meanings),
          Text(
            '${l.sourceLabel}: ${LanguageWordMapper.sourceName}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          PracticePronunciationButton(onPressed: _openPractice),
          const SizedBox(height: 10),
          AddToWordsButton(
            isSaved: _isSaved,
            isLoading: _isSaving,
            onAdd: _addToMyWords,
            onRemove: _removeFromMyWords,
          ),
        ],
      ),
    );
  }
}
