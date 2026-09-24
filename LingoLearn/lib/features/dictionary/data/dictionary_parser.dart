import 'dart:convert';

import 'dictionary_entry.dart';

class DictionaryParser {
  const DictionaryParser();

  DictionaryEntry? parseEntry(Object? body) {
    try {
      final data = body is String ? jsonDecode(body) : body;
      if (data is! List || data.isEmpty) return null;
      final map = data.first;
      if (map is! Map<String, dynamic>) return null;

      final word = (map['word'] as String? ?? '').trim();
      if (word.isEmpty) return null;

      final phonetics = <DictionaryPhonetic>[];
      final rawPhonetics = map['phonetics'];
      if (rawPhonetics is List) {
        for (final item in rawPhonetics) {
          if (item is! Map<String, dynamic>) continue;
          final text = (item['text'] as String? ?? '').trim();
          final audio = (item['audio'] as String? ?? '').trim();
          if (text.isNotEmpty || audio.isNotEmpty) {
            phonetics.add(
              DictionaryPhonetic(
                text: text,
                audio: audio.isEmpty ? null : audio,
              ),
            );
          }
        }
      }

      final meanings = <DictionaryMeaning>[];
      final rawMeanings = map['meanings'];
      if (rawMeanings is List) {
        for (final item in rawMeanings) {
          if (item is! Map<String, dynamic>) continue;
          final definitions = <DictionaryDefinition>[];
          final rawDefinitions = item['definitions'];
          if (rawDefinitions is List) {
            for (final d in rawDefinitions) {
              if (d is! Map<String, dynamic>) continue;
              final definition = (d['definition'] as String? ?? '').trim();
              if (definition.isEmpty) continue;
              final example = (d['example'] as String? ?? '').trim();
              definitions.add(
                DictionaryDefinition(
                  definition: definition,
                  example: example.isEmpty ? null : example,
                  synonyms: _sanitizeStringList(d['synonyms']),
                  antonyms: _sanitizeStringList(d['antonyms']),
                ),
              );
            }
          }
          final pos = (item['partOfSpeech'] as String? ?? '').trim();
          if (definitions.isNotEmpty) {
            meanings.add(
              DictionaryMeaning(partOfSpeech: pos, definitions: definitions),
            );
          }
        }
      }

      if (meanings.isEmpty) return null;

      final sourceUrls = _sanitizeStringList(map['sourceUrls']);

      final phonetic = _primaryPhonetic(map, phonetics);
      final audioUrl = _primaryAudioUrl(phonetics);

      return DictionaryEntry(
        word: word,
        phonetic: phonetic,
        audioUrl: audioUrl,
        phonetics: phonetics,
        meanings: meanings,
        sourceUrls: sourceUrls,
      );
    } catch (_) {
      return null;
    }
  }

  List<String> parseSuggestions(Object? body) {
    try {
      final data = body is String ? jsonDecode(body) : body;
      if (data is! List) return const [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => (e['word'] as String? ?? '').trim())
          .where((w) => w.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String? _primaryPhonetic(
    Map<String, dynamic> map,
    List<DictionaryPhonetic> phonetics,
  ) {
    final direct = (map['phonetic'] as String? ?? '').trim();
    if (direct.isNotEmpty) return direct;
    for (final p in phonetics) {
      if (p.text.isNotEmpty) return p.text;
    }
    return null;
  }

  String? _primaryAudioUrl(List<DictionaryPhonetic> phonetics) {
    for (final p in phonetics) {
      if (p.hasAudio) return p.audio;
    }
    return null;
  }

  List<String> _sanitizeStringList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}
