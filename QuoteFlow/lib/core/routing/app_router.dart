import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/utils/prefs.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/main.dart' show appNavigatorKey;
import 'package:quoteflow/features/splash/presentation/splash_screen.dart';
import 'package:quoteflow/features/onboarding/presentation/onboarding_screen.dart';
import 'package:quoteflow/features/auth/presentation/login_screen.dart';
import 'package:quoteflow/features/auth/presentation/signup_screen.dart';
import 'package:quoteflow/features/home/presentation/home_screen.dart';

enum AppRoute { splash, onboarding, login, signUp, home }

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  AppRoute _currentRoute = AppRoute.splash;
  bool _onboardingCompleted = false;
  bool _splashDone = false;
  bool _wasAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _startup();
  }

  /// Loads onboarding state, then confirms the auth state is resolved before
  /// the splash hands off to the next screen.
  Future<void> _startup() async {
    await _loadOnboardingState();
    if (!mounted) return;

    // Wait until the auth state has been resolved by the provider (capped so
    // we never block indefinitely).
    final auth = context.read<AuthProvider>();
    await _waitForAuth(auth);
  }

  Future<void> _waitForAuth(AuthProvider auth) async {
    const timeout = Duration(seconds: 8);
    final deadline = DateTime.now().add(timeout);
    while (auth.isLoading && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }
  }

  Future<void> _loadOnboardingState() async {
    final prefs = await Prefs.instance;
    _onboardingCompleted = prefs.getBool(AppConstants.prefsKeyOnboardingCompleted) ?? false;
    if (mounted) setState(() {});
  }

  void _routeTo(AppRoute route, {bool? onboarding}) {
    if (!mounted) return;
    setState(() {
      if (onboarding != null) _onboardingCompleted = onboarding;
      _currentRoute = route;
    });
  }

  void _onSplashComplete() {
    _splashDone = true;
    final auth = context.read<AuthProvider>();
    _wasAuthenticated = auth.isAuthenticated;
    _goToTarget(auth);
  }

  /// Routes to the appropriate home/auth screen after opening.
  void _goToTarget(AuthProvider auth) {
    if (!mounted) return;
    if (auth.isAuthenticated) {
      _routeTo(AppRoute.home);
    } else if (_onboardingCompleted) {
      _routeTo(AppRoute.login);
    } else {
      _routeTo(AppRoute.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Only react to auth state *transitions*, never override the current
    // screen while a form is being submitted.
    if (_splashDone) {
      final isAuthed = auth.isAuthenticated;

      // Logged in -> go Home.
      if (isAuthed && !_wasAuthenticated) {
        _wasAuthenticated = true;
        Future.microtask(() => _routeTo(AppRoute.home));
      }
      // Logged out (and we were in Home) -> go to Login.
      else if (!isAuthed &&
          _wasAuthenticated &&
          (_currentRoute == AppRoute.home ||
              _currentRoute == AppRoute.splash)) {
        // Consume the transition synchronously so that any subsequent
        // rebuild triggered by the auth provider won't re-enter this
        // branch while the post-frame work is still pending.
        _wasAuthenticated = false;

        // Pop any pushed screens (e.g. Settings, Favorites) back to the
        // root and switch to Login *after* the current frame completes.
        // Calling popUntil() directly inside build() mutates the Navigator
        // route stack, which triggers OverlayState.setState() during the
        // build phase and causes the "setState() called during build" error.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          appNavigatorKey.currentState?.popUntil(
            (route) => route.isFirst,
          );
          _routeTo(AppRoute.login);
        });
      }
    }

    return _buildRoute(_currentRoute);
  }

  Widget _buildRoute(AppRoute route) {
    switch (route) {
      case AppRoute.splash:
        return SplashScreen(onComplete: _onSplashComplete);
      case AppRoute.onboarding:
        return OnboardingScreen(
          onComplete: () => _routeTo(AppRoute.login, onboarding: true),
        );
      case AppRoute.login:
        return LoginScreen(
          onNavigateToSignUp: () => _routeTo(AppRoute.signUp),
        );
      case AppRoute.signUp:
        return SignUpScreen(
          onNavigateToLogin: () => _routeTo(AppRoute.login),
        );
      case AppRoute.home:
        return const HomeScreen();
    }
  }
}
