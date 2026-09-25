import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/utils/prefs.dart';

enum ThemeModeOption { system, light, dark }

enum ThemePersistenceFailure { loadFailed, saveFailed, invalidStoredValue }

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    unawaited(_loadTheme());
  }

  ThemeModeOption _mode = ThemeModeOption.system;
  ThemePersistenceFailure? _failure;
  int _revision = 0;
  bool _disposed = false;

  ThemeModeOption get mode => _mode;
  ThemePersistenceFailure? get failure => _failure;
  bool get hasPersistenceFailure => _failure != null;

  Future<void> _loadTheme() async {
    final revision = _revision;
    try {
      final prefs = await Prefs.instance;
      if (_disposed || revision != _revision) return;

      final index = prefs.getInt(AppConstants.prefsKeyIsDarkMode);
      if (index == null) {
        _failure = null;
      } else if (index >= 0 && index < ThemeModeOption.values.length) {
        _mode = ThemeModeOption.values[index];
        _failure = null;
      } else {
        _mode = ThemeModeOption.system;
        _failure = ThemePersistenceFailure.invalidStoredValue;
      }
    } catch (_) {
      if (_disposed || revision != _revision) return;
      _failure = ThemePersistenceFailure.loadFailed;
    }
    _notify();
  }

  Future<void> setMode(ThemeModeOption mode) async {
    if (_disposed || (_mode == mode && _failure == null)) return;
    final revision = ++_revision;
    _mode = mode;
    _failure = null;
    _notify();

    try {
      final prefs = await Prefs.instance;
      await prefs.setInt(AppConstants.prefsKeyIsDarkMode, mode.index);
      if (!_disposed && revision != _revision) {
        await prefs.setInt(AppConstants.prefsKeyIsDarkMode, _mode.index);
      }
    } catch (_) {
      if (_disposed || revision != _revision) return;
      _failure = ThemePersistenceFailure.saveFailed;
      _notify();
    }
  }

  ThemeMode get themeMode {
    switch (_mode) {
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  bool get isDark {
    switch (_mode) {
      case ThemeModeOption.dark:
        return true;
      case ThemeModeOption.light:
        return false;
      case ThemeModeOption.system:
        return false;
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
