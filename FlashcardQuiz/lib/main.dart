import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatefulWidget {
  const FlashcardApp({super.key});

  @override
  State<FlashcardApp> createState() => _FlashcardAppState();
}

class _FlashcardAppState extends State<FlashcardApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool('isDarkMode') ?? false;

    if (!mounted) return;

    setState(() {
      _themeMode =
      isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = _themeMode != ThemeMode.dark;

    await prefs.setBool('isDarkMode', isDark);

    setState(() {
      _themeMode =
      isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcard Quiz',

      themeMode: _themeMode,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFF7F8FC),
          surfaceTintColor: Colors.transparent,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF181A1F),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF181A1F),
          surfaceTintColor: Colors.transparent,
        ),
      ),

      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}