import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_parser.dart';

const _entrepreneurPayload = [
  {
    'word': 'entrepreneur',
    'phonetic': '/ˌɑːntrəprəˈnɜːr/',
    'phonetics': [
      {
        'text': '/ˌɑːntrəprəˈnɜːr/',
        'audio':
            'https://api.dictionaryapi.dev/media/pronunciations/en/entrepreneur-uk.mp3',
      },
      {'text': '/ˌɑːntrəprəˈnɝ/', 'audio': ''},
    ],
    'meanings': [
      {
        'partOfSpeech': 'noun',
        'definitions': [
          {
            'definition': 'A person who organizes and operates a business.',
            'example': 'She is a successful entrepreneur.',
            'synonyms': ['businessperson', 'tycoon'],
            'antonyms': [],
          },
        ],
      },
      {
        'partOfSpeech': 'adjective',
        'definitions': [
          {
            'definition': 'Characterized by initiative and risk-taking.',
            'example': null,
            'synonyms': ['enterprising'],
            'antonyms': ['unenterprising'],
          },
        ],
      },
    ],
    'sourceUrls': ['https://en.wiktionary.org/wiki/entrepreneur'],
  },
];

void main() {
  const parser = DictionaryParser();

  group('parseEntry', () {
    test('parses a valid dictionary response', () {
      final entry = parser.parseEntry(_entrepreneurPayload);
      expect(entry, isNotNull);
      expect(entry!.word, 'entrepreneur');
      expect(entry.phonetic, '/ˌɑːntrəprəˈnɜːr/');
      expect(entry.audioUrl, contains('entrepreneur-uk.mp3'));
      expect(entry.meanings, hasLength(2));
      expect(entry.primaryMeaning!.partOfSpeech, 'noun');
      expect(
        entry.primaryDefinition!.definition,
        'A person who organizes and operates a business.',
      );
      expect(entry.primaryDefinition!.synonyms, contains('tycoon'));
      expect(entry.summary, contains('A person who organizes'));
      expect(entry.firstExample, 'She is a successful entrepreneur.');
      expect(entry.exampleSentence, 'She is a successful entrepreneur.');
      expect(entry.sourceUrls.single, contains('wiktionary'));
    });

    test('parses a JSON string body the same as decoded data', () {
      final body = const JsonEncoder().convert(_entrepreneurPayload);
      final entry = parser.parseEntry(body);
      expect(entry, isNotNull);
      expect(entry!.word, 'entrepreneur');
    });

    test('skips phonetics without text or audio', () {
      final payload = [
        {
          'word': 'hi',
          'phonetic': '',
          'phonetics': [
            {'text': '', 'audio': ''},
            {'text': '/haɪ/', 'audio': ''},
          ],
          'meanings': [
            {
              'partOfSpeech': 'interjection',
              'definitions': [
                {
                  'definition': 'Used as a greeting.',
                  'example': 'Hi there!',
                  'synonyms': [],
                  'antonyms': [],
                },
              ],
            },
          ],
          'sourceUrls': [],
        },
      ];
      final entry = parser.parseEntry(payload);
      expect(entry, isNotNull);
      expect(entry!.phonetic, '/haɪ/');
      expect(entry.audioUrl, isNull);
    });

    test('returns null for empty responses', () {
      expect(parser.parseEntry([]), isNull);
      expect(parser.parseEntry('{}'), isNull);
      expect(parser.parseEntry(null), isNull);
      expect(parser.parseEntry('not json at all'), isNull);
    });

    test('returns null when no definitions exist', () {
      final payload = [
        {
          'word': 'ghostword',
          'meanings': [
            {
              'partOfSpeech': 'noun',
              'definitions': [
                {
                  'definition': '   ',
                  'example': '',
                  'synonyms': [],
                  'antonyms': [],
                },
              ],
            },
          ],
        },
      ];
      expect(parser.parseEntry(payload), isNull);
    });
  });

  group('parseSuggestions', () {
    test('returns words from Datamuse-style payloads', () {
      final suggestions = parser.parseSuggestions([
        {'word': 'beautiful', 'score': 100},
        {'word': 'beautify', 'score': 50},
      ]);
      expect(suggestions, ['beautiful', 'beautify']);
    });

    test('returns empty list for malformed payloads', () {
      expect(parser.parseSuggestions('oops'), isEmpty);
      expect(parser.parseSuggestions({'word': 'x'}), isEmpty);
      expect(parser.parseSuggestions(null), isEmpty);
    });
  });
}
