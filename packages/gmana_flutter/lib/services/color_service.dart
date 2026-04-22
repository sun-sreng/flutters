// color_service.dart
import 'package:flutter/material.dart';

abstract final class ColorService {
  static const double defaultAmount = 0.1;

  // ── Lightness ──────────────────────────────────────────────────────────

  static Color adjustLightness(
    Color color, {
    required double amount,
    required bool darken,
  }) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final l =
        darken
            ? (hsl.lightness - amount).clamp(0.0, 1.0)
            : (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  // ── Saturation ─────────────────────────────────────────────────────────

  static Color adjustSaturation(
    Color color, {
    required double amount,
    required bool desaturate,
  }) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final s =
        desaturate
            ? (hsl.saturation - amount).clamp(0.0, 1.0)
            : (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(s).toColor();
  }

  /// Returns [count] analogous colors evenly spaced around [color].
  /// [spreadDegrees] controls the total arc (default 30° each side).
  static List<Color> analogous(
    Color color, {
    int count = 2,
    double spreadDegrees = 30,
  }) {
    assert(count >= 1);
    final hsl = HSLColor.fromColor(color);
    final step = spreadDegrees / count;
    return [
      for (var i = 1; i <= count; i++) ...[
        hsl.withHue((hsl.hue - step * i) % 360).toColor(),
        hsl.withHue((hsl.hue + step * i) % 360).toColor(),
      ],
    ];
  }

  // ── Mixing ─────────────────────────────────────────────────────────────

  /// Picks whichever of [candidates] has the highest contrast against [background].
  /// Defaults to black/white if no candidates supplied.
  static Color bestContrast(
    Color background, [
    List<Color> candidates = const [Colors.white, Colors.black],
  ]) {
    assert(candidates.isNotEmpty);
    return candidates.reduce(
      (best, c) =>
          contrastRatio(c, background) > contrastRatio(best, background)
              ? c
              : best,
    );
  }

  /// Returns the complementary color (hue + 180°).
  static Color complementary(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }

  /// Returns the WCAG contrast ratio between two colors (1–21).
  static double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance() + 0.05;
    final lb = b.computeLuminance() + 0.05;
    return la > lb ? la / lb : lb / la;
  }

  // ── Harmony ────────────────────────────────────────────────────────────

  /// Generates a [MaterialColor] swatch using HSL lightness steps so shades
  /// match Material Design intent rather than raw RGB blending.
  static MaterialColor createMaterialColor(Color color) {
    final hsl = HSLColor.fromColor(color);

    // Material shade → target lightness mapping (approximates the spec).
    const shadeMap = {
      50: 0.95,
      100: 0.90,
      200: 0.80,
      300: 0.70,
      400: 0.60,
      500: 0.50,
      600: 0.40,
      700: 0.30,
      800: 0.20,
      900: 0.10,
    };

    final swatch = {
      for (final entry in shadeMap.entries)
        entry.key: hsl.withLightness(entry.value).toColor(),
    };

    return MaterialColor(color.toARGB32(), swatch);
  }

  /// Removes all saturation — equivalent to a greyscale conversion.
  static Color greyscale(Color color) =>
      adjustSaturation(color, amount: 1.0, desaturate: true);

  /// WCAG 2.1 relative luminance. Threshold 0.179 gives 4.5:1 contrast ratio.
  static bool isDark(Color color) => color.computeLuminance() < 0.179;

  static bool isLight(Color color) => !isDark(color);

  // ── Contrast / Accessibility ───────────────────────────────────────────

  /// AA = 4.5:1 for normal text, AAA = 7:1.
  static bool meetsWcagAA(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= 4.5;
  static bool meetsWcagAAA(Color foreground, Color background) =>
      contrastRatio(foreground, background) >= 7.0;

  /// Linear interpolation between [a] and [b] in sRGB space.
  /// [t] = 0.0 → [a], [t] = 1.0 → [b].
  static Color mix(Color a, Color b, [double t = 0.5]) {
    assert(t >= 0 && t <= 1);
    return Color.lerp(a, b, t)!;
  }

  /// Mixes [color] with black.
  static Color shade(Color color, [double amount = 0.5]) =>
      mix(color, const Color(0xFF000000), amount);

  /// Returns a split-complementary palette (hue + 150° and hue + 210°).
  static (Color, Color) splitComplementary(Color color) {
    final hsl = HSLColor.fromColor(color);
    return (
      hsl.withHue((hsl.hue + 150) % 360).toColor(),
      hsl.withHue((hsl.hue + 210) % 360).toColor(),
    );
  }

  /// Mixes [color] with white.
  static Color tint(Color color, [double amount = 0.5]) =>
      mix(color, const Color(0xFFFFFFFF), amount);

  // ── Serialization ──────────────────────────────────────────────────────

  /// Outputs 8-char ARGB hex including alpha: `#CCFF5500`.
  static String toHexARGB(Color color, {bool withHashSign = true}) {
    final hex =
        color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return withHashSign ? '#$hex' : hex;
  }

  /// Outputs 6-char RGB hex, ignoring alpha: `#FF5500`.
  static String toHexRGB(Color color, {bool withHashSign = true}) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    final hex = '$r$g$b'.toUpperCase();
    return withHashSign ? '#$hex' : hex;
  }

  /// Returns a triadic palette (hue ± 120°).
  static (Color, Color) triadic(Color color) {
    final hsl = HSLColor.fromColor(color);
    return (
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    );
  }

  // ── Material swatch ────────────────────────────────────────────────────

  /// Parses `#RGB`, `#RRGGBB`, `#AARRGGBB` (hash optional).
  static Color? tryParseHex(String hex) {
    final clean = hex.startsWith('#') ? hex.substring(1) : hex;
    return switch (clean.length) {
      3 => () {
        final r = clean[0] * 2;
        final g = clean[1] * 2;
        final b = clean[2] * 2;
        final value = int.tryParse('FF$r$g$b', radix: 16);
        return value != null ? Color(value) : null;
      }(),
      6 => () {
        final value = int.tryParse('FF$clean', radix: 16);
        return value != null ? Color(value) : null;
      }(),
      8 => () {
        final value = int.tryParse(clean, radix: 16);
        return value != null ? Color(value) : null;
      }(),
      _ => null,
    };
  }
}
