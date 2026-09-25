import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/routing/app_navigator_key.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/core/utils/prefs.dart';
import 'package:quoteflow/features/auth/presentation/login_screen.dart';
import 'package:quoteflow/features/auth/presentation/signup_screen.dart';
import 'package:quoteflow/features/onboarding/presentation/onboarding_screen.dart';
import 'package:quoteflow/features/shell/presentation/app_shell.dart';
import 'package:quoteflow/features/splash/presentation/splash_screen.dart';
import 'package:quoteflow/features/splash/presentation/startup_error_view.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';

typedef AppBootstrap = Future<void> Function();

enum AppRoute { splash, startupError, onboarding, login, signUp, home }

class AppRouter extends StatefulWidget {
  final AppBootstrap bootstrap;

  const AppRouter({super.key, required this.bootstrap});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  AppRoute _currentRoute = AppRoute.splash;
  bool _startupComplete = false;
  bool _onboardingCompleted = false;
  bool _wasAuthenticated = false;
  Object? _startupError;
  AuthProvider? _authProvider;
  int _startupRun = 0;
  int _authTransitionRevision = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_runStartup());
  }

  Future<void> _runStartup() async {
    final run = ++_startupRun;
    if (mounted && (_startupComplete || _startupError != null)) {
      setState(() {
        _startupComplete = false;
        _startupError = null;
        _currentRoute = AppRoute.splash;
      });
    }

    try {
      await Future.wait<void>([
        widget.bootstrap(),
        Future<void>.delayed(AppMotion.splash),
      ]);
      final prefs = await Prefs.instance;
      if (!mounted || run != _startupRun) return;

      final auth = context.read<AuthProvider>();
      _attachAuth(auth);
      _wasAuthenticated = auth.isAuthenticated;
      final onboardingCompleted =
          prefs.getBool(AppConstants.prefsKeyOnboardingCompleted) ?? false;

      setState(() {
        _startupComplete = true;
        _onboardingCompleted = onboardingCompleted;
        _currentRoute = _targetFor(auth.isAuthenticated);
      });
    } catch (error) {
      if (!_isCurrentStartupRun(run)) return;
      setState(() {
        _startupError = error;
        _startupComplete = false;
        _currentRoute = AppRoute.startupError;
      });
    }
  }

  bool _isCurrentStartupRun(int run) => mounted && run == _startupRun;

  void _attachAuth(AuthProvider auth) {
    if (_authProvider == auth) return;
    _authProvider?.removeListener(_handleAuthChanged);
    _authProvider = auth..addListener(_handleAuthChanged);
  }

  AppRoute _targetFor(bool isAuthenticated) {
    if (isAuthenticated) return AppRoute.home;
    return _onboardingCompleted ? AppRoute.login : AppRoute.onboarding;
  }

  void _handleAuthChanged() {
    final auth = _authProvider;
    if (!_startupComplete || auth == null) return;

    final isAuthenticated = auth.isAuthenticated;
    if (isAuthenticated == _wasAuthenticated) return;

    _wasAuthenticated = isAuthenticated;
    final revision = ++_authTransitionRevision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != _authTransitionRevision) return;
      appNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      setState(() {
        _currentRoute = isAuthenticated ? AppRoute.home : _targetFor(false);
      });
    });
  }

  void _routeTo(AppRoute route) {
    if (!mounted) return;
    setState(() {
      _currentRoute = route;
      if (route == AppRoute.login) _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.standard,
      switchInCurve: AppMotion.standardCurve,
      switchOutCurve: AppMotion.exitCurve,
      child: KeyedSubtree(
        key: ValueKey(_currentRoute),
        child: _buildRoute(_currentRoute),
      ),
    );
  }

  Widget _buildRoute(AppRoute route) {
    return switch (route) {
      AppRoute.splash => const SplashScreen(),
      AppRoute.startupError => StartupErrorView(onRetry: _retryStartup),
      AppRoute.onboarding => OnboardingScreen(
        onComplete: () => _routeTo(AppRoute.login),
      ),
      AppRoute.login => LoginScreen(
        onNavigateToSignUp: () => _routeTo(AppRoute.signUp),
      ),
      AppRoute.signUp => SignUpScreen(
        onNavigateToLogin: () => _routeTo(AppRoute.login),
      ),
      AppRoute.home => const AppShell(),
    };
  }

  void _retryStartup() {
    unawaited(_runStartup());
  }

  @override
  void dispose() {
    _startupRun++;
    _authProvider?.removeListener(_handleAuthChanged);
    _authProvider = null;
    super.dispose();
  }
}
