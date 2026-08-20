import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  runApp(
    LanguageLearningApp(
      initialDarkMode: isDarkMode,
      onboardingCompleted: onboardingCompleted,
    ),
  );
}
class LanguageLearningApp extends StatefulWidget {
  final bool initialDarkMode;
  final bool onboardingCompleted;
  const LanguageLearningApp({
    super.key,
    required this.initialDarkMode,
    required this.onboardingCompleted,
  });
  @override
  State<LanguageLearningApp> createState() => _LanguageLearningAppState();
}
class _LanguageLearningAppState extends State<LanguageLearningApp> {
  late bool isDarkMode;
  late bool onboardingCompleted;
  @override
  void initState() {
    super.initState();
    isDarkMode = widget.initialDarkMode;
    onboardingCompleted = widget.onboardingCompleted;
  }
  Future<void> toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'is_dark_mode',
      isDarkMode,
    );
  }
  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'onboarding_completed',
      true,
    );
    if (!mounted) return;
    setState(() {
      onboardingCompleted = true;
    });
  }
  Widget _getInitialScreen() {
    return SplashScreen(
      isDarkMode: isDarkMode,
      onToggleTheme: toggleTheme,
      onboardingCompleted: onboardingCompleted,
      onFinishOnboarding: finishOnboarding,
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LingoLearn',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: _getInitialScreen(),
    );
  }
}