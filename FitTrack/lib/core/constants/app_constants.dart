import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Modern palette: violet/indigo primary with teal accent.
  static const Color primaryLight = Color(0xFF5B5FEF);
  static const Color primaryDark = Color(0xFF8B8FF8);
  static const Color accent = Color(0xFF2EC4B6);
  static const Color errorLight = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFEF5350);

  static const Color surfaceLight = Color(0xFFF7F8FC);
  static const Color surfaceDark = Color(0xFF12121A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1D1D29);
  static const Color dividerLight = Color(0xFFE4E7F0);
  static const Color dividerDark = Color(0xFF2E2E3D);

  static const Color tealLight = Color(0xFF2EC4B6);
  static const Color tealDark = Color(0xFF3AD6C8);

  static Color successLight = const Color(0xFF2EC4B6).withValues(alpha: 0.12);
  static Color successDark = const Color(0xFF3AD6C8).withValues(alpha: 0.18);
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 100.0;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get fullAll => BorderRadius.circular(full);
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 2500);
}
