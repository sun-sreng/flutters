// Thin static utility around dart:ui Color.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

abstract final class ColorService {
  static const double defaultAmount = 0.1;

  static Color adjustLightness(Color color, {required double amount, required bool darken}) {
    _checkUnitInterval(amount, 'amount');
    final hsl = HSLColor.fromColor(color);
    final lightness = darken ? (hsl.lightness - amount).clamp(0.0, 1.0) : (hsl.lightness + amount).clamp(0.0, 1.0);

    return hsl.withLightness(lightness).toColor();
  }

  static Color adjustSaturation(Color color, {required double amount, required bool desaturate}) {
    _checkUnitInterval(amount, 'amount');
    final hsl = HSLColor.fromColor(color);
    final saturation =
        desaturate ? (hsl.saturation - amount).clamp(0.0, 1.0) : (hsl.saturation + amount).clamp(0.0, 1.0);

    return hsl.withSaturation(saturation).toColor();
  }

  /// Returns `2 * count` analogous colors: [count] steps left and right on the hue wheel,
  /// interleaved as [left1, right1, left2, right2, …].
  static List<Color> analogous(Color color, {int count = 2, double spreadDegrees = 30}) {
    if (count < 1) {
      throw ArgumentError.value(count, 'count', 'must be at least 1');
    }

    final hsl = HSLColor.fromColor(color);
    final step = spreadDegrees / count;

    return [
      for (var i = 1; i <= count; i++) ...[
        hsl.withHue((hsl.hue - step * i) % 360).toColor(),
        hsl.withHue((hsl.hue + step * i) % 360).toColor(),
      ],
    ];
  }

  /// Picks whichever candidate has the highest contrast against [background].
  static Color bestContrast(Color background, [List<Color> candidates = const [Colors.white, Colors.black]]) {
    if (candidates.isEmpty) {
      throw ArgumentError.value(candidates, 'candidates', 'must not be empty');
    }

    var best = candidates.first;
    var bestRatio = contrastRatio(best, background);

    for (var i = 1; i < candidates.length; i++) {
      final ratio = contrastRatio(candidates[i], background);
      if (ratio > bestRatio) {
        best = candidates[i];
        bestRatio = ratio;
      }
    }

    return best;
  }

  static Color complementary(Color color) {
    final hsl = HSLColor.fromColor(color);

    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }

  static double contrastRatio(Color a, Color b) {
    final luminanceA = a.computeLuminance() + 0.05;
    final luminanceB = b.computeLuminance() + 0.05;

    return luminanceA > luminanceB ? luminanceA / luminanceB : luminanceB / luminanceA;
  }

  /// Generates a [MaterialColor] swatch relative to the input color's lightness.
  /// Shade 500 is the input color itself; lighter shades approach white, darker shades approach black.
  static MaterialColor createMaterialColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final l = hsl.lightness;

    Color at(double lightness) => hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();

    return MaterialColor(color.toARGB32(), {
      50: at(l + (1.0 - l) * 0.9),
      100: at(l + (1.0 - l) * 0.8),
      200: at(l + (1.0 - l) * 0.6),
      300: at(l + (1.0 - l) * 0.4),
      400: at(l + (1.0 - l) * 0.2),
      500: color,
      600: at(l * 0.9),
      700: at(l * 0.75),
      800: at(l * 0.6),
      900: at(l * 0.4),
    });
  }

  static Color greyscale(Color color) => adjustSaturation(color, amount: 1.0, desaturate: true);

  /// WCAG 2.1 relative luminance. Threshold 0.179 gives 4.5:1 contrast.
  static bool isDark(Color color) => color.computeLuminance() < 0.179;

  static bool isLight(Color color) => !isDark(color);

  static bool meetsWcagAA(Color foreground, Color background) => contrastRatio(foreground, background) >= 4.5;

  static bool meetsWcagAAA(Color foreground, Color background) => contrastRatio(foreground, background) >= 7.0;

  static Color mix(Color a, Color b, [double t = 0.5]) {
    _checkUnitInterval(t, 't');

    return Color.lerp(a, b, t)!;
  }

  /// Mixes [color] with black.
  static Color shade(Color color, [double amount = 0.5]) => mix(color, Colors.black, amount);

  static (Color, Color) splitComplementary(Color color) {
    final hsl = HSLColor.fromColor(color);

    return (hsl.withHue((hsl.hue + 150) % 360).toColor(), hsl.withHue((hsl.hue + 210) % 360).toColor());
  }

  /// Mixes [color] with white.
  static Color tint(Color color, [double amount = 0.5]) => mix(color, Colors.white, amount);

  /// Outputs 8-char ARGB hex including alpha, for example `#CCFF5500`.
  static String toHexARGB(Color color, {bool withHashSign = true}) {
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();

    return withHashSign ? '#$hex' : hex;
  }

  /// Outputs 6-char RGB hex, ignoring alpha, for example `#FF5500`.
  static String toHexRGB(Color color, {bool withHashSign = true}) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    final hex = '$r$g$b'.toUpperCase();

    return withHashSign ? '#$hex' : hex;
  }

  static (Color, Color) triadic(Color color) {
    final hsl = HSLColor.fromColor(color);

    return (hsl.withHue((hsl.hue + 120) % 360).toColor(), hsl.withHue((hsl.hue + 240) % 360).toColor());
  }

  /// Parses `#RGB`, `#RRGGBB`, or `#AARRGGBB`, with optional hash prefix.
  static Color? tryParseHex(String hex) {
    final clean = hex.startsWith('#') ? hex.substring(1) : hex;

    final int? value = switch (clean.length) {
      3 => int.tryParse('FF${clean[0] * 2}${clean[1] * 2}${clean[2] * 2}', radix: 16),
      6 => int.tryParse('FF$clean', radix: 16),
      8 => int.tryParse(clean, radix: 16),
      _ => null,
    };

    return value != null ? Color(value) : null;
  }

  static void _checkUnitInterval(double value, String name) {
    if (value.isNaN || value < 0 || value > 1) {
      throw ArgumentError.value(value, name, 'must be between 0 and 1');
    }
  }
}