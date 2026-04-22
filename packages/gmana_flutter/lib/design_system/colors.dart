import 'package:flutter/material.dart';

/// Brand color palette and theme factory.
///
/// Utility methods (hex parsing, opacity) are intentionally omitted here —
/// use [ColorService] and [ColorExt] instead.
abstract final class GColors {
  // ── Brand ──────────────────────────────────────────────────────────────

  static const Color primary = Color(0xFFF57224);
  static const Color primaryDark = Color(0xFFBE3C10); // shade700
  static const Color primaryLight = Color(0xFFFAB577); // shade300

  static const MaterialColor primarySwatch =
      MaterialColor(0xFFF57224, <int, Color>{
        50: Color(0xFFFFF6ED),
        100: Color(0xFFFEECD6),
        200: Color(0xFFFCD4AC),
        300: Color(0xFFFAB577),
        400: Color(0xFFF78B40),
        500: Color(0xFFF57224),
        600: Color(0xFFE65110),
        700: Color(0xFFBE3C10),
        800: Color(0xFF973015),
        900: Color(0xFF7A2A14),
      });

  // ── Semantic ───────────────────────────────────────────────────────────

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color success = Color(0xFF386A20);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFB7F397);
  static const Color onSuccessContainer = Color(0xFF042100);

  static const Color warning = Color(0xFF7C5800);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFDEAA);
  static const Color onWarningContainer = Color(0xFF271900);

  static const Color info = Color(0xFF00639B);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCDE5FF);
  static const Color onInfoContainer = Color(0xFF001E30);

  // ── Neutral (light) ────────────────────────────────────────────────────

  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color surface = Color(0xFFF8F8F8);
  static const Color onSurface = Color(0xFF212121);
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFBDBDBD);

  // ── Neutral (dark) ─────────────────────────────────────────────────────

  static const Color backgroundDark = Color(0xFF121212);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);
  static const Color onSurfaceVariantDark = Color(0xFFBDBDBD);
  static const Color outlineDark = Color(0xFF424242);
  static const Color outlineVariantDark = Color(0xFF616161);

  // ── Overlay / misc ─────────────────────────────────────────────────────

  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  static ThemeData get darkTheme => _buildTheme(brightness: Brightness.dark);
  // ── Themes ─────────────────────────────────────────────────────────────

  static ThemeData get lightTheme => _buildTheme(brightness: Brightness.light);

  static TextTheme _buildTextTheme(bool isDark) {
    final primary = isDark ? onBackgroundDark : onBackground;
    final secondary = isDark ? onSurfaceVariantDark : onSurfaceVariant;

    return TextTheme(
      displayLarge: TextStyle(color: primary),
      displayMedium: TextStyle(color: primary),
      displaySmall: TextStyle(color: primary),
      headlineLarge: TextStyle(color: primary),
      headlineMedium: TextStyle(color: primary),
      headlineSmall: TextStyle(color: primary),
      titleLarge: TextStyle(color: primary),
      titleMedium: TextStyle(color: primary),
      titleSmall: TextStyle(color: secondary),
      bodyLarge: TextStyle(color: primary),
      bodyMedium: TextStyle(color: primary),
      bodySmall: TextStyle(color: secondary),
      labelLarge: TextStyle(color: primary),
      labelMedium: TextStyle(color: secondary),
      labelSmall: TextStyle(color: secondary),
    );
  }

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final colorScheme =
        isDark
            ? ColorScheme.dark(
              primary: primary,
              onPrimary: Colors.white,
              primaryContainer: primaryDark,
              onPrimaryContainer: Colors.white,
              secondary: primaryLight,
              onSecondary: Colors.black,
              error: error,
              onError: onError,
              surface: surfaceDark,
              onSurface: onSurfaceDark,
              surfaceContainerHighest: surfaceVariantDark,
              onSurfaceVariant: onSurfaceVariantDark,
              outline: outlineDark,
              outlineVariant: outlineVariantDark,
            )
            : ColorScheme.light(
              primary: primary,
              onPrimary: Colors.white,
              primaryContainer: primaryLight,
              onPrimaryContainer: Colors.black,
              secondary: primaryDark,
              onSecondary: Colors.white,
              error: error,
              onError: onError,
              surface: surface,
              onSurface: onSurface,
              surfaceContainerHighest: surfaceVariant,
              onSurfaceVariant: onSurfaceVariant,
              outline: outline,
              outlineVariant: outlineVariant,
            );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? backgroundDark : background,
      dividerColor: isDark ? outlineDark : outline,
      disabledColor: isDark ? outlineVariantDark : outlineVariant,
      textTheme: _buildTextTheme(isDark),
    );
  }
}
