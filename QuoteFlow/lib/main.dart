import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(
    MyApp(
      isDarkMode: isDarkMode,
    ),
  );
}
class MyApp extends StatefulWidget {
  final bool isDarkMode;
  const MyApp({
    super.key,
    required this.isDarkMode,
  });
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }
  Future<void> _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'isDarkMode',
      _isDarkMode,
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuoteFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}