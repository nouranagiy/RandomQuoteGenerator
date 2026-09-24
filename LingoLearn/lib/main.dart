import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/onboarding/data/onboarding_store.dart';
import 'firebase_options.dart';

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void _configureFirestore() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authController = AuthController();

  final themeFuture = ThemeController.init();
  final localeFuture = LocaleController.init();
  final onboardingFuture = OnboardingStore.load();

  _initializeFirebase().then((_) {
    authController.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) => _configureFirestore());
  });

  runApp(
    LingoLearnApp(
      themeController: await themeFuture,
      localeController: await localeFuture,
      onboardingStore: await onboardingFuture,
      authController: authController,
    ),
  );
}

class LingoLearnApp extends StatelessWidget {
  final ThemeController themeController;
  final LocaleController localeController;
  final OnboardingStore onboardingStore;
  final AuthController authController;
  const LingoLearnApp({
    super.key,
    required this.themeController,
    required this.localeController,
    required this.onboardingStore,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScope(
      store: onboardingStore,
      child: ThemeControllerScope(
        controller: themeController,
        child: LocaleControllerScope(
          controller: localeController,
          child: AuthControllerScope(
            controller: authController,
            child: ListenableBuilder(
              listenable: Listenable.merge([
                themeController,
                localeController,
                authController,
              ]),
              builder: (context, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'LingoLearn',

                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeController.themeMode,

                  locale: localeController.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],

                  initialRoute: AppRoutes.splash,
                  onGenerateRoute: AppRouter.onGenerateRoute,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
