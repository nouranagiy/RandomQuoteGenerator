import 'package:flutter/material.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/utils/prefs.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await Prefs.instance;
    final code = prefs.getString(AppConstants.prefsKeyLocale) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await Prefs.instance;
    await prefs.setString(AppConstants.prefsKeyLocale, locale.languageCode);
  }
}
