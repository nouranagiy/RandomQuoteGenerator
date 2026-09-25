import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/routing/app_navigator_key.dart';
import 'package:quoteflow/core/routing/app_router.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_provider.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/providers/locale_provider.dart';
import 'package:quoteflow/shared/providers/theme_provider.dart';

class QuoteFlowApp extends StatelessWidget {
  final AuthProvider authProvider;
  final AppBootstrap bootstrap;

  const QuoteFlowApp({
    super.key,
    required this.authProvider,
    required this.bootstrap,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              FavoritesProvider()..bindTo(context.read<AuthProvider>()),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          final locale = localeProvider.locale;
          return MaterialApp(
            navigatorKey: appNavigatorKey,
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.l10n.appTitle,
            theme: AppTheme.light(locale),
            darkTheme: AppTheme.dark(locale),
            themeMode: themeProvider.themeMode,
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AppRouter(bootstrap: bootstrap),
          );
        },
      ),
    );
  }
}
