import 'package:flutter/material.dart';

/// Extension methods for fluent [TextStyle] styling.
extension TextStyleX on TextStyle {
  /// Returns a copy of this style with bold font weight (`FontWeight.bold`).
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Returns a copy of this style with italic font style (`FontStyle.italic`).
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Returns a copy of this style with underline text decoration.
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// Returns a copy of this style with line-through text decoration.
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// Returns a copy of this style with custom color.
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Returns a copy of this style with custom font size.
  TextStyle withFontSize(double size) => copyWith(fontSize: size);

  /// Returns a copy of this style with custom font weight.
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);

  /// Returns a copy of this style with custom letter spacing.
  TextStyle withLetterSpacing(double spacing) {
    return copyWith(letterSpacing: spacing);
  }
}
