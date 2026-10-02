// Color extension getters — method names ARE the doc.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../color_math.dart';

extension ColorX on Color {
  Color get complementary => ColorMath.complementary(this);

  /// Picks the highest-contrast color from [candidates] (defaults to white/black).
  Color bestContrast([
    List<Color> candidates = const [Colors.white, Colors.black],
  ]) => ColorMath.bestContrast(this, candidates);

  Color get contrastText => bestContrast();

  Color get greyscale => ColorMath.greyscale(this);

  bool get isDark => ColorMath.isDark(this);

  bool get isLight => ColorMath.isLight(this);

  (Color, Color) get splitComplementary => ColorMath.splitComplementary(this);

  (Color, Color) get triadic => ColorMath.triadic(this);

  (Color, Color, Color) get tetradic => ColorMath.tetradic(this);

  /// A same-hue lightness ramp. See [ColorMath.monochromatic].
  List<Color> monochromatic({int count = 5}) =>
      ColorMath.monochromatic(this, count: count);

  // --- HSL accessors ---

  /// Hue in degrees, `0` to `360`.
  double get hue => HSLColor.fromColor(this).hue;

  /// Saturation in `[0, 1]`.
  double get saturation => HSLColor.fromColor(this).saturation;

  /// Lightness in `[0, 1]`.
  double get lightness => HSLColor.fromColor(this).lightness;

  /// Returns this color with its hue replaced. Wraps values outside 0–360.
  Color withHue(double value) =>
      HSLColor.fromColor(this).withHue(value % 360).toColor();

  /// Returns this color with its saturation replaced, clamped to `[0, 1]`.
  Color withSaturation(double value) =>
      HSLColor.fromColor(this).withSaturation(value.clamp(0.0, 1.0)).toColor();

  /// Returns this color with its lightness replaced, clamped to `[0, 1]`.
  Color withLightness(double value) =>
      HSLColor.fromColor(this).withLightness(value.clamp(0.0, 1.0)).toColor();

  // --- Alpha ---

  /// Whether this color is fully transparent.
  bool get isTransparent => a == 0;

  /// Whether this color is fully opaque.
  bool get isOpaque => a == 1;

  /// This color at full opacity.
  Color get opaque => withValues(alpha: 1);

  /// CSS `rgba(...)` notation.
  String toCssRgba({int alphaPrecision = 2}) =>
      ColorMath.toCssRgba(this, alphaPrecision: alphaPrecision);

  /// Returns `2 * count` analogous colors: [count] steps to the left and [count] to the right
  /// of this color on the hue wheel, interleaved as [left1, right1, left2, right2, …].
  List<Color> analogous({int count = 2, double spreadDegrees = 30}) =>
      ColorMath.analogous(this, count: count, spreadDegrees: spreadDegrees);

  double contrastRatio(Color other) => ColorMath.contrastRatio(this, other);

  Color darken([double amount = ColorMath.defaultAmount]) =>
      ColorMath.adjustLightness(this, amount: amount, darken: true);

  Color desaturate([double amount = ColorMath.defaultAmount]) =>
      ColorMath.adjustSaturation(this, amount: amount, desaturate: true);

  Color lighten([double amount = ColorMath.defaultAmount]) =>
      ColorMath.adjustLightness(this, amount: amount, darken: false);

  bool meetsWcagAA(Color background) => ColorMath.meetsWcagAA(this, background);

  bool meetsWcagAAA(Color background) =>
      ColorMath.meetsWcagAAA(this, background);

  /// Linearly interpolates toward [other]. `t = 0` returns this color; `t = 1` returns [other].
  Color mix(Color other, [double t = 0.5]) => ColorMath.mix(this, other, t);

  Color saturate([double amount = ColorMath.defaultAmount]) =>
      ColorMath.adjustSaturation(this, amount: amount, desaturate: false);

  Color shade([double amount = 0.5]) => ColorMath.shade(this, amount);

  Color tint([double amount = 0.5]) => ColorMath.tint(this, amount);

  /// 8-char ARGB: `#CCFF5500`.
  String toHexARGB({bool withHashSign = true}) =>
      ColorMath.toHexARGB(this, withHashSign: withHashSign);

  /// 6-char RGB: `#FF5500`.
  String toHexRGB({bool withHashSign = true}) =>
      ColorMath.toHexRGB(this, withHashSign: withHashSign);

  MaterialColor toMaterialColor() => ColorMath.createMaterialColor(this);

  Color withAlphaOpacity(double opacity) {
    if (opacity.isNaN || opacity < 0 || opacity > 1) {
      throw ArgumentError.value(opacity, 'opacity', 'must be between 0 and 1');
    }

    return withAlpha((opacity * 255).round());
  }
}
