import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task1/core/localization/app_localizations.dart';
import 'package:task1/core/theme/app_theme.dart';
import 'package:task1/widgets/welcome_header.dart';

void main() {
  testWidgets('WelcomeHeader renders user name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.lightTheme(),
        home: const Scaffold(
          body: WelcomeHeader(userName: 'Ahmed', isLoading: false),
        ),
      ),
    );

    await tester.pump();

    expect(find.textContaining('Ahmed'), findsOneWidget);
    expect(find.textContaining('Welcome'), findsOneWidget);
  });
}
