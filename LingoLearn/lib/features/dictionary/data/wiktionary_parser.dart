import 'dart:convert';

import 'dictionary_entry.dart';

class WiktionaryParser {
  const WiktionaryParser();

  static const int _maxDefinitionsPerPos = 5;
  static const String _sourceUrlPrefix = 'https://en.wiktionary.org/wiki/';

  DictionaryEntry? parseEntry(
    String body, {
    String? word,
    String? audioMediaList,
  }) {
    try {
      final data = jsonDecode(body);
      if (data is! Map<String, dynamic>) return null;

      final senses = data['en'];
      if (senses is! List || senses.isEmpty) return null;

      final wordValue = (word ?? '').trim();
      if (wordValue.isEmpty) return null;

      final meanings = <DictionaryMeaning>[];
      for (final sense in senses.whereType<Map<String, dynamic>>()) {
        final pos = (sense['partOfSpeech'] as String? ?? '')
            .trim()
            .toLowerCase();
        final rawDefinitions = sense['definitions'];
        if (rawDefinitions is! List) continue;

        final definitions = <DictionaryDefinition>[];
        for (final d in rawDefinitions.whereType<Map<String, dynamic>>()) {
          final definition = _stripHtml(
            (d['definition'] as String? ?? '').trim(),
          );
          if (definition.isEmpty) continue;
          definitions.add(
            DictionaryDefinition(
              definition: definition,
              example: _firstExample(d),
              synonyms: const [],
              antonyms: const [],
            ),
          );
          if (definitions.length >= _maxDefinitionsPerPos) break;
        }
        if (definitions.isNotEmpty) {
          meanings.add(
            DictionaryMeaning(partOfSpeech: pos, definitions: definitions),
          );
        }
      }
      if (meanings.isEmpty) return null;

      return DictionaryEntry(
        word: wordValue,
        phonetic: null,
        audioUrl: _audioUrlFromMediaList(audioMediaList),
        phonetics: const [],
        meanings: meanings,
        sourceUrls: [_sourceUrlPrefix + Uri.encodeComponent(wordValue)],
      );
    } catch (_) {
      return null;
    }
  }

  String? _firstExample(Map<String, dynamic> definition) {
    final parsed = definition['parsedExamples'];
    if (parsed is List) {
      for (final item in parsed.whereType<Map<String, dynamic>>()) {
        final example = _stripHtml((item['example'] as String? ?? '').trim());
        if (example.isNotEmpty) return example;
      }
    }
    final raw = definition['examples'];
    if (raw is List) {
      for (final example in raw.whereType<String>()) {
        final clean = _stripHtml(example.trim());
        if (clean.isNotEmpty) return clean;
      }
    }
    return null;
  }

  String? _audioUrlFromMediaList(String? mediaList) {
    if (mediaList == null || mediaList.isEmpty) return null;
    try {
      final data = jsonDecode(mediaList);
      if (data is! Map<String, dynamic>) return null;
      final items = data['items'];
      if (items is! List) return null;
      for (final item in items.whereType<Map<String, dynamic>>()) {
        if (item['type'] != 'audio') continue;
        final title = (item['title'] as String? ?? '').trim();
        if (!title.startsWith('File:')) continue;
        final filename = title.substring('File:'.length).trim();
        if (filename.isEmpty) continue;
        return 'https://commons.wikimedia.org/wiki/Special:FilePath/'
            '${Uri.encodeComponent(filename)}';
      }
    } catch (_) {}
    return null;
  }

  String _stripHtml(String input) {
    var text = input.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&rsquo;', '\u2019')
        .replaceAll('&lsquo;', '\u2018')
        .replaceAll('&ldquo;', '\u201C')
        .replaceAll('&rdquo;', '\u201D')
        .replaceAll('&mdash;', '\u2014')
        .replaceAll('&ndash;', '\u2013')
        .replaceAll('&hellip;', '\u2026')
        .replaceAll('&amp;', '&');
    text = text.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (m) => String.fromCharCode(int.tryParse(m[1]!) ?? 0),
    );
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
