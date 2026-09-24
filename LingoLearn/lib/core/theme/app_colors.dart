import 'package:flutter/material.dart';

class AppPalette {
  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color error;
  final Color onError;
  final Color outline;
  final Color outlineVariant;
  final Color surfaceContainerHighest;
  final Color card;

  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.error,
    required this.onError,
    required this.outline,
    required this.outlineVariant,
    required this.surfaceContainerHighest,
    required this.card,
  });

  ColorScheme get colorScheme => ColorScheme(
    brightness: brightness,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    error: error,
    onError: onError,
    outline: outline,
    outlineVariant: outlineVariant,
    surfaceContainerHighest: surfaceContainerHighest,
  );
}

class AppColors {
  AppColors._();

  static const light = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF0D9488),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFCCFBF1),
    onPrimaryContainer: Color(0xFF065F46),
    secondary: Color(0xFF64748B),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE2E8F0),
    onSecondaryContainer: Color(0xFF334155),
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF0F172A),
    onSurfaceVariant: Color(0xFF64748B),
    error: Color(0xFFDC2626),
    onError: Colors.white,
    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFFF1F5F9),
    card: Color(0xFFFFFFFF),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFF2DD4BF),
    onPrimary: Color(0xFF0F172A),
    primaryContainer: Color(0xFF134E4A),
    onPrimaryContainer: Color(0xFF99F6E4),
    secondary: Color(0xFF94A3B8),
    onSecondary: Color(0xFF0F172A),
    secondaryContainer: Color(0xFF334155),
    onSecondaryContainer: Color(0xFFCBD5E1),
    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF94A3B8),
    error: Color(0xFFF87171),
    onError: Color(0xFF0F172A),
    outline: Color(0xFF475569),
    outlineVariant: Color(0xFF334155),
    surfaceContainerHighest: Color(0xFF1E293B),
    card: Color(0xFF1E293B),
  );
}
