import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'generated/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_manager.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'features/profile/data/profile_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FitTrackApp());
}

class FitTrackApp extends StatefulWidget {
  const FitTrackApp({super.key});

  @override
  State<FitTrackApp> createState() => _FitTrackAppState();
}

class _FitTrackAppState extends State<FitTrackApp> {
  late final ThemeModeManager _themeModeManager;

  @override
  void initState() {
    super.initState();
    _themeModeManager = ThemeModeManager();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final savedMode = await AppTheme.loadThemeMode();
    _themeModeManager.setMode(savedMode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeModeManager),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeManager = context.watch<ThemeModeManager>();
          final localeProvider = context.watch<LocaleProvider>();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FitTrack',
            themeMode: themeManager.mode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.splash,
          );
        },
      ),
    );
  }
}
