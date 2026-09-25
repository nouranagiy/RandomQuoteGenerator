import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const Color lightCanvas = Color(0xFFF7F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF0F0F6);
  static const Color lightOutline = Color(0xFFDDDCEA);
  static const Color lightOutlineStrong = Color(0xFFC7C4D6);
  static const Color lightText = Color(0xFF171522);
  static const Color lightTextSecondary = Color(0xFF5F5D70);
  static const Color lightTextMuted = Color(0xFF858296);
  static const Color lightPrimary = Color(0xFF2563EB);
  static const Color lightPrimaryHover = Color(0xFF5944D8);
  static const Color lightPrimaryPressed = Color(0xFF4D3AC4);
  static const Color lightPrimarySoft = Color(0xFFEEEAFE);
  static const Color lightPrimarySoftStrong = Color(0xFFDDD5FE);
  static const Color lightAccent = Color(0xFFE86A47);
  static const Color lightAccentHover = Color(0xFFCF5838);
  static const Color lightAccentSoft = Color(0xFFFFF0EA);
  static const Color lightSuccess = Color(0xFF168A61);
  static const Color lightSuccessSoft = Color(0xFFE6F5EF);
  static const Color lightWarning = Color(0xFFB66A13);
  static const Color lightWarningSoft = Color(0xFFFFF3DE);
  static const Color lightError = Color(0xFFC53D52);
  static const Color lightErrorSoft = Color(0xFFFDECEF);
  static const Color lightShadow = Color(0xFF171522);

  static const Color darkCanvas = Color(0xFF0F0E16);
  static const Color darkSurface = Color(0xFF171620);
  static const Color darkSurfaceElevated = Color(0xFF242130);
  static const Color darkSurfaceSubtle = Color(0xFF201E2B);
  static const Color darkOutline = Color(0xFF373345);
  static const Color darkOutlineStrong = Color(0xFF4A4559);
  static const Color darkText = Color(0xFFF8F6FF);
  static const Color darkTextSecondary = Color(0xFFC2BED2);
  static const Color darkTextMuted = Color(0xFF8D899E);
  static const Color darkPrimary = Color(0xFF60A5FA);
  static const Color darkPrimaryHover = Color(0xFFB9AAFF);
  static const Color darkPrimaryPressed = Color(0xFF8B75F5);
  static const Color darkPrimarySoft = Color(0xFF292340);
  static const Color darkPrimarySoftStrong = Color(0xFF372F59);
  static const Color darkAccent = Color(0xFFFF9A78);
  static const Color darkAccentHover = Color(0xFFFFB096);
  static const Color darkAccentSoft = Color(0xFF3B2525);
  static const Color darkSuccess = Color(0xFF5DD5A5);
  static const Color darkSuccessSoft = Color(0xFF17352B);
  static const Color darkWarning = Color(0xFFF2B95B);
  static const Color darkWarningSoft = Color(0xFF3A2D16);
  static const Color darkError = Color(0xFFFF8295);
  static const Color darkErrorSoft = Color(0xFF3E1F28);
  static const Color darkShadow = Color(0xFF050409);

  static ColorScheme lightScheme() =>
      ColorScheme.fromSeed(
        seedColor: lightPrimary,
        brightness: Brightness.light,
      ).copyWith(
        primary: lightPrimary,
        onPrimary: lightSurface,
        primaryContainer: lightPrimarySoft,
        onPrimaryContainer: lightText,
        secondary: lightAccent,
        onSecondary: lightSurface,
        secondaryContainer: lightAccentSoft,
        onSecondaryContainer: lightText,
        tertiary: lightAccent,
        onTertiary: lightSurface,
        tertiaryContainer: lightAccentSoft,
        onTertiaryContainer: lightText,
        error: lightError,
        onError: lightSurface,
        errorContainer: lightErrorSoft,
        onErrorContainer: lightError,
        surface: lightCanvas,
        onSurface: lightText,
        onSurfaceVariant: lightTextSecondary,
        surfaceContainerLowest: lightSurface,
        surfaceContainerLow: lightSurface,
        surfaceContainer: lightSurfaceSubtle,
        surfaceContainerHigh: lightSurface,
        surfaceContainerHighest: lightSurfaceSubtle,
        surfaceTint: lightPrimary,
        outline: lightOutlineStrong,
        outlineVariant: lightOutline,
        inverseSurface: lightText,
        onInverseSurface: lightCanvas,
        inversePrimary: darkPrimary,
        shadow: lightShadow,
        scrim: lightShadow,
      );

  static ColorScheme darkScheme() =>
      ColorScheme.fromSeed(
        seedColor: darkPrimary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: darkPrimary,
        onPrimary: darkCanvas,
        primaryContainer: darkPrimarySoft,
        onPrimaryContainer: darkText,
        secondary: darkAccent,
        onSecondary: darkCanvas,
        secondaryContainer: darkAccentSoft,
        onSecondaryContainer: darkText,
        tertiary: darkAccent,
        onTertiary: darkCanvas,
        tertiaryContainer: darkAccentSoft,
        onTertiaryContainer: darkText,
        error: darkError,
        onError: darkCanvas,
        errorContainer: darkErrorSoft,
        onErrorContainer: darkError,
        surface: darkCanvas,
        onSurface: darkText,
        onSurfaceVariant: darkTextSecondary,
        surfaceContainerLowest: darkCanvas,
        surfaceContainerLow: darkSurface,
        surfaceContainer: darkSurfaceSubtle,
        surfaceContainerHigh: darkSurfaceElevated,
        surfaceContainerHighest: darkSurfaceElevated,
        surfaceTint: darkPrimary,
        outline: darkOutlineStrong,
        outlineVariant: darkOutline,
        inverseSurface: darkText,
        onInverseSurface: darkCanvas,
        inversePrimary: lightPrimary,
        shadow: darkShadow,
        scrim: darkShadow,
      );

  static AppSemanticColors semanticColors(Brightness brightness) {
    return brightness == Brightness.dark
        ? const AppSemanticColors(
            success: darkSuccess,
            successContainer: darkSuccessSoft,
            warning: darkWarning,
            warningContainer: darkWarningSoft,
            favorite: darkAccent,
            favoriteContainer: darkAccentSoft,
          )
        : const AppSemanticColors(
            success: lightSuccess,
            successContainer: lightSuccessSoft,
            warning: lightWarning,
            warningContainer: lightWarningSoft,
            favorite: lightAccent,
            favoriteContainer: lightAccentSoft,
          );
  }
}

