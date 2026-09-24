import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/onboarding/data/onboarding_store.dart';
import '../localization/app_localizations.dart';
import '../widgets/app_icon_tile.dart';
import 'app_router.dart';

String initialRouteFor({
  required bool onboardingCompleted,
  required bool isAuthenticated,
}) {
  if (isAuthenticated) return AppRoutes.home;
  return onboardingCompleted ? AppRoutes.login : AppRoutes.onboarding;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  Timer? _timer;
  DateTime? _authDeadline;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
    _timer = Timer(const Duration(milliseconds: 2), _decideInitialRoute);
  }

  void _decideInitialRoute() {
    if (!mounted) return;
    final onboardingStore = OnboardingScope.of(context);
    final auth = AuthControllerScope.of(context);

    if (auth.isLoading && !_authTimedOut) {
      _authDeadline ??= DateTime.now().add(const Duration(seconds: 8));
      _timer = Timer(const Duration(milliseconds: 50), _decideInitialRoute);
      return;
    }

    final route = initialRouteFor(
      onboardingCompleted: onboardingStore.isCompleted,
      isAuthenticated: auth.isAuthenticated,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  bool get _authTimedOut =>
      _authDeadline != null && DateTime.now().isAfter(_authDeadline!);

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIconTile(
                  icon: Icons.translate_rounded,
                  size: 110,
                  iconSize: 56,
                  borderRadius: 30,
                ),
                const SizedBox(height: 24),
                Text(
                  l.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.tagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
