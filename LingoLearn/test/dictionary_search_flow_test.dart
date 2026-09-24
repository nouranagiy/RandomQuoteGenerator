import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/core/localization/app_localizations.dart';
import 'package:lingolearn/core/routing/app_router.dart';
import 'package:lingolearn/core/widgets/app_loading.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_entry.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_repository.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_result.dart';
import 'package:lingolearn/features/dictionary/presentation/dictionary_controller.dart';
import 'package:lingolearn/features/dictionary/presentation/dictionary_screen.dart';
import 'package:lingolearn/features/dictionary/presentation/dictionary_word_screen.dart';
import 'package:lingolearn/features/dictionary/presentation/widgets/dictionary_result_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FoundRepo extends DictionaryRepository {
  int lookupCalls = 0;

  @override
  Future<DictionaryLookupResult> lookup(String rawWord) async {
    lookupCalls++;
    return DictionaryLookupResult.found(
      DictionaryEntry(
        word: rawWord.trim(),
        phonetic: '/ˈbjuːtɪfʊl/',
        audioUrl: null,
        phonetics: const [],
        meanings: [
          DictionaryMeaning(
            partOfSpeech: 'adjective',
            definitions: [
              DictionaryDefinition(
                definition: 'Pleasing the senses or mind aesthetically.',
                example: 'A beautiful sunset.',
                synonyms: const ['attractive'],
                antonyms: const ['ugly'],
              ),
            ],
          ),
        ],
        sourceUrls: const [],
      ),
    );
  }

  @override
  Future<List<String>> suggestions(String query) async => const [];
}

Widget _app(DictionaryController controller) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    onGenerateRoute: AppRouter.onGenerateRoute,
    home: DictionaryScreen(controller: controller),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'search -> tap result -> details opens reusing the search data, no refetch',
    (tester) async {
      final repo = _FoundRepo();
      final controller = DictionaryController(repository: repo);

      await tester.pumpWidget(_app(controller));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'beautiful');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.byType(DictionaryResultCard), findsOneWidget);
      expect(find.byType(AppLoading), findsNothing);
      expect(repo.lookupCalls, 1);

      await tester.tap(find.byType(DictionaryResultCard));
      await tester.pumpAndSettle();

      expect(find.byType(DictionaryWordScreen), findsOneWidget);
      expect(find.text('beautiful'), findsWidgets);
      expect(
        find.text('Pleasing the senses or mind aesthetically.'),
        findsOneWidget,
      );
      expect(
        find.byType(AppLoading),
        findsNothing,
        reason: 'details must never show an infinite spinner',
      );

      expect(
        repo.lookupCalls,
        1,
        reason: 'details must reuse the search result',
      );
    },
  );

  testWidgets(
    'search results can be reopened with zero additional lookups (cache)',
    (tester) async {
      final repo = _FoundRepo();
      final controller = DictionaryController(repository: repo);

      await tester.pumpWidget(_app(controller));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'beautiful');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DictionaryResultCard));
      await tester.pumpAndSettle();
      expect(find.byType(DictionaryWordScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(DictionaryResultCard), findsOneWidget);

      await tester.tap(find.byType(DictionaryResultCard));
      await tester.pumpAndSettle();
      expect(find.byType(DictionaryWordScreen), findsOneWidget);

      expect(
        repo.lookupCalls,
        1,
        reason: 'reopening must reuse the session cache',
      );
    },
  );
}
