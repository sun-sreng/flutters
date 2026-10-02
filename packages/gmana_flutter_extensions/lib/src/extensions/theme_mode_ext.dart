// ThemeMode extension getters — method names ARE the doc.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../theme_modes.dart';

extension ThemeModeX on ThemeMode {
  IconData toIcon() => ThemeModes.getIcon(this);

  String toKey() => ThemeModes.getKey(this);

  String toLabel() => ThemeModes.getLabel(this);

  /// The next mode in the system → light → dark cycle.
  ThemeMode next() => ThemeModes.next(this);

  bool get isSystem => this == ThemeMode.system;

  bool get isLight => this == ThemeMode.light;

  bool get isDark => this == ThemeMode.dark;

  /// Resolves to a concrete [Brightness], consulting [platformBrightness]
  /// only for [ThemeMode.system].
  Brightness resolveBrightness(Brightness platformBrightness) =>
      ThemeModes.resolveBrightness(
        this,
        platformBrightness: platformBrightness,
      );
}

extension StringThemeModeX on String {
  IconData toThemeIcon() => ThemeModes.getIconFromKey(this);

  String toThemeLabel() => ThemeModes.getLabelFromKey(this);

  ThemeMode toThemeMode() => ThemeModes.fromKey(this);

  /// The next theme key in the cycle.
  String nextThemeKey() => ThemeModes.nextKey(this);

  /// Whether this string is one of the known theme keys.
  bool get isThemeKey => ThemeModes.isKnownKey(this);
}
