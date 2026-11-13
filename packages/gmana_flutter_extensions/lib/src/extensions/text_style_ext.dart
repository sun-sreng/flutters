import 'package:material_ui/material_ui.dart';

/// Fluent styling on a nullable [TextStyle], for `Theme.of(context).textTheme`
/// slots, which are all nullable.
///
/// ```dart
/// context.textTheme.titleMedium.orDefault.semiBold
/// ```
extension TextStyleNullableX on TextStyle? {
  /// This style, or an empty [TextStyle] when null.
  TextStyle get orDefault => this ?? const TextStyle();

  /// Applies [transform] only when this style is non-null.
  TextStyle? map(TextStyle Function(TextStyle style) transform) {
    final style = this;
    return style == null ? null : transform(style);
  }
}

/// Extension methods for fluent [TextStyle] styling.
extension TextStyleX on TextStyle {
  /// `FontWeight.w900`.
  TextStyle get black => copyWith(fontWeight: FontWeight.w900);

  /// Returns a copy of this style with bold font weight (`FontWeight.bold`).
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Returns a copy of this style with italic font style (`FontStyle.italic`).
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// `FontWeight.w300`.
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Returns a copy of this style with line-through text decoration.
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// `FontWeight.w500`.
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Removes any text decoration.
  TextStyle get noDecoration => copyWith(decoration: TextDecoration.none);

  /// `FontWeight.w400`.
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  // --- Named weights ---

  /// `FontWeight.w600`.
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Returns a copy of this style with underline text decoration.
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// Multiplies the current [fontSize] by [factor].
  ///
  /// A style with no explicit size is returned unchanged, since there is
  /// nothing to scale — the size is inherited at paint time.
  TextStyle scaled(double factor) {
    if (factor < 0) {
      throw ArgumentError.value(factor, 'factor', 'must not be negative');
    }

    final size = fontSize;
    return size == null ? this : copyWith(fontSize: size * factor);
  }

  /// Returns a copy whose color carries [opacity].
  ///
  /// Falls back to opaque black when the style has no color yet, so the
  /// result is always visible rather than silently unstyled.
  TextStyle withAlphaOpacity(double opacity) {
    if (opacity.isNaN || opacity < 0 || opacity > 1) {
      throw ArgumentError.value(opacity, 'opacity', 'must be between 0 and 1');
    }

    return copyWith(
      color: (color ?? const Color(0xFF000000)).withValues(alpha: opacity),
    );
  }

  /// Returns a copy of this style with custom color.
  TextStyle withColor(Color color) => copyWith(color: color);

  // --- Decoration ---

  /// Applies a custom [decoration], optionally styling it.
  TextStyle withDecoration(
    TextDecoration decoration, {
    Color? color,
    TextDecorationStyle? style,
    double? thickness,
  }) => copyWith(
    decoration: decoration,
    decorationColor: color,
    decorationStyle: style,
    decorationThickness: thickness,
  );

  /// Returns a copy with the given font family.
  TextStyle withFamily(String family) => copyWith(fontFamily: family);

  // --- Metrics ---

  /// Returns a copy of this style with custom font size.
  TextStyle withFontSize(double size) => copyWith(fontSize: size);

  /// Returns a copy with the given line height multiplier.
  TextStyle withHeight(double height) => copyWith(height: height);

  /// Returns a copy of this style with custom letter spacing.
  TextStyle withLetterSpacing(double spacing) {
    return copyWith(letterSpacing: spacing);
  }

  /// Returns a copy with a single drop shadow.
  TextStyle withShadow({
    Color color = const Color(0x66000000),
    Offset offset = const Offset(0, 1),
    double blurRadius = 2,
  }) => copyWith(
    shadows: [Shadow(color: color, offset: offset, blurRadius: blurRadius)],
  );

  /// Returns a copy of this style with custom font weight.
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);

  /// Returns a copy with the given word spacing.
  TextStyle withWordSpacing(double spacing) => copyWith(wordSpacing: spacing);
}