abstract final class AppGradients {
  AppGradients._();

  static LinearGradient logo(ColorScheme colorScheme) => LinearGradient(
    colors: [
      colorScheme.primary,
      colorScheme.primary.withValues(alpha: AppOpacity.strong),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient splashBackground(ColorScheme colorScheme) =>
      LinearGradient(
        colors: [
          colorScheme.primaryContainer,
          colorScheme.surface,
          colorScheme.secondaryContainer,
        ],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      );
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color favorite;
  final Color favoriteContainer;

  const AppSemanticColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.favorite,
    required this.favoriteContainer,
  });

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? favorite,
    Color? favoriteContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      favorite: favorite ?? this.favorite,
      favoriteContainer: favoriteContainer ?? this.favoriteContainer,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      favorite: Color.lerp(favorite, other.favorite, t)!,
      favoriteContainer: Color.lerp(
        favoriteContainer,
        other.favoriteContainer,
        t,
      )!,
    );
  }
}

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double giant = 64;
}

abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double expanded = 960;
}

abstract final class AppSizes {
  static const double buttonHeight = 52;
  static const double touchTarget = 48;
  static const double navigationHeight = 72;
  static const double contentMaxWidth = 720;
  static const double formMaxWidth = 440;
  static const double onboardingMaxWidth = 520;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double logoSm = 36;
  static const double logoMd = 48;
  static const double logoLg = 72;
  static const double logoHero = 88;
}

