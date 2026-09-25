import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/utils/prefs.dart';

enum LocalePersistenceFailure { loadFailed, saveFailed, invalidStoredValue }

class LocaleProvider extends ChangeNotifier {
  LocaleProvider() {
    unawaited(_loadLocale());
  }

  static const Set<String> _supportedLanguageCodes = {'en', 'ar'};

  Locale _locale = const Locale('en');
  LocalePersistenceFailure? _failure;
  int _revision = 0;
  bool _disposed = false;

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  LocalePersistenceFailure? get failure => _failure;
  bool get hasPersistenceFailure => _failure != null;

  Future<void> _loadLocale() async {
    final revision = _revision;
    try {
      final prefs = await Prefs.instance;
      if (_disposed || revision != _revision) return;

      final code = prefs.getString(AppConstants.prefsKeyLocale);
      if (code == null || _supportedLanguageCodes.contains(code)) {
        _locale = Locale(code ?? 'en');
        _failure = null;
      } else {
        _locale = const Locale('en');
        _failure = LocalePersistenceFailure.invalidStoredValue;
      }
    } catch (_) {
      if (_disposed || revision != _revision) return;
      _failure = LocalePersistenceFailure.loadFailed;
    }
    _notify();
  }

  Future<void> setLocale(Locale locale) async {
    if (_disposed) return;
    final languageCode = _supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'en';
    if (_locale.languageCode == languageCode && _failure == null) return;

    final revision = ++_revision;
    _locale = Locale(languageCode);
    _failure = null;
    _notify();

    try {
      final prefs = await Prefs.instance;
      await prefs.setString(AppConstants.prefsKeyLocale, languageCode);
      if (!_disposed && revision != _revision) {
        await prefs.setString(
          AppConstants.prefsKeyLocale,
          _locale.languageCode,
        );
      }
    } catch (_) {
      if (_disposed || revision != _revision) return;
      _failure = LocalePersistenceFailure.saveFailed;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
