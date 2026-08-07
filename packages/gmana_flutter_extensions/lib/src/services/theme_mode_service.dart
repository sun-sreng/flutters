// Thin static utility around ThemeMode.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

abstract final class ThemeModeService {
  static const Map<ThemeMode, _ThemeModeConfig> _configs = {
    ThemeMode.system: _ThemeModeConfig(
      key: 'system',
      label: 'System Mode',
      icon: Icons.brightness_6,
    ),
    ThemeMode.light: _ThemeModeConfig(
      key: 'light',
      label: 'Light Mode',
      icon: Icons.light_mode,
    ),
    ThemeMode.dark: _ThemeModeConfig(
      key: 'dark',
      label: 'Dark Mode',
      icon: Icons.dark_mode,
    ),
  };

  static const Map<String, ThemeMode> _keyMap = {
    'system': ThemeMode.system,
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
  };

  static ThemeMode fromKey(String key) => _keyMap[key] ?? ThemeMode.system;

  static IconData getIcon(ThemeMode mode) => _configs[mode]!.icon;

  static IconData getIconFromKey(String key) => _configs[fromKey(key)]!.icon;

  static String getKey(ThemeMode mode) => _configs[mode]!.key;

  static String getLabel(ThemeMode mode) => _configs[mode]!.label;

  static String getLabelFromKey(String key) => _configs[fromKey(key)]!.label;

  static List<String> getThemeKeys() => _keyMap.keys.toList();

  /// All modes in presentation order: system, light, dark.
  static List<ThemeMode> get all => _configs.keys.toList();

  /// The next mode in the cycle, wrapping back to the first.
  ///
  /// This is what a single "toggle theme" button needs — Flutter's
  /// [ThemeMode] has three values, so a boolean flip cannot express it.
  static ThemeMode next(ThemeMode mode) {
    final modes = all;
    final index = modes.indexOf(mode);

    return modes[(index + 1) % modes.length];
  }

  /// The next mode's key, wrapping back to the first.
  static String nextKey(String key) => getKey(next(fromKey(key)));

  /// Whether [key] maps to a known mode rather than falling back to system.
  static bool isKnownKey(String key) => _keyMap.containsKey(key);

  /// Resolves [mode] to a concrete [Brightness], consulting [platformBrightness]
  /// only for [ThemeMode.system].
  static Brightness resolveBrightness(
    ThemeMode mode, {
    required Brightness platformBrightness,
  }) => switch (mode) {
    ThemeMode.system => platformBrightness,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };
}

class _ThemeModeConfig {
  final String key;
  final String label;
  final IconData icon;

  const _ThemeModeConfig({
    required this.key,
    required this.label,
    required this.icon,
  });
}
