import 'package:flutter/widgets.dart';

/// Default spacing constants and helper constructors for UI layout systems.
abstract class GSpacing {
  /// The default unit of spacing (16.0).
  static const double spaceUnit = 16;

  /// Extra-extra-extra small spacing (1.0).
  static const double xxxs = 0.0625 * spaceUnit;

  /// Extra-extra small spacing (2.0).
  static const double xxs = 0.125 * spaceUnit;

  /// Extra small spacing (4.0).
  static const double xs = 0.25 * spaceUnit;

  /// Small spacing (8.0).
  static const double sm = 0.5 * spaceUnit;

  /// Medium spacing (12.0).
  static const double md = 0.75 * spaceUnit;

  /// Large spacing (16.0).
  static const double lg = spaceUnit;

  /// Extra large spacing (24.0).
  static const double xlg = 1.5 * spaceUnit;

  /// Extra-extra large spacing (40.0).
  static const double xxlg = 2.5 * spaceUnit;

  /// Extra-extra-extra large spacing (64.0).
  static const double xxxlg = 4 * spaceUnit;

  /// Creates uniform [EdgeInsets] padding of [value] (defaults to [GSpacing.md]).
  static EdgeInsets paddingAll([double value = md]) => EdgeInsets.all(value);

  /// Creates symmetric [EdgeInsets] padding.
  static EdgeInsets paddingSymmetric({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) => EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// Creates horizontal-only [EdgeInsets] padding.
  static EdgeInsets paddingHorizontal([double value = md]) =>
      EdgeInsets.symmetric(horizontal: value);

  /// Creates vertical-only [EdgeInsets] padding.
  static EdgeInsets paddingVertical([double value = md]) =>
      EdgeInsets.symmetric(vertical: value);

  /// Returns a vertical [SizedBox] with height equal to [height] (defaults to [GSpacing.md]).
  static SizedBox vSpace([double height = md]) => SizedBox(height: height);

  /// Returns a horizontal [SizedBox] with width equal to [width] (defaults to [GSpacing.md]).
  static SizedBox hSpace([double width = md]) => SizedBox(width: width);
}
