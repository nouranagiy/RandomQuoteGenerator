import 'package:flutter/material.dart';

import 'splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/dictionary/data/dictionary_entry.dart';
import '../../features/dictionary/presentation/dictionary_screen.dart';
import '../../features/dictionary/presentation/dictionary_word_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/home/presentation/daily_lesson_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/pronunciation/presentation/pronunciation_screen.dart';
import '../../features/quiz/presentation/quiz_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/vocabulary/data/language_word.dart';
import '../../features/vocabulary/presentation/add_word_screen.dart';
import '../../features/vocabulary/presentation/edit_word_screen.dart';
import '../../features/vocabulary/presentation/vocabulary_screen.dart';
import '../../features/vocabulary/presentation/word_details_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String vocabulary = '/vocabulary';
  static const String addWord = '/add-word';
  static const String editWord = '/edit-word';
  static const String wordDetails = '/word-details';
  static const String quiz = '/quiz';
  static const String favorites = '/favorites';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String dailyLesson = '/daily-lesson';
  static const String pronunciation = '/pronunciation';
  static const String dictionary = '/dictionary';
  static const String dictionaryWord = '/dictionary-word';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen());
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen());
      case AppRoutes.login:
        return _buildRoute(const LoginScreen());
      case AppRoutes.signUp:
        return _buildRoute(const SignUpScreen());
      case AppRoutes.home:
        return _buildRoute(const HomeScreen());
      case AppRoutes.vocabulary:
        return _buildRoute(const VocabularyScreen());
      case AppRoutes.addWord:
        return _buildRoute(const AddWordScreen());
      case AppRoutes.editWord:
        final word = routeSettings.arguments as LanguageWord;
        return _buildRoute(EditWordScreen(word: word));
      case AppRoutes.wordDetails:
        final word = routeSettings.arguments as LanguageWord;
        return _buildRoute(WordDetailsScreen(word: word));
      case AppRoutes.quiz:
        return _buildRoute(const QuizScreen());
      case AppRoutes.favorites:
        return _buildRoute(const FavoritesScreen());
      case AppRoutes.progress:
        return _buildRoute(const ProgressScreen());
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen());
      case AppRoutes.dailyLesson:
        final word = routeSettings.arguments as LanguageWord;
        return _buildRoute(DailyLessonScreen(word: word));
      case AppRoutes.pronunciation:
        final word = routeSettings.arguments as LanguageWord;
        return _buildRoute(PronunciationScreen(word: word));
      case AppRoutes.dictionary:
        return _buildRoute(const DictionaryScreen());
      case AppRoutes.dictionaryWord:
        final entry = routeSettings.arguments as DictionaryEntry;
        return _buildRoute(DictionaryWordScreen(entry: entry));
      default:
        return _buildRoute(const HomeScreen());
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(Widget page) {
    return MaterialPageRoute<T>(builder: (_) => page);
  }
}
