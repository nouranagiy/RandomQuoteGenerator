import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/routing/app_navigator_key.dart';
import 'package:quoteflow/core/routing/app_router.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/core/utils/prefs.dart';
import 'package:quoteflow/features/auth/presentation/login_screen.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_provider.dart';
import 'package:quoteflow/features/onboarding/presentation/onboarding_screen.dart';
import 'package:quoteflow/features/shell/presentation/app_shell.dart';
import 'package:quoteflow/features/splash/presentation/startup_error_view.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/providers/locale_provider.dart';
import 'package:quoteflow/shared/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AuthProvider> pumpApp(
    WidgetTester tester, {
    bool authenticated = true,
    bool onboardingCompleted = true,
    AppBootstrap? bootstrap,
  }) async {
    Prefs.resetForTesting();
    SharedPreferences.setMockInitialValues({
      AppConstants.prefsKeyOnboardingCompleted: onboardingCompleted,
    });
    final auth = AuthProvider()
      ..loadingOverride = false
      ..authenticatedOverride = authenticated;
    const locale = Locale('en');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(
            create: (context) =>
                FavoritesProvider()..bindTo(context.read<AuthProvider>()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          theme: AppTheme.light(locale),
          darkTheme: AppTheme.dark(locale),
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AppRouter(bootstrap: bootstrap ?? () async {}),
        ),
      ),
    );
    await tester.pump(AppMotion.splash);
    await tester.pumpAndSettle();
    return auth;
  }

  testWidgets('logout returns to login and clears pushed routes', (
    tester,
  ) async {
    final auth = await pumpApp(tester);
    expect(find.byType(AppShell), findsOneWidget);

    appNavigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Detail')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Detail'), findsOneWidget);

    auth.authenticatedOverride = false;
    auth.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('Detail'), findsNothing);
    expect(find.byType(AppShell), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('signed-out startup reaches login after onboarding', (
    tester,
  ) async {
    await pumpApp(tester, authenticated: false);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('first launch reaches onboarding', (tester) async {
    await pumpApp(tester, authenticated: false, onboardingCompleted: false);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('startup failure can retry successfully', (tester) async {
    var attempts = 0;
    await pumpApp(
      tester,
      bootstrap: () async {
        attempts++;
        if (attempts == 1) throw StateError('startup failed');
      },
    );

    expect(find.byType(StartupErrorView), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump(AppMotion.splash);
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.byType(StartupErrorView), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
  });
}