abstract final class AppOpacity {
  static const double subtle = 0.08;
  static const double muted = 0.12;
  static const double disabled = 0.38;
  static const double strong = 0.72;
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration standard = Duration(milliseconds: 180);
  static const Duration relaxed = Duration(milliseconds: 240);
  static const Duration splash = Duration(milliseconds: 720);
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
}

abstract final class AppShadows {
  static List<BoxShadow> low(Brightness brightness) {
    final shadow = brightness == Brightness.dark
        ? AppPalette.darkShadow
        : AppPalette.lightShadow;
    return [
      BoxShadow(
        color: shadow.withValues(
          alpha: brightness == Brightness.dark ? 0.28 : 0.05,
        ),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> medium(Brightness brightness) {
    final shadow = brightness == Brightness.dark
        ? AppPalette.darkShadow
        : AppPalette.lightShadow;
    return [
      BoxShadow(
        color: shadow.withValues(
          alpha: brightness == Brightness.dark ? 0.32 : 0.07,
        ),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: shadow.withValues(
          alpha: brightness == Brightness.dark ? 0.20 : 0.03,
        ),
        blurRadius: 2,
        offset: Offset.zero,
      ),
    ];
  }
}

abstract final class AppTheme {
  static final Map<({Brightness brightness, String language}), ThemeData>
  _cache = {};

  static ThemeData light(Locale locale) =>
      _build(brightness: Brightness.light, locale: locale);

  static ThemeData dark(Locale locale) =>
      _build(brightness: Brightness.dark, locale: locale);

  static ThemeData _build({
    required Brightness brightness,
    required Locale locale,
  }) {
    final key = (brightness: brightness, language: locale.languageCode);
    return _cache.putIfAbsent(key, () {
      final colors = brightness == Brightness.dark
          ? AppPalette.darkScheme()
          : AppPalette.lightScheme();
      final fontFamily = locale.languageCode == 'ar'
          ? 'Noto Sans Arabic'
          : 'Plus Jakarta Sans';
      final textTheme = _textTheme(colors, fontFamily);
      final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colors.outlineVariant),
      );

      return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: colors,
        scaffoldBackgroundColor: colors.surface,
        fontFamily: fontFamily,
        fontFamilyFallback: const ['Noto Sans Arabic', 'Plus Jakarta Sans'],
        textTheme: textTheme,
        extensions: [AppPalette.semanticColors(brightness)],
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: AppBarTheme(
          backgroundColor: colors.surface.withValues(alpha: 0.92),
          foregroundColor: colors.onSurface,
          surfaceTintColor: colors.surfaceTint.withValues(alpha: 0),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: textTheme.titleLarge,
        ),
        cardTheme: CardThemeData(
          color: colors.surfaceContainerHigh,
          surfaceTintColor: colors.surfaceTint.withValues(alpha: 0),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            disabledBackgroundColor: colors.primary.withValues(
              alpha: AppOpacity.disabled,
            ),
            disabledForegroundColor: colors.onPrimary.withValues(
              alpha: AppOpacity.disabled,
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            textStyle: textTheme.labelLarge,
            overlayColor: colors.onPrimary.withValues(alpha: AppOpacity.muted),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            disabledBackgroundColor: colors.primary.withValues(
              alpha: AppOpacity.disabled,
            ),
            disabledForegroundColor: colors.onPrimary.withValues(
              alpha: AppOpacity.disabled,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            textStyle: textTheme.labelLarge,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.outline),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            textStyle: textTheme.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
            minimumSize: const Size(AppSizes.touchTarget, AppSizes.touchTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            textStyle: textTheme.labelLarge,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            minimumSize: const Size.square(AppSizes.touchTarget),
            foregroundColor: colors.onSurfaceVariant,
            highlightColor: colors.primary.withValues(alpha: AppOpacity.subtle),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: colors.primary, width: 1.6),
          ),
          errorBorder: border.copyWith(
            borderSide: BorderSide(color: colors.error),
          ),
          focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(color: colors.error, width: 1.6),
          ),
          labelStyle: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: AppOpacity.strong),
          ),
          errorStyle: textTheme.bodySmall?.copyWith(color: colors.error),
          prefixIconColor: colors.onSurfaceVariant,
          suffixIconColor: colors.onSurfaceVariant,
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: AppSizes.navigationHeight,
          backgroundColor: colors.surfaceContainerLow,
          surfaceTintColor: colors.surfaceTint.withValues(alpha: 0),
          elevation: 0,
          indicatorColor: colors.primaryContainer,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.onSurfaceVariant,
              size: AppSizes.iconMd,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return textTheme.labelSmall?.copyWith(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.onSurfaceVariant,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
        ),
        navigationDrawerTheme: NavigationDrawerThemeData(
          backgroundColor: colors.surfaceContainerLow,
          surfaceTintColor: colors.surfaceTint.withValues(alpha: 0),
          indicatorColor: colors.primaryContainer,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          iconColor: colors.onSurfaceVariant,
          titleTextStyle: textTheme.bodyLarge,
          subtitleTextStyle: textTheme.bodySmall,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: colors.surfaceContainerHigh,
          surfaceTintColor: colors.surfaceTint.withValues(alpha: 0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: BorderSide(color: colors.outlineVariant),
          ),
          titleTextStyle: textTheme.titleLarge,
          contentTextStyle: textTheme.bodyMedium,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: colors.surfaceContainerLow,
          surfaceTintColor: colors.surfaceTint.withValues(alpha: 0),
          showDragHandle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.inverseSurface,
          contentTextStyle: textTheme.bodyMedium?.copyWith(
            color: colors.onInverseSurface,
          ),
          actionTextColor: colors.inversePrimary,
          elevation: 0,
          insetPadding: const EdgeInsets.all(AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: colors.outlineVariant,
          thickness: 1,
          space: 1,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: colors.primary,
          linearTrackColor: colors.primaryContainer,
          circularTrackColor: colors.primaryContainer,
        ),
        tooltipTheme: TooltipThemeData(
          waitDuration: const Duration(milliseconds: 500),
          textStyle: textTheme.bodySmall?.copyWith(
            color: colors.onInverseSurface,
          ),
          decoration: BoxDecoration(
            color: colors.inverseSurface,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: colors.primary,
          selectionColor: colors.primary.withValues(alpha: AppOpacity.muted),
          selectionHandleColor: colors.primary,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          },
        ),
      );
    });
  }

  static TextTheme _textTheme(ColorScheme colors, String fontFamily) {
    TextStyle style({
      required double fontSize,
      required double height,
      required double letterSpacing,
      required FontWeight fontWeight,
      required Color color,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
        color: color,
      );
    }

    return TextTheme(
      displayLarge: style(
        fontSize: 36,
        height: 1.22,
        letterSpacing: -0.8,
        fontWeight: FontWeight.w800,
        color: colors.onSurface,
      ),
      displayMedium: style(
        fontSize: 28,
        height: 1.28,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w800,
        color: colors.onSurface,
      ),
      displaySmall: style(
        fontSize: 28,
        height: 1.28,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      headlineLarge: style(
        fontSize: 28,
        height: 1.28,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w800,
        color: colors.onSurface,
      ),
      headlineMedium: style(
        fontSize: 28,
        height: 1.28,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      headlineSmall: style(
        fontSize: 20,
        height: 1.4,
        letterSpacing: -0.25,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleLarge: style(
        fontSize: 20,
        height: 1.4,
        letterSpacing: -0.25,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      titleMedium: style(
        fontSize: 16,
        height: 1.375,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      titleSmall: style(
        fontSize: 14,
        height: 1.4,
        letterSpacing: 0,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      bodyLarge: style(
        fontSize: 16,
        height: 1.625,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),
      bodyMedium: style(
        fontSize: 14,
        height: 1.57,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: colors.onSurface,
      ),
      bodySmall: style(
        fontSize: 12,
        height: 1.5,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w500,
        color: colors.onSurfaceVariant,
      ),
      labelLarge: style(
        fontSize: 14,
        height: 1.43,
        letterSpacing: 0,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
      labelMedium: style(
        fontSize: 12,
        height: 1.5,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      labelSmall: style(
        fontSize: 12,
        height: 1.5,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w500,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
