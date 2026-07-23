// Extension on IconData.
// ignore_for_file: public_member_api_docs

// IconData parses runtime values from JSON; tree-shaking does not apply here.
// ignore_for_file: non_const_argument_for_const_parameter

import 'dart:convert';

import 'package:flutter/material.dart';

/// Scoped parser that avoids adding icon parsing behavior to every [String].
abstract final class IconDataExt {
  /// Returns [fallback] on any parse failure.
  static IconData parse(
    String source, {
    IconData fallback = Icons.question_mark,
  }) => tryParse(source) ?? fallback;

  /// Returns `null` if [source] is empty, not valid JSON, or missing code point.
  static IconData? tryParse(String source) {
    if (source.isEmpty) return null;

    try {
      final map = jsonDecode(source);
      if (map is! Map<String, dynamic>) return null;

      final codePoint = map['codePoint'];
      if (codePoint is! int) return null;

      return IconData(
        codePoint,
        fontFamily: map['fontFamily'] as String?,
        fontPackage: map['fontPackage'] as String?,
        matchTextDirection: map['matchTextDirection'] as bool? ?? false,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}

extension IconDataSerialization on IconData {
  /// Serializes to a compact JSON string; null and default fields are omitted.
  String toJsonString() {
    final map = <String, dynamic>{'codePoint': codePoint};
    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (fontPackage != null) map['fontPackage'] = fontPackage;
    if (matchTextDirection) map['matchTextDirection'] = true;
    return jsonEncode(map);
  }
}
