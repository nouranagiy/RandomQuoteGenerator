class DictionaryEntry {
  final String word;

  final String? phonetic;

  final String? audioUrl;

  final List<DictionaryPhonetic> phonetics;
  final List<DictionaryMeaning> meanings;
  final List<String> sourceUrls;

  const DictionaryEntry({
    required this.word,
    required this.phonetic,
    required this.audioUrl,
    required this.phonetics,
    required this.meanings,
    required this.sourceUrls,
  });

  bool get isEmpty => meanings.isEmpty;

  DictionaryMeaning? get primaryMeaning =>
      meanings.isEmpty ? null : meanings.first;
  DictionaryDefinition? get primaryDefinition =>
      primaryMeaning?.definitions.isEmpty ?? true
      ? null
      : primaryMeaning!.definitions.first;

  String get summary {
    final definition = primaryDefinition?.definition;
    if (definition != null) return definition;
    if (word.isNotEmpty) return word;
    return '';
  }

  String? get firstExample {
    for (final meaning in meanings) {
      for (final definition in meaning.definitions) {
        final example = definition.example?.trim();
        if (example != null && example.isNotEmpty) return example;
      }
    }
    return null;
  }

  String get exampleSentence => firstExample ?? '';

  DictionaryEntry mergedWith(DictionaryEntry? other) {
    if (other == null) return this;
    return DictionaryEntry(
      word: word,
      phonetic: (phonetic == null || phonetic!.trim().isEmpty)
          ? other.phonetic
          : phonetic,
      audioUrl: (audioUrl == null || audioUrl!.trim().isEmpty)
          ? other.audioUrl
          : audioUrl,
      phonetics: phonetics.isNotEmpty ? phonetics : other.phonetics,
      meanings: meanings.isNotEmpty ? meanings : other.meanings,
      sourceUrls: {...sourceUrls, ...other.sourceUrls}.toList(growable: false),
    );
  }
}

class DictionaryPhonetic {
  final String text;
  final String? audio;

  const DictionaryPhonetic({required this.text, required this.audio});

  bool get hasAudio => audio != null && audio!.isNotEmpty;
}

class DictionaryMeaning {
  final String partOfSpeech;
  final List<DictionaryDefinition> definitions;

  const DictionaryMeaning({
    required this.partOfSpeech,
    required this.definitions,
  });
}

class DictionaryDefinition {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  const DictionaryDefinition({
    required this.definition,
    required this.example,
    required this.synonyms,
    required this.antonyms,
  });
}
