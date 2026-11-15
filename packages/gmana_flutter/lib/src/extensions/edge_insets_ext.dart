import 'package:material_ui/material_ui.dart';

/// Extension methods for modifying [EdgeInsets].
extension EdgeInsetsX on EdgeInsets {
  /// Total horizontal inset padding (left + right).
  double get horizontalInsets => left + right;

  /// Only the horizontal sides, with top and bottom zeroed.
  EdgeInsets get horizontalOnly => EdgeInsets.only(left: left, right: right);

  /// Whether every side is zero.
  bool get isZero => left == 0 && top == 0 && right == 0 && bottom == 0;

  /// The largest of the four sides.
  double get largestSide =>
      [left, top, right, bottom].reduce((a, b) => a > b ? a : b);

  /// Total vertical inset padding (top + bottom).
  double get verticalInsets => top + bottom;

  /// Only the vertical sides, with left and right zeroed.
  EdgeInsets get verticalOnly => EdgeInsets.only(top: top, bottom: bottom);

  /// Adds [amount] to every side, never dropping below zero.
  EdgeInsets grown(double amount) => EdgeInsets.fromLTRB(
    (left + amount).clamp(0.0, double.infinity),
    (top + amount).clamp(0.0, double.infinity),
    (right + amount).clamp(0.0, double.infinity),
    (bottom + amount).clamp(0.0, double.infinity),
  );

  /// Per-side maximum of this and [other].
  ///
  /// Useful for merging a design padding with a device's safe-area inset
  /// without double-counting either.
  EdgeInsets mergeMax(EdgeInsets other) => EdgeInsets.fromLTRB(
    left > other.left ? left : other.left,
    top > other.top ? top : other.top,
    right > other.right ? right : other.right,
    bottom > other.bottom ? bottom : other.bottom,
  );

  /// Multiplies every side by [factor].
  ///
  /// ```dart
  /// const EdgeInsets.all(8).scaled(1.5); // EdgeInsets.all(12)
  /// ```
  EdgeInsets scaled(double factor) {
    if (factor < 0) {
      throw ArgumentError.value(factor, 'factor', 'must not be negative');
    }

    return EdgeInsets.fromLTRB(
      left * factor,
      top * factor,
      right * factor,
      bottom * factor,
    );
  }

  /// Subtracts [amount] from every side, never dropping below zero.
  EdgeInsets shrunk(double amount) => grown(-amount);

  /// Returns a new [EdgeInsets] with modified bottom padding.
  EdgeInsets withBottom(double bottom) => copyWith(bottom: bottom);

  /// Returns a new [EdgeInsets] with modified left padding.
  EdgeInsets withLeft(double left) => copyWith(left: left);

  /// Returns a new [EdgeInsets] with modified right padding.
  EdgeInsets withRight(double right) => copyWith(right: right);

  /// Returns a new [EdgeInsets] with modified top padding.
  EdgeInsets withTop(double top) => copyWith(top: top);
}
