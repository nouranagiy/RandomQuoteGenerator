import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_entry.dart';
import 'package:lingolearn/features/dictionary/data/language_word_mapper.dart';

const _entry = DictionaryEntry(
  word: 'entrepreneur',
  phonetic: '/ˌɑːntrəprəˈnɜːr/',
  audioUrl: 'https://example.com/entrepreneur.mp3',
  phonetics: [],
  meanings: [
    DictionaryMeaning(
      partOfSpeech: 'noun',
      definitions: [
        DictionaryDefinition(
          definition: 'A person who organizes and operates a business.',
          example: 'She is an entrepreneur.',
          synonyms: ['businessperson'],
          antonyms: [],
        ),
      ],
    ),
  ],
  sourceUrls: [],
);

void main() {
  const mapper = LanguageWordMapper();

  test('maps a dictionary entry onto a LanguageWord without manual input', () {
    final t = DateTime(2025, 1, 1, 12);
    final word = mapper.toLanguageWord(_entry, id: 'abc', createdAt: t);

    expect(word.id, 'abc');
    expect(word.word, 'entrepreneur');
    expect(word.translation, contains('A person who organizes'));
    expect(word.pronunciation, '/ˌɑːntrəprəˈnɜːr/');
    expect(word.example, 'She is an entrepreneur.');
    expect(word.category, 'General');
    expect(word.phonetic, '/ˌɑːntrəprəˈnɜːr/');
    expect(word.audioUrl, 'https://example.com/entrepreneur.mp3');
    expect(word.partOfSpeech, 'noun');
    expect(word.source, LanguageWordMapper.sourceName);
    expect(word.createdAt, t.millisecondsSinceEpoch);
  });

  test('allows editing non-pronunciation fields', () {
    final word = mapper.toLanguageWord(
      _entry,
      id: 'abc',
      translation: 'رائد أعمال',
      example: 'مثال معدل',
      category: 'Business',
    );

    expect(word.translation, 'رائد أعمال');
    expect(word.example, 'مثال معدل');
    expect(word.category, 'Business');
    expect(
      word.pronunciation,
      '/ˌɑːntrəprəˈnɜːr/',
      reason: 'pronunciation is auto-fetched and not editable',
    );
  });

  test('blank editable fields fall back to entry data', () {
    final word = mapper.toLanguageWord(
      _entry,
      id: 'abc',
      translation: '   ',
      example: '',
      category: '',
    );

    expect(word.translation, contains('A person who organizes'));
    expect(word.example, 'She is an entrepreneur.');
    expect(word.category, 'General');
  });
}
