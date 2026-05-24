// ThemeMode extension getters — method names ARE the doc.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../services/theme_mode_service.dart';

extension ThemeModeExt on ThemeMode {
  IconData toIcon() => ThemeModeService.getIcon(this);

  String toKey() => ThemeModeService.getKey(this);

  String toLabel() => ThemeModeService.getLabel(this);
}

extension ThemeModeStringExt on String {
  IconData toThemeIcon() => ThemeModeService.getIconFromKey(this);

  String toThemeLabel() => ThemeModeService.getLabelFromKey(this);

  ThemeMode toThemeMode() => ThemeModeService.fromKey(this);
}