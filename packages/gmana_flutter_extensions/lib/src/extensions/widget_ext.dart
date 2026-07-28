import 'package:flutter/material.dart';

/// Ergonomic layout and composition extension methods on [Widget].
extension WidgetX on Widget {
  /// Wraps this widget in a [Padding] widget with uniform padding.
  Widget paddingAll(double value) {
    return Padding(
      padding: EdgeInsets.all(value),
      child: this,
    );
  }

  /// Wraps this widget in a [Padding] widget with symmetric padding.
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: vertical,
      ),
      child: this,
    );
  }

  /// Wraps this widget in a [Padding] widget with specific edge padding.
  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Wraps this widget in a [Center] widget.
  Widget get centered => Center(child: this);

  /// Wraps this widget in an [Expanded] widget with [flex].
  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);

  /// Wraps this widget in a [Flexible] widget with [flex] and [fit].
  Widget flexible([int flex = 1, FlexFit fit = FlexFit.loose]) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Wraps this widget in a [FittedBox] widget with [fit].
  Widget fitted([BoxFit fit = BoxFit.contain]) {
    return FittedBox(fit: fit, child: this);
  }

  /// Wraps this widget in a [ClipRRect] widget with rounded corners.
  Widget clipped([BorderRadius? radius]) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.zero,
      child: this,
    );
  }

  /// Wraps this widget in a [GestureDetector] with [onTap] callback.
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
}
