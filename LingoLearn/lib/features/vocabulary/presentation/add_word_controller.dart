import 'package:flutter/foundation.dart';

import '../../../core/utils/debug_log.dart';
import '../../dictionary/data/dictionary_entry.dart';
import '../../dictionary/data/dictionary_repository.dart';
import '../../dictionary/data/dictionary_result.dart';
import '../../dictionary/data/language_word_mapper.dart';
import '../data/language_word.dart';

class AddWordController extends ChangeNotifier {
  AddWordController({
    DictionaryRepository? repository,
    LanguageWordMapper mapper = const LanguageWordMapper(),
  }) : _repository = repository ?? DictionaryRepository(),
       _mapper = mapper;

  final DictionaryRepository _repository;
  final LanguageWordMapper _mapper;

  DictionaryLookupStatus _status = DictionaryLookupStatus.idle;
  DictionaryEntry? _entry;
  String? _inFlightWord;
  int _lookupGeneration = 0;
  bool _isDisposed = false;

  DictionaryLookupStatus get status => _status;
  DictionaryEntry? get entry => _entry;

  Future<void> lookup(String word) async {
    final query = word.trim();
    if (query.isEmpty) return;
    final normalized = DictionaryRepository.normalizeWord(query);
    if (_status == DictionaryLookupStatus.loading &&
        normalized == _inFlightWord) {
      debugLog('AddWordController', 'deduped: "$query" already in flight');
      return;
    }
    final generation = ++_lookupGeneration;
    _inFlightWord = normalized;
    _status = DictionaryLookupStatus.loading;
    _entry = null;
    _notify();

    final result = await _repository.lookup(query);
    if (_isDisposed || generation != _lookupGeneration) return;
    _inFlightWord = null;

    if (result.status == DictionaryLookupStatus.found && result.entry != null) {
      _entry = result.entry;
    }
    _status = result.status;
    _notify();
  }

  void reset() {
    _lookupGeneration++;
    _inFlightWord = null;
    _status = DictionaryLookupStatus.idle;
    _entry = null;
    _notify();
  }

  LanguageWord toLanguageWord({
    required String id,
    String? translation,
    String? example,
    String category = 'General',
    DateTime? createdAt,
  }) {
    final entry = _entry;
    if (entry == null) {
      throw StateError('No dictionary entry to map. Lookup a word first.');
    }
    return _mapper.toLanguageWord(
      entry,
      id: id,
      translation: translation,
      example: example,
      category: category,
      createdAt: createdAt,
    );
  }

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
