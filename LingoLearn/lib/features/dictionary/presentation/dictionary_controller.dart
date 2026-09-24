import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/debug_log.dart';
import '../data/dictionary_entry.dart';
import '../data/dictionary_repository.dart';
import '../data/dictionary_result.dart';

class DictionaryController extends ChangeNotifier {
  DictionaryController({DictionaryRepository? repository})
    : _repository = repository ?? DictionaryRepository() {
    _loadRecentSearches();
  }

  static const String _recentKey = 'dictionary_recent_searches';
  static const int _maxRecent = 8;
  static const Duration _suggestionDebounce = Duration(milliseconds: 250);

  final DictionaryRepository _repository;
  Timer? _suggestionTimer;
  int _suggestionGeneration = 0;

  String _query = '';
  DictionaryLookupStatus _status = DictionaryLookupStatus.idle;
  DictionaryEntry? _entry;
  List<String> _suggestions = [];
  List<String> _recentSearches = [];
  String? _inFlightWord;
  bool _isDisposed = false;

  String get query => _query;
  DictionaryLookupStatus get status => _status;
  DictionaryEntry? get entry => _entry;
  List<String> get suggestions => _suggestions;
  List<String> get recentSearches => _recentSearches;

  void onQueryChanged(String value) {
    _query = value;
    _suggestionTimer?.cancel();
    final trimmed = value.trim();

    if (trimmed.length < 2) {
      _invalidateSuggestions();
      return;
    }
    _suggestionTimer = Timer(_suggestionDebounce, () {
      _fetchSuggestions(trimmed);
    });
  }

  Future<void> search([String? word]) async {
    final query = (word ?? _query).trim();
    if (query.isEmpty) return;
    final normalized = DictionaryRepository.normalizeWord(query);
    if (_status == DictionaryLookupStatus.loading &&
        normalized == _inFlightWord) {
      debugLog('DictionaryController', 'deduped: "$query" already in flight');
      return;
    }
    _inFlightWord = normalized;

    _suggestionTimer?.cancel();
    _suggestionGeneration++;

    _query = query;
    _status = DictionaryLookupStatus.loading;
    _entry = null;
    _suggestions = [];
    _notify();
    debugLog('DictionaryController', 'search started: "$query"');

    DictionaryLookupResult result;
    try {
      result = await _repository.lookup(query);
    } catch (e, s) {
      debugLog('DictionaryController', 'lookup threw for "$query": $e\n$s');
      result = const DictionaryLookupResult.apiError();
    }
    if (_isDisposed) return;
    _inFlightWord = null;

    if (result.status == DictionaryLookupStatus.found && result.entry != null) {
      _entry = result.entry;
    }

    _status = result.status;
    _notify();
    debugLog('DictionaryController', '"$query" -> ${result.status}');

    if (result.status == DictionaryLookupStatus.found && _entry != null) {
      unawaited(_addRecentSearch(query));
    }
  }

  void clearResult() {
    _status = DictionaryLookupStatus.idle;
    _entry = null;
    _suggestionTimer?.cancel();
    _suggestionGeneration++;
    _suggestions = [];
    _notify();
  }

  Future<void> selectSuggestion(String word) async {
    _query = word;
    await search(word);
  }

  Future<void> removeRecentSearch(String word) async {
    _recentSearches.remove(word);
    _notify();
    await _persistRecentSearches();
  }

  Future<void> _fetchSuggestions(String query) async {
    final generation = ++_suggestionGeneration;
    final result = await _repository.suggestions(query);
    if (_isDisposed) return;
    if (generation != _suggestionGeneration) return;
    if (_query.trim() != query) return;

    _suggestions = result;
    _notify();
  }

  void _invalidateSuggestions() {
    _suggestionGeneration++;
    _suggestions = [];
    _notify();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList(_recentKey) ?? [];
      _notify();
    } catch (e) {
      debugLog('DictionaryController', 'failed to load recent searches: $e');
    }
  }

  Future<void> _addRecentSearch(String word) async {
    try {
      _recentSearches.remove(word);
      _recentSearches.insert(0, word);
      if (_recentSearches.length > _maxRecent) {
        _recentSearches = _recentSearches.sublist(0, _maxRecent);
      }
      _notify();
      await _persistRecentSearches();
    } catch (e) {
      debugLog(
        'DictionaryController',
        'failed to record recent search "$word": $e',
      );
    }
  }

  Future<void> _persistRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentKey, _recentSearches);
    } catch (e) {
      debugLog('DictionaryController', 'failed to persist recent searches: $e');
    }
  }

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _suggestionTimer?.cancel();
    super.dispose();
  }
}
