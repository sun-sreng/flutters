// ThemeMode extension getters — method names ARE the doc.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../services/theme_mode_service.dart';

extension ThemeModeExt on ThemeMode {
  IconData toIcon() => ThemeModeService.getIcon(this);

  String toKey() => ThemeModeService.getKey(this);

  String toLabel() => ThemeModeService.getLabel(this);

  /// The next mode in the system → light → dark cycle.
  ThemeMode next() => ThemeModeService.next(this);

  bool get isSystem => this == ThemeMode.system;

  bool get isLight => this == ThemeMode.light;

  bool get isDark => this == ThemeMode.dark;

  /// Resolves to a concrete [Brightness], consulting [platformBrightness]
  /// only for [ThemeMode.system].
  Brightness resolveBrightness(Brightness platformBrightness) =>
      ThemeModeService.resolveBrightness(
        this,
        platformBrightness: platformBrightness,
      );
}

extension ThemeModeStringExt on String {
  IconData toThemeIcon() => ThemeModeService.getIconFromKey(this);

  String toThemeLabel() => ThemeModeService.getLabelFromKey(this);

  ThemeMode toThemeMode() => ThemeModeService.fromKey(this);

  /// The next theme key in the cycle.
  String nextThemeKey() => ThemeModeService.nextKey(this);

  /// Whether this string is one of the known theme keys.
  bool get isThemeKey => ThemeModeService.isKnownKey(this);
}
