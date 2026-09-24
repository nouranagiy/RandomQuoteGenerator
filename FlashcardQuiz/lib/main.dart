import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/preferences_util.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/splash/presentation/onboarding_screen.dart';
import 'features/auth/presentation/screens/auth_container.dart';
import 'features/home/presentation/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatefulWidget {
  const FlashcardApp({super.key});

  @override
  State<FlashcardApp> createState() => _FlashcardAppState();
}

class _FlashcardAppState extends State<FlashcardApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  String _homeRoute = 'splash';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final themeModeStr = await PreferencesUtil.getThemeMode();
    final langCode = await PreferencesUtil.getLanguage();

    if (!mounted) return;

    setState(() {
      _themeMode = _themeModeFromString(themeModeStr);
      _locale = Locale(langCode);
    });
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await PreferencesUtil.setThemeMode(_themeModeToString(mode));
    setState(() => _themeMode = mode);
  }

  Future<void> _setLanguage(String code) async {
    await PreferencesUtil.setLanguage(code);
    setState(() => _locale = Locale(code));
  }

  void _onRouteDetermined(String route) {
    setState(() => _homeRoute = route);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcard Quiz',
      themeMode: _themeMode,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_homeRoute) {
      case 'splash':
        return SplashScreen(onRouteDetermined: _onRouteDetermined);
      case 'onboarding':
        return OnboardingScreen(onComplete: () => _onRouteDetermined('auth'));
      case 'auth':
        return AuthContainer(onAuthenticated: () => _onRouteDetermined('home'));
      case 'home':
        return HomeScreen(
          onSetThemeMode: _setThemeMode,
          onLogout: () => _onRouteDetermined('auth'),
          currentThemeMode: _themeMode,
          languageCode: _locale.languageCode,
          onLanguageChanged: _setLanguage,
        );
      default:
        return SplashScreen(onRouteDetermined: _onRouteDetermined);
    }
  }
}
