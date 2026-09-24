import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_entry.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_repository.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_result.dart';
import 'package:lingolearn/features/dictionary/presentation/dictionary_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

DictionaryEntry _entryFor(String word) {
  return DictionaryEntry(
    word: word,
    phonetic: null,
    audioUrl: null,
    phonetics: const [],
    meanings: [
      DictionaryMeaning(
        partOfSpeech: 'noun',
        definitions: [
          DictionaryDefinition(
            definition: 'definition of $word',
            example: null,
            synonyms: const [],
            antonyms: const [],
          ),
        ],
      ),
    ],
    sourceUrls: const [],
  );
}

class _FakeRepository extends DictionaryRepository {
  _FakeRepository({this.lookupError, this.suggestionsFuture});

  Object? lookupError;
  Future<List<String>>? suggestionsFuture;
  int lookupCalls = 0;

  @override
  Future<DictionaryLookupResult> lookup(String rawWord) async {
    lookupCalls++;
    final error = lookupError;
    if (error != null) throw error;
    return DictionaryLookupResult.found(
      _entryFor(rawWord.trim().toLowerCase()),
    );
  }

  @override
  Future<List<String>> suggestions(String query) async {
    final future = suggestionsFuture;
    if (future != null) return future;
    return const [];
  }
}

class _GatedRepository extends DictionaryRepository {
  final gate = Completer<void>();
  int lookupCalls = 0;

  @override
  Future<DictionaryLookupResult> lookup(String rawWord) async {
    lookupCalls++;
    await gate.future;
    return DictionaryLookupResult.found(
      _entryFor(rawWord.trim().toLowerCase()),
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DictionaryController', () {
    test(
      'successful search reaches found, sets entry and records recent',
      () async {
        final repo = _FakeRepository();
        final controller = DictionaryController(repository: repo);

        await controller.search('beautiful');

        expect(controller.status, DictionaryLookupStatus.found);
        expect(controller.entry?.word, 'beautiful');
        expect(controller.recentSearches, ['beautiful']);
      },
    );

    test(
      'repo exceptions map to apiError and never leave the controller loading',
      () async {
        final repo = _FakeRepository(lookupError: StateError('boom'));
        final controller = DictionaryController(repository: repo);

        await controller.search('beautiful');

        expect(controller.status, DictionaryLookupStatus.apiError);
        expect(controller.entry, isNull);
      },
    );

    test('a late suggestion response cannot hide a found search result', () {
      final pendingSuggestions = Completer<List<String>>();
      final repo = _FakeRepository(
        suggestionsFuture: pendingSuggestions.future,
      );
      final controller = DictionaryController(repository: repo);

      fakeAsync((async) {
        controller.onQueryChanged('beautiful');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(controller.suggestions, isEmpty);

        var searchDone = false;
        controller.search('beautiful').whenComplete(() => searchDone = true);
        async.flushMicrotasks();
        expect(searchDone, isTrue);
        expect(controller.status, DictionaryLookupStatus.found);

        pendingSuggestions.complete(['beautiful']);
        async.flushMicrotasks();

        expect(controller.status, DictionaryLookupStatus.found);
        expect(controller.suggestions, isEmpty);
      });
    });

    test(
      'a second search for the same running word does not re-hit the repository',
      () async {
        final repo = _GatedRepository();
        final controller = DictionaryController(repository: repo);

        final first = controller.search('leader');
        final second = controller.search(' LEADER ');
        expect(
          repo.lookupCalls,
          1,
          reason: 'overlapping searches for the same word must be deduped',
        );

        repo.gate.complete();
        await first;
        await second;

        expect(controller.status, DictionaryLookupStatus.found);
        expect(repo.lookupCalls, 1);
      },
    );

    test(
      'a new word search is allowed while another word is in flight',
      () async {
        final repo = _GatedRepository();
        final controller = DictionaryController(repository: repo);

        final first = controller.search('leader');
        final second = controller.search('beautiful');
        expect(
          repo.lookupCalls,
          2,
          reason: 'different words are never deduped together',
        );

        repo.gate.complete();
        await first;
        await second;
      },
    );

    test('cancelled search timer no longer fires after clearResult', () {
      final repo = _FakeRepository();
      final controller = DictionaryController(repository: repo);

      fakeAsync((async) {
        controller.onQueryChanged('beautiful');
        controller.clearResult();
        async.elapse(const Duration(milliseconds: 300));

        expect(controller.status, DictionaryLookupStatus.idle);
        expect(controller.suggestions, isEmpty);
      });
    });

    test('short queries never schedule suggestion requests', () {
      final repo = _FakeRepository();
      final controller = DictionaryController(repository: repo);

      fakeAsync((async) {
        controller.onQueryChanged('a');
        async.elapse(const Duration(seconds: 2));

        expect(controller.suggestions, isEmpty);
        expect(repo.lookupCalls, 0);
      });
    });
  });
}
