import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_entry.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_repository.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_result.dart';
import 'package:lingolearn/features/vocabulary/presentation/add_word_controller.dart';

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
  group('AddWordController', () {
    test('dedupes overlapping lookups for the same normalized word', () async {
      final repo = _GatedRepository();
      final controller = AddWordController(repository: repo);

      final first = controller.lookup('leader');
      final second = controller.lookup(' LEADER ');
      expect(
        repo.lookupCalls,
        1,
        reason: 're-triggering the same word must not spawn another request',
      );

      repo.gate.complete();
      await first;
      await second;

      expect(controller.status, DictionaryLookupStatus.found);
      expect(controller.entry?.word, 'leader');
      expect(repo.lookupCalls, 1);
    });

    test(
      'times out to a terminal error state after the request finishes',
      () async {
        final repo = _GatedRepository();
        final controller = AddWordController(repository: repo);

        final pending = controller.lookup('leader');
        expect(controller.status, DictionaryLookupStatus.loading);

        repo.gate.complete();
        await pending;

        expect(controller.status, DictionaryLookupStatus.found);
      },
    );

    test('reset clears the in-flight word and returns to idle', () async {
      final repo = _GatedRepository();
      final controller = AddWordController(repository: repo);

      final pending = controller.lookup('leader');
      controller.reset();
      expect(controller.status, DictionaryLookupStatus.idle);

      repo.gate.complete();
      await pending;
      expect(controller.status, DictionaryLookupStatus.idle);
      expect(controller.entry, isNull);
    });
  });
}
