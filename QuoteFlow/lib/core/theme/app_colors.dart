import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color _seedLight = Color(0xFF2EB69E);
  static const Color _seedDark = Color(0xFF5EEAD4);

  static const Color _surfaceLight = Color(0xFFF3F8F7);
  static const Color _surfaceDark = Color(0xFF0E1615);

  static const Color _primaryLight = Color(0xFF0F766E);
  static const Color _primaryDark = Color(0xFF2DD4BF);

  static const Color _accentLight = Color(0xFF14B8A6);
  static const Color _accentDark = Color(0xFF99F6E4);

  static ColorScheme lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: _seedLight,
      brightness: Brightness.light,
      primary: _primaryLight,
      secondary: _accentLight,
      surface: _surfaceLight,
      error: const Color(0xFFDC362E),
    );
  }

  static ColorScheme darkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: _seedDark,
      brightness: Brightness.dark,
      primary: _primaryDark,
      secondary: _accentDark,
      surface: _surfaceDark,
      error: const Color(0xFFFF6B6B),
    );
  }
}
