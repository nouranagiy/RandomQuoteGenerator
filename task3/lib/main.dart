import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(
    FitTrackApp(
      isDarkMode: isDarkMode,
    ),
  );
}
class FitTrackApp extends StatefulWidget {
  final bool isDarkMode;
  const FitTrackApp({
    super.key,
    required this.isDarkMode,
  });
  @override
  State<FitTrackApp> createState() => _FitTrackAppState();
}
class _FitTrackAppState extends State<FitTrackApp> {
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
      title: 'FitTrack',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}