import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/core/utils/prefs.dart';
import 'package:quoteflow/shared/providers/theme_provider.dart';
import 'package:quoteflow/shared/providers/locale_provider.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/core/routing/app_router.dart';
import 'package:quoteflow/firebase_options.dart';
import 'package:quoteflow/features/favorites/presentation/favorites_provider.dart';

Future<void> _initializeFirebase() async {
  // Only core app init is awaited here. This must finish before any Firebase
  // Auth/Firestore call, but it never blocks the first frame because it runs
  // asynchronously after runApp has already scheduled the UI.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void _configureFirestore() {
  // Enable durable offline cache so Firestore reads serve from disk on
  // subsequent launches. Deliberately not awaited and run after the first
  // frame (see main) because it touches the main isolate's native channel.
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (_) {
    // Persistence may already be enabled natively on Android — ignore.
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Create AuthProvider eagerly — its constructor no longer touches Firebase,
  // so the first frame is never blocked waiting for initialization.
  final authProvider = AuthProvider();

  // Start Firebase init and SharedPreferences preload concurrently in the
  // background. runApp is called immediately; the first frame shows the real
  // branded SplashScreen without waiting for any of this.
  _initializeFirebase().then((_) {
    // Firebase is ready: safely attach the auth listener now.
    authProvider.initialize();
    // Defer Firestore native setup until after the first frame paints.
    WidgetsBinding.instance.addPostFrameCallback((_) => _configureFirestore());
  });

  Prefs.preload();

  runApp(QuoteFlowApp(authProvider: authProvider));
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// App root. Renders the UI immediately — no Firebase gating, no spinner.
/// [AuthProvider] is created up front (it is safe before Firebase) and its
/// Firebase listener is attached only after Firebase finishes initializing.
class QuoteFlowApp extends StatefulWidget {
  final AuthProvider authProvider;
  const QuoteFlowApp({super.key, required this.authProvider});

  @override
  State<QuoteFlowApp> createState() => _QuoteFlowAppState();
}

class _QuoteFlowAppState extends State<QuoteFlowApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider(
          create: (ctx) => FavoritesProvider()..bindTo(ctx.read<AuthProvider>()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return MaterialApp(
            navigatorKey: appNavigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'QuoteFlow',
            // Cached theme instances — no rebuild cost on theme/locale changes.
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AppRouter(),
          );
        },
      ),
    );
  }
}
