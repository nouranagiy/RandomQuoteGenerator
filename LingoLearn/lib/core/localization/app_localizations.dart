import 'package:flutter/material.dart';

import 'ar_strings.dart';
import 'en_strings.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  bool get isArabic => locale.languageCode == 'ar';

  String get appName => _t('appName');
  String get tagline => _t('tagline');

  String get yourProgress => _t('yourProgress');
  String get dailyLesson => _t('dailyLesson');
  String get noWordsAvailable => _t('noWordsAvailable');
  String get continueNewWord => _t('continueNewWord');
  String get quickPractice => _t('quickPractice');
  String get vocabulary => _t('vocabulary');
  String get quiz => _t('quiz');
  String get favorites => _t('favorites');
  String get progress => _t('progress');
  String get testYourself => _t('testYourself');

  String get searchWords => _t('searchWords');
  String get all => _t('all');
  String get addWord => _t('addWord');
  String get editWord => _t('editWord');
  String get deleteWord => _t('deleteWord');
  String get wordDetails => _t('wordDetails');
  String get word => _t('word');
  String get translation => _t('translation');
  String get pronunciation => _t('pronunciation');
  String get example => _t('example');
  String get category => _t('category');
  String get saveChanges => _t('saveChanges');
  String get cancel => _t('cancel');
  String get noWordsFound => _t('noWordsFound');
  String get tryAnotherSearch => _t('tryAnotherSearch');
  String get markAsLearned => _t('markAsLearned');
  String get learned => _t('learned');
  String get greatJobLearned => _t('greatJobLearned');
  String get edit => _t('edit');
  String get delete => _t('delete');

  String get pleaseEnterWord => _t('pleaseEnterWord');
  String get pleaseEnterTranslation => _t('pleaseEnterTranslation');
  String get pleaseEnterPronunciation => _t('pleaseEnterPronunciation');
  String get pleaseEnterExample => _t('pleaseEnterExample');
  String get pleaseEnterCategory => _t('pleaseEnterCategory');
  String get hintWord => _t('hintWord');
  String get hintTranslation => _t('hintTranslation');
  String get hintPronunciation => _t('hintPronunciation');
  String get hintExample => _t('hintExample');
  String get hintCategory => _t('hintCategory');

  String deleteWordConfirm(String wordName) =>
      isArabic ? 'هل تريد حذف "$wordName"؟' : 'Delete "$wordName"?';
  String get deleteWordMessage => _t('deleteWordMessage');

  String get practiceQuiz => _t('practiceQuiz');
  String get chooseCategory => _t('chooseCategory');
  String get whatToPractice => _t('whatToPractice');
  String get allCategories => _t('allCategories');
  String get chooseQuizLength => _t('chooseQuizLength');
  String get howManyQuestions => _t('howManyQuestions');
  String questionsCount(int count) =>
      isArabic ? '$count أسئلة' : '$count Questions';
  String get allQuestions => _t('allQuestions');
  String questionNumber(int n) => isArabic ? 'السؤال $n' : 'Question $n';
  String correctCount(int n) => isArabic ? '$n صحيح' : '$n correct';
  String get whatIsTheMeaning => _t('whatIsTheMeaning');
  String get chooseCorrectAnswer => _t('chooseCorrectAnswer');
  String get nextQuestion => _t('nextQuestion');
  String get showResult => _t('showResult');
  String get quizCompleted => _t('quizCompleted');
  String get tryAgain => _t('tryAgain');
  String get done => _t('done');
  String get noWordsForQuiz => _t('noWordsForQuiz');
  String get addWordsBeforeQuiz => _t('addWordsBeforeQuiz');
  String get excellent => _t('excellent');
  String get greatJob => _t('greatJob');
  String get goodEffort => _t('goodEffort');
  String get keepPracticing => _t('keepPracticing');

  String get noFavoritesYet => _t('noFavoritesYet');
  String get saveFavoriteWords => _t('saveFavoriteWords');
  String get browseVocabulary => _t('browseVocabulary');

  String get myProgress => _t('myProgress');
  String get learningProgress => _t('learningProgress');
  String get totalWords => _t('totalWords');
  String get quizzes => _t('quizzes');
  String get quizPerformance => _t('quizPerformance');
  String get bestScore => _t('bestScore');
  String get lastScore => _t('lastScore');
  String get categories => _t('categories');
  String get takeFirstQuiz => _t('takeFirstQuiz');
  String quizzesCompleted(int count) => isArabic
      ? 'أكملت $count اختبار${count == 1 ? '' : 'ات'}.'
      : 'You completed $count quiz${count == 1 ? '' : 'zes'}.';
  String wordsOfTotal(int learned, int total) => isArabic
      ? '$learned من $total كلمة تم تعلمها'
      : '$learned of $total words learned';
  String wordsCount(int n) => isArabic ? '$n كلمة' : '$n words';
  String savedCount(int n) => isArabic ? '$n محفوظ' : '$n saved';
  String learnedCount(int n) => isArabic ? '$n تم تعلمها' : '$n learned';

  String get settings => _t('settings');
  String get appearance => _t('appearance');
  String get theme => _t('theme');
  String get lightMode => _t('lightMode');
  String get darkMode => _t('darkMode');
  String get systemDefault => _t('systemDefault');
  String get language => _t('language');
  String get english => _t('english');
  String get arabic => _t('arabic');
  String get data => _t('data');
  String get resetAppData => _t('resetAppData');
  String get resetAppDataDesc => _t('resetAppDataDesc');
  String get resetAppDataMessage => _t('resetAppDataMessage');
  String get reset => _t('reset');
  String get dataResetSuccess => _t('dataResetSuccess');

  String get buildVocabulary => _t('buildVocabulary');
  String get buildVocabularyDesc => _t('buildVocabularyDesc');
  String get practiceWithQuizzes => _t('practiceWithQuizzes');
  String get practiceWithQuizzesDesc => _t('practiceWithQuizzesDesc');
  String get trackYourProgress => _t('trackYourProgress');
  String get trackYourProgressDesc => _t('trackYourProgressDesc');
  String get getStarted => _t('getStarted');
  String get next => _t('next');
  String get skip => _t('skip');

  String get wordMarkedLearned => _t('wordMarkedLearned');
  String get wordMarkedNotLearned => _t('wordMarkedNotLearned');

  String welcomeUser(String name) =>
      isArabic ? 'مرحباً، $name 👋' : 'Welcome, $name 👋';
  String get welcomeFallback => isArabic ? 'مرحباً 👋' : 'Welcome 👋';
  String get readyToContinue => _t('readyToContinue');

  String get listen => _t('listen');
  String get pronunciationUnavailable => _t('pronunciationUnavailable');

  String get pronunciationPractice => _t('pronunciationPractice');
  String get practicePronunciation => _t('practicePronunciation');
  String get pronunciationTip => _t('pronunciationTip');
  String get tapToRecord => _t('tapToRecord');
  String get tapToStop => _t('tapToStop');
  String get listening => _t('listening');
  String get analyzingPronunciation => _t('analyzingPronunciation');
  String get excellentPronunciation => _t('excellentPronunciation');
  String get greatPronunciation => _t('greatPronunciation');
  String get goodPronunciation => _t('goodPronunciation');
  String get needsPracticePronunciation => _t('needsPracticePronunciation');
  String get weHeard => _t('weHeard');
  String get nothingRecognized => _t('nothingRecognized');
  String get focusSounds => _t('focusSounds');
  String get nextWord => _t('nextWord');
  String get score => _t('score');
  String get speechNotAvailable => _t('speechNotAvailable');
  String get microphonePermissionDenied => _t('microphonePermissionDenied');
  String get noSpeechDetected => _t('noSpeechDetected');
  String get speechNetworkError => _t('speechNetworkError');
  String get speechRecognitionFailed => _t('speechRecognitionFailed');
  String get speechInitializationTimedOut => _t('speechInitializationTimedOut');
  String get recordingTooShort => _t('recordingTooShort');
  String get recordingFailed => _t('recordingFailed');
  String get recordingClipped => _t('recordingClipped');
  String get preparingRecording => _t('preparingRecording');
  String get recording => _t('recording');
  String get howToProduceSound => _t('howToProduceSound');
  String get articulationTip => _t('articulationTip');
  String get focusOnRetry => _t('focusOnRetry');
  String attemptLabel(int n) => isArabic ? 'المحاولة $n' : 'Attempt $n';

  String get doesntSoundRight => _t('doesntSoundRight');
  String get soundsGood => _t('soundsGood');
  String get matchLabel => _t('matchLabel');
  String get yourAttempt => _t('yourAttempt');
  String get reference => _t('reference');
  String get segmentsCaption => _t('segmentsCaption');
  String get attemptAudioUnavailable => _t('attemptAudioUnavailable');
  String get accuracyScore => _t('accuracyScore');
  String get fluencyScore => _t('fluencyScore');
  String get completenessScore => _t('completenessScore');
  String get prosodyScore => _t('prosodyScore');
  String get soundAccuracyLegend => _t('soundAccuracyLegend');
  String get omissionTag => _t('omissionTag');
  String get insertionTag => _t('insertionTag');
  String get mispronunciationTag => _t('mispronunciationTag');
  String get feedbackFocusPhonemes => _t('feedbackFocusPhonemes');
  String get feedbackOmission => _t('feedbackOmission');
  String get feedbackInsertion => _t('feedbackInsertion');
  String get feedbackWrongWord => _t('feedbackWrongWord');
  String get feedbackPhraseIncomplete => _t('feedbackPhraseIncomplete');
  String get feedbackStart => _t('feedbackStart');
  String get feedbackMiddle => _t('feedbackMiddle');
  String get feedbackEnd => _t('feedbackEnd');
  String get feedbackMismatch => _t('feedbackMismatch');
  String get feedbackExtra => _t('feedbackExtra');
  String get feedbackClose => _t('feedbackClose');
  String get micUnavailable => _t('micUnavailable');
  String get audioTooQuiet => _t('audioTooQuiet');
  String get unclearAudio => _t('unclearAudio');
  String get invalidAudioFormat => _t('invalidAudioFormat');
  String get assessmentNetworkError => _t('assessmentNetworkError');
  String get assessmentUnavailable => _t('assessmentUnavailable');
  String get tokenFailed => _t('tokenFailed');
  String get assessmentTimedOut => _t('assessmentTimedOut');
  String get assessmentFailed => _t('assessmentFailed');
  String get malformedResponse => _t('malformedResponse');

  String get dictionary => _t('dictionary');
  String get searchAnyWord => _t('searchAnyWord');
  String get searchingWord => _t('searchingWord');
  String get dictionaryHint => _t('dictionaryHint');
  String get meaning => _t('meaning');
  String get wordNotFoundMessage => _t('wordNotFoundMessage');
  String get couldNotConnect => _t('couldNotConnect');
  String get dictionaryApiError => _t('dictionaryApiError');
  String get requestTimedOut => _t('requestTimedOut');
  String get dictionaryInvalidResponse => _t('dictionaryInvalidResponse');
  String get saveWordFailed => _t('saveWordFailed');
  String get recentSearches => _t('recentSearches');
  String get viewDetails => _t('viewDetails');
  String get addToMyWords => _t('addToMyWords');
  String get removeFromMyWords => _t('removeFromMyWords');
  String get wordAddedToMyWords => _t('wordAddedToMyWords');
  String get sourceLabel => _t('sourceLabel');
  String get fetchWord => _t('fetchWord');
  String get fetchWordHint => _t('fetchWordHint');
  String get autoFetched => _t('autoFetched');

  String get networkError => _t('networkError');
  String get unknownError => _t('unknownError');
  String get retry => _t('retry');

  String get login => _t('login');
  String get signUp => _t('signUp');
  String get logout => _t('logout');
  String get email => _t('email');
  String get password => _t('password');
  String get confirmPassword => _t('confirmPassword');
  String get name => _t('name');
  String get welcomeBack => _t('welcomeBack');
  String get signInToContinue => _t('signInToContinue');
  String get createAccount => _t('createAccount');
  String get joinLingoLearn => _t('joinLingoLearn');
  String get dontHaveAccount => _t('dontHaveAccount');
  String get alreadyHaveAccount => _t('alreadyHaveAccount');
  String get emailRequired => _t('emailRequired');
  String get invalidEmail => _t('invalidEmail');
  String get passwordRequired => _t('passwordRequired');
  String get passwordTooShort => _t('passwordTooShort');
  String get nameRequired => _t('nameRequired');
  String get passwordsDoNotMatch => _t('passwordsDoNotMatch');
  String get loginFailed => _t('loginFailed');
  String get signUpFailed => _t('signUpFailed');
  String get emailAlreadyExists => _t('emailAlreadyExists');
  String get invalidCredentials => _t('invalidCredentials');
  String get logoutConfirm => _t('logoutConfirm');
  String get logoutMessage => _t('logoutMessage');
  String get account => _t('account');
  String get wrongPassword => _t('wrongPassword');
  String get userNotFound => _t('userNotFound');
  String get weakPassword => _t('weakPassword');
  String get tooManyRequests => _t('tooManyRequests');
  String get userDisabled => _t('userDisabled');
  String get operationNotAllowed => _t('operationNotAllowed');
  String get requiresRecentLogin => _t('requiresRecentLogin');

  String text(String key) => _t(key);

  String _t(String key) {
    return (locale.languageCode == 'ar' ? arStrings : enStrings)[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
