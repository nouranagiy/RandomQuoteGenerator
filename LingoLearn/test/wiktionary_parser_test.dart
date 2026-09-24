import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/features/dictionary/data/wiktionary_parser.dart';

const _learnerDefinition = '''
{
  "en": [
    {
      "partOfSpeech": "Noun",
      "language": "English",
      "definitions": [
        {
          "definition": "One who is <a rel=\\"mw:WikiLink\\" href=\\"/wiki/learn\\" title=\\"learn\\">learning</a>; one <span typeof=\\"mw:Entity\\">&nbsp;</span> receiving instruction.",
          "parsedExamples": [
            {"example": "She&rsquo;s still a <b>learner</b>, so she&rsquo;s prone to making mistakes."}
          ],
          "examples": ["She&rsquo;s still a <b>learner</b>, so she&rsquo;s prone to making mistakes."]
        },
        {"definition": "A <a rel=\\"mw:WikiLink\\" href=\\"/wiki/scholar\\" title=\\"scholar\\">scholar</a>."}
      ]
    }
  ]
}
''';

const _learnerMediaList = '''
{
  "revision": "92418364",
  "items": [
    {"title": "File:LL-Q1860_(eng)-I_learned_some_phrases-learner.wav", "type": "audio", "audio_type": "generic"}
  ]
}
''';

void main() {
  const parser = WiktionaryParser();

  group('WiktionaryParser', () {
    test('parses the English senses into meanings', () {
      final entry = parser.parseEntry(_learnerDefinition, word: 'learner');

      expect(entry, isNotNull);
      expect(entry!.word, 'learner');
      expect(entry.meanings, isNotEmpty);
      expect(entry.meanings.first.partOfSpeech, 'noun');
      expect(entry.meanings.first.definitions, isNotEmpty);
      expect(entry.sourceUrls.single, 'https://en.wiktionary.org/wiki/learner');
    });

    test('strips HTML markup and decodes entities from definitions', () {
      final entry = parser.parseEntry(_learnerDefinition, word: 'learner');

      final definition = entry!.meanings.first.definitions.first.definition;
      expect(definition, isNot(contains('<a')));
      expect(definition, isNot(contains('<span')));
      expect(definition, contains('learning'));
      expect(definition, contains('receiving instruction'));
    });

    test('extracts a strip-format example sentence and decodes entities', () {
      final entry = parser.parseEntry(_learnerDefinition, word: 'learner');

      final example = entry!.meanings.first.definitions.first.example;
      expect(example, isNotNull);
      expect(example, isNot(contains('<b>')));
      expect(example, contains('She\u2019s'));
    });

    test('extracts the first audio item into an audioUrl', () {
      final entry = parser.parseEntry(
        _learnerDefinition,
        word: 'learner',
        audioMediaList: _learnerMediaList,
      );

      expect(
        entry!.audioUrl,
        'https://commons.wikimedia.org/wiki/Special:FilePath/'
        'LL-Q1860_(eng)-I_learned_some_phrases-learner.wav',
      );
    });

    test('audioUrl stays null when no media-list body is provided', () {
      final entry = parser.parseEntry(_learnerDefinition, word: 'learner');
      expect(entry!.audioUrl, isNull);
    });

    test('returns null for a missing English section', () {
      expect(
        parser.parseEntry('{"fr": [{"partOfSpeech":"Noun"}]}', word: 'bonjour'),
        isNull,
      );
    });

    test('returns null for non-JSON or non-map bodies', () {
      expect(parser.parseEntry('not json', word: 'learner'), isNull);
      expect(parser.parseEntry('[]', word: 'learner'), isNull);
      expect(parser.parseEntry('[1, 2]', word: 'learner'), isNull);
    });
  });
}
