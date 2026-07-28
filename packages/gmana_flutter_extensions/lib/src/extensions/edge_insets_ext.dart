import 'package:flutter/material.dart';

/// Extension methods for modifying [EdgeInsets].
extension EdgeInsetsX on EdgeInsets {
  /// Returns a new [EdgeInsets] with modified top padding.
  EdgeInsets withTop(double top) => copyWith(top: top);

  /// Returns a new [EdgeInsets] with modified bottom padding.
  EdgeInsets withBottom(double bottom) => copyWith(bottom: bottom);

  /// Returns a new [EdgeInsets] with modified left padding.
  EdgeInsets withLeft(double left) => copyWith(left: left);

  /// Returns a new [EdgeInsets] with modified right padding.
  EdgeInsets withRight(double right) => copyWith(right: right);

  /// Total horizontal inset padding (left + right).
  double get horizontalInsets => left + right;

  /// Total vertical inset padding (top + bottom).
  double get verticalInsets => top + bottom;
}
