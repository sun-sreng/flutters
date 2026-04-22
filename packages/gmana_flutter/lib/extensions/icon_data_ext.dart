import 'dart:convert';

import 'package:flutter/material.dart';

/// Scoped parser — avoids polluting all [String] instances with icon logic.
abstract final class IconDataExt {
  /// Returns [fallback] (default: [Icons.question_mark]) on any parse failure.
  static IconData parse(
    String source, {
    IconData fallback = Icons.question_mark,
  }) => tryParse(source) ?? fallback;

  /// Returns `null` if [source] is empty, not valid JSON, or missing [codePoint].
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
  /// True when this icon round-trips correctly through [toJsonString].
  bool get isSerializable => IconDataExt.tryParse(toJsonString()) != null;

  /// Serializes to a JSON string. Round-trips losslessly with [IconDataExt.tryParse].
  String toJsonString() => jsonEncode({
    'codePoint': codePoint,
    'fontFamily': fontFamily,
    'fontPackage': fontPackage,
    'matchTextDirection': matchTextDirection,
  });
}
