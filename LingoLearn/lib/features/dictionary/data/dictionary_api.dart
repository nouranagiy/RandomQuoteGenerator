import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../../core/utils/debug_log.dart';
import '../../../core/utils/network_probe.dart';
import 'dictionary_endpoints.dart';
import 'dictionary_entry.dart';
import 'dictionary_parser.dart';
import 'dictionary_result.dart';
import 'wiktionary_parser.dart';

class DictionaryApi {
  DictionaryApi({
    http.Client? client,
    DictionaryParser parser = const DictionaryParser(),
    WiktionaryParser wiktionaryParser = const WiktionaryParser(),
  }) : _client = client ?? _createDefaultClient(),
       _parser = parser,
       _wiktionaryParser = wiktionaryParser;

  final http.Client _client;
  final DictionaryParser _parser;
  final WiktionaryParser _wiktionaryParser;

  static http.Client _createDefaultClient() {
    final inner = HttpClient();
    inner.connectionTimeout = DictionaryEndpoints.connectTimeout;
    return IOClient(inner);
  }

  Future<DictionaryLookupResult> fetchWord(
    String word, {
    void Function(DictionaryEntry winner, DictionaryEntry late)?
    onLateResolution,
  }) async {
    final stopwatch = Stopwatch()..start();
    debugLog(
      'DictionaryApi',
      'lookup started (primary + Wiktionary in parallel): $word',
    );

    final primaryFuture = _fetchPrimary(word);
    final wiktionaryFuture = _fetchWiktionary(word);
    final completer = Completer<DictionaryLookupResult>();
    final settled = <DictionaryLookupResult>[];
    DictionaryEntry? winner;

    bool mergeLate(DictionaryLookupResult result) {
      final current = winner;
      if (current == null ||
          result.status != DictionaryLookupStatus.found ||
          result.entry == null) {
        return false;
      }
      final onLate = onLateResolution;
      if (onLate == null) return false;
      debugLog(
        'DictionaryApi',
        '"$word" late ${result.entry!.word} resolved after winner '
            '-> progressive merge',
      );
      onLate(current, result.entry!);
      return true;
    }

    void settle(DictionaryLookupResult result) {
      if (completer.isCompleted) {
        mergeLate(result);
        return;
      }
      settled.add(result);
      if (result.status == DictionaryLookupStatus.found &&
          result.entry != null) {
        debugLog(
          'DictionaryApi',
          '"$word" resolved -> ${result.status} in '
              '${stopwatch.elapsedMilliseconds} ms',
        );
        winner = result.entry;
        completer.complete(result);
        return;
      }
      if (settled.length == 2) {
        final combined = combineFailures(settled);
        debugLog(
          'DictionaryApi',
          '"$word" settled both sources -> ${combined.status} in '
              '${stopwatch.elapsedMilliseconds} ms',
        );
        completer.complete(combined);
      }
    }

    primaryFuture.then(
      settle,
      onError: (Object e) => settle(const DictionaryLookupResult.apiError()),
    );
    wiktionaryFuture.then(
      settle,
      onError: (Object e) => settle(const DictionaryLookupResult.apiError()),
    );
    return completer.future;
  }

  Future<DictionaryLookupResult> _fetchPrimary(String word) async {
    final uri = Uri.parse(
      '${DictionaryEndpoints.entryEndpoint}${Uri.encodeComponent(word)}',
    );
    final stopwatch = Stopwatch()..start();
    debugLog('DictionaryApi', 'primary started: $uri');
    try {
      final response = await _client
          .get(uri, headers: DictionaryEndpoints.headers)
          .timeout(DictionaryEndpoints.primaryBudget);
      debugLog(
        'DictionaryApi',
        'primary HTTP ${response.statusCode} in ${stopwatch.elapsedMilliseconds} ms, '
            'content-type: ${response.headers['content-type'] ?? 'none'}, '
            'body: ${response.bodyBytes.length} bytes for "$word"',
      );

      if (response.statusCode == 200) {
        debugLog(
          'DictionaryApi',
          'parsing primary response for "$word" started',
        );
        final entry = await _parseEntry(response.body);
        debugLog(
          'DictionaryApi',
          entry == null
              ? 'primary parsing failed for "$word" -> invalidResponse'
              : 'primary parsing completed for "$word" -> ${entry.word}',
        );
        return entry == null
            ? const DictionaryLookupResult.invalidResponse()
            : DictionaryLookupResult.found(entry);
      }
      if (response.statusCode == 404) {
        debugLog('DictionaryApi', '"$word" primary -> notFound');
        return const DictionaryLookupResult.notFound();
      }
      debugLog(
        'DictionaryApi',
        '"$word" primary -> apiError (status ${response.statusCode})',
      );
      return const DictionaryLookupResult.apiError();
    } on TimeoutException catch (e) {
      debugLog(
        'DictionaryApi',
        '"$word" primary timed out after ${stopwatch.elapsedMilliseconds} ms: $e',
      );
      unawaited(diagnoseConnectivity(uri));
      return const DictionaryLookupResult.timeout();
    } on http.ClientException catch (e) {
      debugLog(
        'DictionaryApi',
        '"$word" primary network failure after ${stopwatch.elapsedMilliseconds} ms: ${e.message}',
      );
      return e.message.toLowerCase().contains('timed out')
          ? const DictionaryLookupResult.timeout()
          : const DictionaryLookupResult.networkError();
    } on FormatException catch (e) {
      debugLog(
        'DictionaryApi',
        '"$word" primary body decoding failed -> invalidResponse: $e',
      );
      return const DictionaryLookupResult.invalidResponse();
    } catch (e, s) {
      debugLog('DictionaryApi', '"$word" primary unexpected error ($e)\n$s');
      return const DictionaryLookupResult.apiError();
    }
  }

