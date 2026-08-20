import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
class SplashScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool onboardingCompleted;
  final Future<void> Function() onFinishOnboarding;
  const SplashScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onboardingCompleted,
    required this.onFinishOnboarding,
  });
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 2),
      _goNext,
    );
  }
  void _goNext() {
    if (!mounted) return;
    if (widget.onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onFinished: widget.onFinishOnboarding,
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
      );
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.translate_rounded,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 25),
            Text('LingoLearn',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ), SizedBox(height: 8),
            Text('Learn. Practice. Improve.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ), SizedBox(height: 35),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}