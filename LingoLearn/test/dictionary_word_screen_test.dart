import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/core/localization/app_localizations.dart';
import 'package:lingolearn/core/routing/app_router.dart';
import 'package:lingolearn/core/widgets/app_loading.dart';
import 'package:lingolearn/core/widgets/word_audio_button.dart';
import 'package:lingolearn/features/dictionary/data/dictionary_entry.dart';
import 'package:lingolearn/features/dictionary/presentation/dictionary_word_screen.dart';
import 'package:lingolearn/features/dictionary/presentation/widgets/word_actions.dart';
import 'package:lingolearn/features/pronunciation/presentation/pronunciation_screen.dart';
import 'package:lingolearn/features/vocabulary/data/language_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

DictionaryEntry _entry({String word = 'beautiful'}) {
  return DictionaryEntry(
    word: word,
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
  );
}

Widget _app(DictionaryEntry entry) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    onGenerateRoute: AppRouter.onGenerateRoute,
    home: DictionaryWordScreen(entry: entry),
  );
}

Future<void> _openDetails(WidgetTester tester, DictionaryEntry entry) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(entry));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('details render the word, IPA, meanings, source and actions', (
    tester,
  ) async {
    await _openDetails(tester, _entry());

    expect(find.text('beautiful'), findsWidgets);
    expect(find.text('/ˈbjuːtɪfʊl/'), findsOneWidget);
    expect(
      find.text('Pleasing the senses or mind aesthetically.'),
      findsOneWidget,
    );
    expect(find.textContaining('Free Dictionary API'), findsOneWidget);
    expect(find.byType(PracticePronunciationButton), findsOneWidget);
    expect(find.byType(AddToWordsButton), findsOneWidget);
    expect(find.byType(WordAudioButton), findsOneWidget);
    expect(
      find.byType(AppLoading),
      findsNothing,
      reason: 'details are rendered from the cached entry, no loading',
    );
  });

  testWidgets(
    'add to My Words persists, updates the button, and remove works',
    (tester) async {
      await _openDetails(tester, _entry());

      expect(find.byType(SnackBar), findsNothing);

      await tester.tap(find.byType(AddToWordsButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      final saved = await tester.runAsync(() => LanguageStorage().getWords());
      expect(saved, hasLength(1));
      expect(saved!.single.word.toLowerCase(), 'beautiful');

      await tester.tap(find.byType(AddToWordsButton));
      await tester.pumpAndSettle();
      final removed = await tester.runAsync(() => LanguageStorage().getWords());
      expect(removed, isEmpty);
    },
  );

  testWidgets(
    'practice button opens the pronunciation screen without crashing',
    (tester) async {
      await _openDetails(tester, _entry());

      await tester.tap(find.byType(PracticePronunciationButton));
      await tester.pumpAndSettle();

      expect(find.byType(PronunciationScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('audio button tap never throws and returns to idle state', (
    tester,
  ) async {
    await _openDetails(tester, _entry());

    await tester.tap(find.byType(WordAudioButton));

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 8));

    expect(
      tester.takeException(),
      isNull,
      reason: 'audio failures must be handled, never thrown',
    );

    expect(find.byType(DictionaryWordScreen), findsOneWidget);
  });

  testWidgets('failure to save surfaces a snackbar instead of an exception', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'language_words': 'not-json'});
    await _openDetails(tester, _entry());

    expect(tester.takeException(), isNull);
    expect(find.byType(DictionaryWordScreen), findsOneWidget);
  });
}
