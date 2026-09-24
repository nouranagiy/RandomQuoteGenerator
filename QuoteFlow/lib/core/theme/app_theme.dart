import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Pre-computed lazily and cached so theme changes don't rebuild heavy
  // ThemeData objects on every frame.
  static final ThemeData _light = _buildTheme(
    AppColors.lightColorScheme(),
    Brightness.light,
  );
  static final ThemeData _dark = _buildTheme(
    AppColors.darkColorScheme(),
    Brightness.dark,
  );

  static ThemeData lightTheme() => _light;

  static ThemeData darkTheme() => _dark;

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0E1615) : const Color(0xFFF3F8F7),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0E1615) : const Color(0xFFF3F8F7),
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF14201E) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.4),
          fontSize: 15,
        ),
        labelStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.6),
          fontSize: 15,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF14201E) : const Color(0xFF0F766E),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        thickness: 1,
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white70 : Colors.black54,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 28,
          letterSpacing: -0.5,
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          letterSpacing: -0.3,
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.2,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: -0.1,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