  Future<DictionaryLookupResult> _fetchWiktionary(String word) async {
    final definitionUri = Uri.parse(
      '${DictionaryEndpoints.wiktionaryDefinitionEndpoint}${Uri.encodeComponent(word)}',
    );
    final mediaUri = Uri.parse(
      '${DictionaryEndpoints.wiktionaryMediaEndpoint}${Uri.encodeComponent(word)}',
    );
    final stopwatch = Stopwatch()..start();
    debugLog('DictionaryApi', 'wiktionary started: $definitionUri');
    try {
      final responses = await Future.wait([
        _client.get(
          definitionUri,
          headers: DictionaryEndpoints.wiktionaryHeaders,
        ),
        _client.get(mediaUri, headers: DictionaryEndpoints.wiktionaryHeaders),
      ]).timeout(DictionaryEndpoints.wiktionaryBudget);

      final definitionResponse = responses[0];
      final mediaResponse = responses[1];
      debugLog(
        'DictionaryApi',
        'wiktionary HTTP ${definitionResponse.statusCode} (def) / '
            '${mediaResponse.statusCode} (media) in ${stopwatch.elapsedMilliseconds} ms total '
            'for "$word" (content-type: ${definitionResponse.headers['content-type'] ?? 'none'})',
      );

      if (definitionResponse.statusCode == 404) {
        debugLog('DictionaryApi', '"$word" wiktionary -> notFound');
        return const DictionaryLookupResult.notFound();
      }
      if (definitionResponse.statusCode != 200) {
        debugLog(
          'DictionaryApi',
          '"$word" wiktionary -> apiError (status ${definitionResponse.statusCode})',
        );
        return const DictionaryLookupResult.apiError();
      }
      if (_isWiktionaryNotFoundEnvelope(definitionResponse.body)) {
        debugLog(
          'DictionaryApi',
          '"$word" wiktionary body reports status 404 -> notFound',
        );
        return const DictionaryLookupResult.notFound();
      }

      final entry = _wiktionaryParser.parseEntry(
        definitionResponse.body,
        word: word,
        audioMediaList: mediaResponse.statusCode == 200
            ? mediaResponse.body
            : null,
      );
      if (entry == null) {
        debugLog(
          'DictionaryApi',
          '"$word" wiktionary parsing failed -> invalidResponse',
        );
        return const DictionaryLookupResult.invalidResponse();
      }
      debugLog(
        'DictionaryApi',
        'wiktionary completed for "$word" -> ${entry.word} '
            '(${entry.meanings.length} meanings, audio: ${entry.audioUrl ?? 'none'})',
      );
      return DictionaryLookupResult.found(entry);
    } on TimeoutException catch (e) {
      debugLog('DictionaryApi', '"$word" wiktionary timed out: $e');
      return const DictionaryLookupResult.timeout();
    } on http.ClientException catch (e) {
      debugLog(
        'DictionaryApi',
        '"$word" wiktionary network failure: ${e.message}',
      );
      return e.message.toLowerCase().contains('timed out')
          ? const DictionaryLookupResult.timeout()
          : const DictionaryLookupResult.networkError();
    } catch (e, s) {
      debugLog('DictionaryApi', '"$word" wiktionary unexpected error: $e\n$s');
      return const DictionaryLookupResult.apiError();
    }
  }

  bool _isWiktionaryNotFoundEnvelope(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['status'] == 404;
      }
    } catch (_) {}
    return false;
  }

  Future<DictionaryEntry?> _parseEntry(String body) {
    if (!kIsWeb && body.length >= DictionaryEndpoints.isolateParseThreshold) {
      return compute(
        _decodeEntryIsolate,
        body,
      ).then<DictionaryEntry?>((e) => e).catchError((Object e) {
        debugLog(
          'DictionaryApi',
          'isolate parse failed, falling back to inline: $e',
        );
        return _parser.parseEntry(body);
      });
    }
    return Future.value(_parser.parseEntry(body));
  }

  @pragma('vm:entry-point')
  static DictionaryEntry? _decodeEntryIsolate(String body) =>
      const DictionaryParser().parseEntry(body);

  Future<List<String>> fetchSuggestions(String query) async {
    final uri = Uri.parse(
      '${DictionaryEndpoints.suggestionEndpoint}?s=${Uri.encodeComponent(query)}&max=8',
    );
    debugLog('DictionaryApi', 'suggestions started: $uri');
    try {
      final response = await _client
          .get(uri, headers: DictionaryEndpoints.headers)
          .timeout(DictionaryEndpoints.requestTimeout);
      if (response.statusCode != 200) {
        debugLog(
          'DictionaryApi',
          'suggestions HTTP ${response.statusCode} -> empty',
        );
        return const [];
      }
      final body = jsonDecode(response.body);
      final words = _parser.parseSuggestions(body);
      debugLog('DictionaryApi', 'suggestions for "$query": $words');
      return words;
    } catch (e) {
      debugLog('DictionaryApi', 'suggestions failed for "$query": $e');
      return const [];
    }
  }
}
