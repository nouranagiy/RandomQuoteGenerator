import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_api.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_repository.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_result.dart';

const _entryResponse = [
  {
    'word': 'beautiful',
    'phonetic': '/ˈbjuːtɪfʊl/',
    'phonetics': [
      {'text': '/ˈbjuːtɪfʊl/', 'audio': ''},
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
    'sourceUrls': [],
  },
];

void main() {
  group('DictionaryRepository', () {
    test(
      'returns found result and caches: second lookup skips the API',
      () async {
        var primaryCalls = 0;
        final client = MockClient((request) async {
          if (request.url.host != 'api.dictionaryapi.dev') {
            return http.Response('[]', 404);
          }
          primaryCalls++;
          return http.Response(
            jsonEncode(_entryResponse),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        final repository = DictionaryRepository(
          api: DictionaryApi(client: client),
        );

        final first = await repository.lookup('beautiful');
        expect(first.status, DictionaryLookupStatus.found);

        final second = await repository.lookup(' Beautiful ');
        expect(second.status, DictionaryLookupStatus.found);
        expect(second.entry!.word, 'beautiful');
        expect(primaryCalls, 1, reason: 'second lookup must hit the cache');
      },
    );

    test(
      'normalizes casing and surrounding whitespace for cache hits',
      () async {
        final client = MockClient((request) async {
          expect(request.url.path.endsWith('/beautiful'), isTrue);
          return http.Response('[]', 404);
        });
        final repository = DictionaryRepository(
          api: DictionaryApi(client: client),
        );

        final result = await repository.lookup('  BEAUTIFUL  ');
        expect(result.status, DictionaryLookupStatus.notFound);
      },
    );

    test(
      'caches misses so the API is not re-hit for the same invalid word',
      () async {
        var primaryCalls = 0;
        final client = MockClient((request) async {
          if (request.url.host != 'api.dictionaryapi.dev') {
            return http.Response('[]', 404);
          }
          primaryCalls++;
          return http.Response('[]', 404);
        });
        final repository = DictionaryRepository(
          api: DictionaryApi(client: client),
        );

        await repository.lookup('zzzznotaword');
        await repository.lookup('zzzznotaword');
        expect(primaryCalls, 1);
      },
    );

    test(
      'deduplicates overlapping requests for the same normalized word',
      () async {
        var primaryCalls = 0;
        final gate = Completer<void>();
        final client = MockClient((request) async {
          if (request.url.host != 'api.dictionaryapi.dev') {
            return http.Response('[]', 404);
          }
          primaryCalls++;
          await gate.future;
          return http.Response(
            jsonEncode(_entryResponse),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        final repository = DictionaryRepository(
          api: DictionaryApi(client: client),
        );

        final first = repository.lookup('beautiful');

        await Future<void>.delayed(Duration.zero);
        final second = repository.lookup(' Beautiful ');
        expect(
          primaryCalls,
          1,
          reason: 'second concurrent lookup must rejoin the in-flight request',
        );

        gate.complete();
        final firstResult = await first;
        final secondResult = await second;

        expect(firstResult.status, DictionaryLookupStatus.found);
        expect(secondResult.status, DictionaryLookupStatus.found);
        expect(
          primaryCalls,
          1,
          reason: 'overlapping lookups must share ONE primary request',
        );
      },
    );

    test(
      'a slow secondary source resolves late and enriches the cached entry',
      () async {
        final wiktionaryGate = Completer<void>();
        final client = MockClient((request) async {
          final path = request.url.path;
          if (path.startsWith('/api/rest_v1/page/definition/')) {
            await wiktionaryGate.future;
            return http.Response(
              jsonEncode({
                'en': [
                  {
                    'partOfSpeech': 'adjective',
                    'definitions': [
                      {'definition': 'Pleasing the senses aesthetically.'},
                    ],
                  },
                ],
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          if (path.startsWith('/api/rest_v1/page/media-list/')) {
            await wiktionaryGate.future;
            return http.Response(
              jsonEncode({
                'items': [
                  {'type': 'audio', 'title': 'File:En-us-beautiful.ogg'},
                ],
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode(_entryResponse),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });
        final repository = DictionaryRepository(
          api: DictionaryApi(client: client),
        );

        final first = await repository.lookup('beautiful');
        expect(first.status, DictionaryLookupStatus.found);
        expect(
          first.entry!.phonetic,
          '/ˈbjuːtɪfʊl/',
          reason:
              'the fast primary must be shown without waiting for the slow source',
        );

        wiktionaryGate.complete();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final second = await repository.lookup('beautiful');
        expect(second.status, DictionaryLookupStatus.found);
        expect(
          second.entry!.audioUrl,
          isNotNull,
          reason: 'the late source must backfill audio into the cached entry',
        );
        expect(second.entry!.phonetic, '/ˈbjuːtɪfʊl/');
      },
    );

    test('maps HTTP 404 to notFound', () async {
      final client = MockClient((request) async => http.Response('[]', 404));
      final repository = DictionaryRepository(
        api: DictionaryApi(client: client),
      );

      final result = await repository.lookup('definitelynotaword');
      expect(result.status, DictionaryLookupStatus.notFound);
      expect(result.entry, isNull);
    });

    test('maps transport failures to networkError', () async {
      final client = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });
      final repository = DictionaryRepository(
        api: DictionaryApi(client: client),
      );

      final result = await repository.lookup('beautiful');
      expect(result.status, DictionaryLookupStatus.networkError);
    });

    test('maps request timeouts to a distinct timeout result', () async {
      final client = DictionaryApi(
        client: _ThrowingClient(TimeoutException('late')),
      );
      final repository = DictionaryRepository(api: client);

      final result = await repository.lookup('beautiful');
      expect(result.status, DictionaryLookupStatus.timeout);
    });

    test('maps an unparsable 200 response to invalidResponse', () async {
      final client = MockClient((request) async {
        return http.Response(
          '[]',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final repository = DictionaryRepository(
        api: DictionaryApi(client: client),
      );

      final result = await repository.lookup('beautiful');
      expect(result.status, DictionaryLookupStatus.invalidResponse);
    });

    test('maps server errors to apiError', () async {
      final client = MockClient((request) async => http.Response('oops', 500));
      final repository = DictionaryRepository(
        api: DictionaryApi(client: client),
      );

      final result = await repository.lookup('beautiful');
      expect(result.status, DictionaryLookupStatus.apiError);
    });

    test('empty input is an apiError without hitting the network', () async {
      var apiCalls = 0;
      final client = MockClient((request) async {
        apiCalls++;
        return http.Response('[]', 404);
      });
      final repository = DictionaryRepository(
        api: DictionaryApi(client: client),
      );

      final result = await repository.lookup('   ');
      expect(result.status, DictionaryLookupStatus.apiError);
      expect(apiCalls, 0);
    });
  });

  group('DictionaryApi suggestions', () {
    test('parses suggestion words', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'api.datamuse.com');
        expect(request.url.queryParameters['s'], 'entre');
        return http.Response(
          '[{"word":"entrepreneur"},{"word":"entry"}]',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      final api = DictionaryApi(client: client);

      final suggestions = await api.fetchSuggestions('entre');
      expect(suggestions, ['entrepreneur', 'entry']);
    });

    test('returns empty list on failure', () async {
      final client = MockClient(
        (request) async => throw http.ClientException('boom'),
      );
      final api = DictionaryApi(client: client);

      expect(await api.fetchSuggestions('entre'), isEmpty);
    });
  });
}

class _ThrowingClient extends http.BaseClient {
  _ThrowingClient(this.error);

  final Object error;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw error;
  }
}
