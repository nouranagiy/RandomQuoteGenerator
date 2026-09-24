import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_api.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_result.dart';

const _primaryEntry = [
  {
    'word': 'beautiful',
    'phonetic': '/ˈbjuːtɪfʊl/',
    'phonetics': [
      {'text': '/ˈbjuːtɪfʊl/', 'audio': 'https://example.com/beautiful.mp3'},
    ],
    'meanings': [
      {
        'partOfSpeech': 'adjective',
        'definitions': [
          {
            'definition': 'Pleasing the senses or mind aesthetically.',
            'example': 'A beautiful sunset.',
            'synonyms': ['attractive'],
            'antonyms': ['ugly'],
          },
        ],
      },
    ],
    'sourceUrls': ['https://api.dictionaryapi.dev/beautiful'],
  },
];

const _wiktionaryDefinition = '''
{"en": [{"partOfSpeech": "Noun", "language": "English", "definitions": [
  {"definition": "One who is learning; one receiving instruction.",
   "parsedExamples": [{"example": "She is a proud learner."}]}
]}]}
''';

const _wiktionaryMediaList =
    '{"items": [{"title": "File:En-us-learner.ogg", "type": "audio"}]}';

void main() {
  group('DictionaryApi fallback', () {
    test(
      'rescues a stalled primary source with a Wiktionary definition',
      () async {
        var dictCalls = 0;
        var wiktCalls = 0;
        final client = MockClient((request) async {
          if (request.url.host == 'api.dictionaryapi.dev') {
            dictCalls++;
            throw TimeoutException('stalled: no response bytes');
          }
          wiktCalls++;
          if (request.url.path.contains('/media-list/')) {
            return http.Response(
              _wiktionaryMediaList,
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response(
            _wiktionaryDefinition,
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        final api = DictionaryApi(client: client);

        final result = await api.fetchWord('learner');

        expect(result.status, DictionaryLookupStatus.found);
        expect(result.entry!.word, 'learner');
        expect(result.entry!.meanings.single.partOfSpeech, 'noun');
        expect(result.entry!.audioUrl, contains('Special:FilePath'));
        expect(dictCalls, 1, reason: 'exactly one primary attempt per lookup');
        expect(
          wiktCalls,
          2,
          reason:
              'Wiktionary definition + media-list are requested in parallel',
        );
      },
    );

    test('uses the primary source directly when it responds fast', () async {
      var dictCalls = 0;
      var wiktCalls = 0;
      final client = MockClient((request) async {
        if (request.url.host == 'api.dictionaryapi.dev') {
          dictCalls++;
          return http.Response(
            jsonEncode(_primaryEntry),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        wiktCalls++;

        await Future<void>.delayed(const Duration(milliseconds: 5));
        return http.Response(_wiktionaryDefinition, 200);
      });
      final api = DictionaryApi(client: client);

      final result = await api.fetchWord('beautiful');

      expect(result.status, DictionaryLookupStatus.found);
      expect(result.entry!.word, 'beautiful');
      expect(dictCalls, 1);
      expect(
        wiktCalls,
        2,
        reason: 'Wiktionary still runs in parallel with the primary',
      );
    });

    test('a Wiktionary hit wins while the primary stalls', () async {
      var dictCalls = 0;
      var wiktCalls = 0;
      final client = MockClient((request) async {
        if (request.url.host == 'api.dictionaryapi.dev') {
          dictCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          throw TimeoutException('stalled: no response bytes');
        }
        wiktCalls++;
        return http.Response(_wiktionaryDefinition, 200);
      });
      final api = DictionaryApi(client: client);

      final result = await api.fetchWord('learner');

      expect(result.status, DictionaryLookupStatus.found);
      expect(result.entry!.word, 'learner');
      expect(dictCalls, 1, reason: 'the stalled primary is tried exactly once');
      expect(
        wiktCalls,
        2,
        reason: 'the parallel Wiktionary path must not be skipped',
      );
    });

    test(
      'a primary 404 with a Wiktionary hit still returns the entry',
      () async {
        var dictCalls = 0;
        var wiktCalls = 0;
        final client = MockClient((request) async {
          if (request.url.host == 'api.dictionaryapi.dev') {
            dictCalls++;
            return http.Response('[]', 404);
          }
          wiktCalls++;
          return http.Response(_wiktionaryDefinition, 200);
        });
        final api = DictionaryApi(client: client);

        final result = await api.fetchWord('beautiful');

        expect(
          result.status,
          DictionaryLookupStatus.found,
          reason: 'found beats a 404 from the other source',
        );
        expect(result.entry!.word, 'beautiful');
        expect(dictCalls, 1);
        expect(
          wiktCalls,
          2,
          reason: 'Wiktionary is also consulted in parallel',
        );
      },
    );

    test(
      'falls back to Wiktionary when the primary returns a server error',
      () async {
        var dictCalls = 0;
        var wiktCalls = 0;
        final client = MockClient((request) async {
          if (request.url.host == 'api.dictionaryapi.dev') {
            dictCalls++;
            return http.Response('oops', 500);
          }
          wiktCalls++;
          return http.Response(_wiktionaryDefinition, 200);
        });
        final api = DictionaryApi(client: client);

        final result = await api.fetchWord('learner');

        expect(result.status, DictionaryLookupStatus.found);
        expect(dictCalls, 1);
        expect(
          wiktCalls,
          2,
          reason: 'definition + media-list rescue the failed primary',
        );
      },
    );

    test(
      'both sources agreeing the word is absent surfaces notFound',
      () async {
        final client = MockClient((request) async {
          if (request.url.host == 'api.dictionaryapi.dev') {
            return http.Response('[]', 404);
          }
          return http.Response('', 404);
        });
        final api = DictionaryApi(client: client);

        final result = await api.fetchWord('zzzznotaword');

        expect(result.status, DictionaryLookupStatus.notFound);
      },
    );

    test(
      'a Wiktionary HTTP-200 status-404 envelope surfaces as notFound',
      () async {
        final client = MockClient((request) async {
          if (request.url.host == 'api.dictionaryapi.dev') {
            throw TimeoutException('stalled');
          }
          return http.Response('{"status":404,"type":"Internal error"}', 200);
        });
        final api = DictionaryApi(client: client);

        final result = await api.fetchWord('zzzznotaword');

        expect(result.status, DictionaryLookupStatus.notFound);
      },
    );

    test(
      'falls through to a terminal timeout when both sources stall',
      () async {
        final client = MockClient((request) async {
          throw TimeoutException('stalled');
        });
        final api = DictionaryApi(client: client);

        final result = await api.fetchWord('learner');

        expect(result.status, DictionaryLookupStatus.timeout);
      },
    );

    test('surfaces a network error when neither source can connect', () async {
      final client = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });
      final api = DictionaryApi(client: client);

      final result = await api.fetchWord('learner');

      expect(result.status, DictionaryLookupStatus.networkError);
    });
  });
}
