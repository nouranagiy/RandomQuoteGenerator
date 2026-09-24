import 'package:flutter/material.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/core/utils/prefs.dart';

enum ThemeModeOption { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeModeOption _mode = ThemeModeOption.system;
  ThemeModeOption get mode => _mode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await Prefs.instance;
    final index = prefs.getInt(AppConstants.prefsKeyIsDarkMode) ?? 0;
    _mode = ThemeModeOption.values[index.clamp(0, 2)];
    notifyListeners();
  }

  Future<void> setMode(ThemeModeOption mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await Prefs.instance;
    await prefs.setInt(AppConstants.prefsKeyIsDarkMode, mode.index);
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
}
