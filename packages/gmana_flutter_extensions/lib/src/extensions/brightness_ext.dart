import 'package:flutter/material.dart';

/// Readability helpers on [Brightness].
extension BrightnessX on Brightness {
  /// Whether this is [Brightness.dark].
  bool get isDark => this == Brightness.dark;

  /// Whether this is [Brightness.light].
  bool get isLight => this == Brightness.light;

  /// The other brightness.
  Brightness get opposite => isDark ? Brightness.light : Brightness.dark;

  /// Returns [dark] when this is dark, otherwise [light].
  ///
  /// ```dart
  /// final border = brightness.select(light: Colors.black12, dark: Colors.white24);
  /// ```
  T select<T>({required T light, required T dark}) => isDark ? dark : light;
}

/// Brightness shortcuts on [ThemeData].
extension ThemeDataX on ThemeData {
  /// Whether this theme is dark.
  bool get isDark => brightness.isDark;

  /// Whether this theme is light.
  bool get isLight => brightness.isLight;

  /// Returns [dark] when the theme is dark, otherwise [light].
  T select<T>({required T light, required T dark}) =>
      brightness.select(light: light, dark: dark);
}
