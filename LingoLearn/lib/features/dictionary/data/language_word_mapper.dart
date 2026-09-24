import '../../vocabulary/data/language_word.dart';
import 'dictionary_entry.dart';

class LanguageWordMapper {
  const LanguageWordMapper();

  static const String sourceName = 'Free Dictionary API';

  LanguageWord toLanguageWord(
    DictionaryEntry entry, {
    required String id,
    String? translation,
    String? example,
    String category = 'General',
    DateTime? createdAt,
  }) {
    final editedTranslation = _firstNonEmpty(translation, entry.summary);
    final editedExample = _firstNonEmpty(example, entry.exampleSentence);

    return LanguageWord(
      id: id,
      word: entry.word,
      translation: editedTranslation,
      pronunciation: entry.phonetic ?? '',
      example: editedExample,
      category: category.trim().isEmpty ? 'General' : category.trim(),
      phonetic: entry.phonetic,
      audioUrl: entry.audioUrl,
      partOfSpeech: entry.primaryMeaning?.partOfSpeech,
      source: sourceName,
      createdAt: (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    );
  }

  String _firstNonEmpty(String? candidate, String fallback) {
    final trimmed = candidate?.trim();
    return trimmed != null && trimmed.isNotEmpty ? trimmed : fallback;
  }
}
