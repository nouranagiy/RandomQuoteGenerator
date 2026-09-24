import 'dart:collection';

import '../../../core/utils/debug_log.dart';
import 'dictionary_api.dart';
import 'dictionary_entry.dart';
import 'dictionary_result.dart';

class DictionaryRepository {
  DictionaryRepository({DictionaryApi? api}) : _api = api ?? DictionaryApi();

  final DictionaryApi _api;

  final LinkedHashMap<String, DictionaryEntry> _cache = LinkedHashMap();
  final Set<String> _missCache = {};

  final Map<String, Future<DictionaryLookupResult>> _inFlight = {};

  static const int _cacheLimit = 50;
  static const int _missLimit = 100;

  Future<DictionaryLookupResult> lookup(String rawWord) async {
    final word = normalizeWord(rawWord);
    if (word.isEmpty) return const DictionaryLookupResult.apiError();

    final cached = _cache[word];
    if (cached != null) {
      debugLog('DictionaryRepo', 'cache hit for "$word"');
      return DictionaryLookupResult.found(cached);
    }
    if (_missCache.contains(word)) {
      debugLog('DictionaryRepo', 'negative cache hit for "$word"');
      return const DictionaryLookupResult.notFound();
    }

    final running = _inFlight[word];
    if (running != null) {
      debugLog('DictionaryRepo', 'deduped: "$word" already in flight');
      return running;
    }

    final future = _fetch(word);
    _inFlight[word] = future;
    try {
      return await future;
    } finally {
      _inFlight.remove(word);
    }
  }

  Future<DictionaryLookupResult> _fetch(String word) async {
    debugLog('DictionaryRepo', 'cache miss, fetching "$word"');
    final result = await _api.fetchWord(
      word,
      onLateResolution: (winner, late) => _enrichCache(word, winner, late),
    );
    debugLog('DictionaryRepo', 'fetched "$word" -> ${result.status}');
    if (result.status == DictionaryLookupStatus.found && result.entry != null) {
      _cacheWord(word, result.entry!);
    } else if (result.status == DictionaryLookupStatus.notFound) {
      _cacheMiss(word);
    }
    return result;
  }

  void _enrichCache(String word, DictionaryEntry winner, DictionaryEntry late) {
    final cached = _cache[word];
    if (cached == null) return;
    final merged = cached.mergedWith(late);
    if (identical(merged, cached)) return;
    debugLog(
      'DictionaryRepo',
      '"$word" cache enriched (phonetic/audio/meanings filled in)',
    );
    _cache[word] = merged;
  }

  Future<List<String>> suggestions(String query) =>
      _api.fetchSuggestions(query);

  static String normalizeWord(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  void _cacheWord(String word, DictionaryEntry entry) {
    if (_cache.length >= _cacheLimit) {
      _cache.remove(_cache.keys.first);
    }
    _cache[word] = entry;
  }

  void _cacheMiss(String word) {
    if (_missCache.length >= _missLimit) {
      _missCache.remove(_missCache.first);
    }
    _missCache.add(word);
  }
}
