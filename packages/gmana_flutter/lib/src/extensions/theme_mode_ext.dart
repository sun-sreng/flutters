// ThemeMode extension getters — method names ARE the doc.
// ignore_for_file: public_member_api_docs

import 'package:material_ui/material_ui.dart';

import 'theme_modes.dart';

extension StringThemeModeX on String {
  /// Whether this string is one of the known theme keys.
  bool get isThemeKey => ThemeModes.isKnownKey(this);

  /// The next theme key in the cycle.
  String nextThemeKey() => ThemeModes.nextKey(this);

  IconData toThemeIcon() => ThemeModes.getIconFromKey(this);

  String toThemeLabel() => ThemeModes.getLabelFromKey(this);

  ThemeMode toThemeMode() => ThemeModes.fromKey(this);
}

extension ThemeModeX on ThemeMode {
  bool get isDark => this == ThemeMode.dark;

  bool get isLight => this == ThemeMode.light;

  bool get isSystem => this == ThemeMode.system;

  /// The next mode in the system → light → dark cycle.
  ThemeMode next() => ThemeModes.next(this);

  /// Resolves to a concrete [Brightness], consulting [platformBrightness]
  /// only for [ThemeMode.system].
  Brightness resolveBrightness(Brightness platformBrightness) =>
      ThemeModes.resolveBrightness(
        this,
        platformBrightness: platformBrightness,
      );

  IconData toIcon() => ThemeModes.getIcon(this);

  String toKey() => ThemeModes.getKey(this);

  String toLabel() => ThemeModes.getLabel(this);
}
