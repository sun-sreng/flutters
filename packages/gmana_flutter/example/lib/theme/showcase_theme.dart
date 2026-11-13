import 'package:gmana_flutter/gmana_flutter.dart';
import 'package:material_ui/material_ui.dart';

ThemeData buildShowcaseTheme(Brightness brightness) {
  final baseTheme =
      brightness == Brightness.dark ? GColors.darkTheme : GColors.lightTheme;
  final colorScheme = baseTheme.colorScheme;
  final isDark = brightness == Brightness.dark;

  return baseTheme.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface.withAlpha(isDark ? 230 : 245),
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outline.withAlpha(60)),
      ),
    ),
    chipTheme: baseTheme.chipTheme.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      side: BorderSide(color: colorScheme.outline.withAlpha(50)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline.withAlpha(90)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF101113) : const Color(0xFFF7F3EE),
    textTheme: baseTheme.textTheme.copyWith(
      displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
      headlineSmall: baseTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(height: 1.5),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(height: 1.45),
    ),
  );
}
