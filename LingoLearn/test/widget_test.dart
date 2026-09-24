import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingolearn/core/localization/locale_controller.dart';
import 'package:lingolearn/core/theme/theme_controller.dart';
import 'package:lingolearn/features/auth/presentation/auth_controller.dart';
import 'package:lingolearn/features/onboarding/data/onboarding_store.dart';
import 'package:lingolearn/features/onboarding/presentation/onboarding_screen.dart';
import 'package:lingolearn/main.dart';

void main() {
  testWidgets('App boots into onboarding on first launch', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final themeController = ThemeController(ThemeMode.system);
    final localeController = LocaleController(const Locale('en'));
    final onboardingStore = await OnboardingStore.load();
    final authController = AuthController()
      ..loadingOverride = false
      ..authenticatedOverride = false;

    await tester.pumpWidget(
      LingoLearnApp(
        themeController: themeController,
        localeController: localeController,
        onboardingStore: onboardingStore,
        authController: authController,
      ),
    );
    await tester.pump();

    expect(find.text('LingoLearn'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
