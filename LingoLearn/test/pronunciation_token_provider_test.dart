import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_issues.dart';
import 'package:lingolearn/features/pronunciation/data/pronunciation_token_provider.dart';

void main() {
  http.Response okResponse(String token) {
    return http.Response(
      jsonEncode({
        'token': token,
        'endpoint':
            'https://my-speech.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1',
        'expiresInSeconds': 600,
      }),
      200,
      headers: {'content-type': 'application/json'},
    );
  }

  test('returns an AzureAccess from a well-formed backend response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      return okResponse('jwt-token');
    });
    final provider = AzureTokenProvider(
      client: client,
      tokenUrl: 'https://example.com/azure/token',
    );

    final access = await provider.access();

    expect(access.token, 'jwt-token');
    expect(
      access.endpoint,
      'https://my-speech.cognitiveservices.azure.com/stt/speech/recognition/conversation/cognitiveservices/v1',
    );
    expect(access.isExpired, isFalse);
  });

  test('caches the token until it is about to expire', () async {
    var now = DateTime(2026, 1, 1, 12);
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return okResponse('jwt-$calls');
    });
    final provider = AzureTokenProvider(
      client: client,
      tokenUrl: 'https://example.com/azure/token',
      clock: () => now,
    );

    final first = await provider.access();
    final second = await provider.access();
    expect(
      identical(first, second),
      isTrue,
      reason: 'the same cached access must be reused',
    );
    expect(calls, 1);

    now = now.add(const Duration(minutes: 11));
    final refreshed = await provider.access();
    expect(refreshed.token, 'jwt-2');
    expect(calls, 2);
  });

  test('a non-200 response throws PronunciationTokenException', () async {
    final client = MockClient((request) async => http.Response('nope', 500));
    final provider = AzureTokenProvider(
      client: client,
      tokenUrl: 'https://example.com/azure/token',
    );

    expect(provider.access(), throwsA(isA<PronunciationTokenException>()));
  });

  test('a malformed body throws PronunciationTokenException', () async {
    final client = MockClient(
      (request) async => http.Response('not json', 200),
    );
    final provider = AzureTokenProvider(
      client: client,
      tokenUrl: 'https://example.com/azure/token',
    );

    expect(provider.access(), throwsA(isA<PronunciationTokenException>()));
  });

  test(
    'a body missing token/endpoint throws PronunciationTokenException',
    () async {
      final client = MockClient(
        (request) async => http.Response('{"expiresInSeconds":600}', 200),
      );
      final provider = AzureTokenProvider(
        client: client,
        tokenUrl: 'https://example.com/azure/token',
      );

      expect(provider.access(), throwsA(isA<PronunciationTokenException>()));
    },
  );

  test('an unreachable endpoint throws PronunciationTokenException', () async {
    final client = MockClient(
      (request) async => throw http.ClientException('connection refused'),
    );
    final provider = AzureTokenProvider(
      client: client,
      tokenUrl: 'https://example.com/azure/token',
    );

    expect(provider.access(), throwsA(isA<PronunciationTokenException>()));
  });

  test(
    'an empty token URL throws PronunciationUnconfiguredException',
    () async {
      final provider = AzureTokenProvider(tokenUrl: '');

      expect(
        provider.access(),
        throwsA(isA<PronunciationUnconfiguredException>()),
      );
    },
  );

  test('clear() drops the cached token', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return okResponse('jwt');
    });
    final provider = AzureTokenProvider(
      client: client,
      tokenUrl: 'https://example.com/azure/token',
    );

    await provider.access();
    await provider.clear();
    await provider.access();
    expect(calls, 2);
  });
}
