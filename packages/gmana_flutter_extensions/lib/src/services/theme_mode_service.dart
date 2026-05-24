// Thin static utility around ThemeMode.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

abstract final class ThemeModeService {
  static const Map<ThemeMode, _ThemeModeConfig> _configs = {
    ThemeMode.system: _ThemeModeConfig(key: 'system', label: 'System Mode', icon: Icons.brightness_6),
    ThemeMode.light: _ThemeModeConfig(key: 'light', label: 'Light Mode', icon: Icons.light_mode),
    ThemeMode.dark: _ThemeModeConfig(key: 'dark', label: 'Dark Mode', icon: Icons.dark_mode),
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
}

class _ThemeModeConfig {
  final String key;
  final String label;
  final IconData icon;

  const _ThemeModeConfig({required this.key, required this.label, required this.icon});
}