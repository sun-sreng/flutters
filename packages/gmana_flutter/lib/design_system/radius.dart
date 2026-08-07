import 'package:flutter/widgets.dart';

/// Corner-radius tokens and [BorderRadius] helpers.
///
/// Pairs with `GSpacing` so widgets stop hard-coding literal radii.
abstract final class GRadius {
  /// No rounding (0.0).
  static const double none = 0;

  /// Extra small radius (4.0) — chips, badges, tags.
  static const double xs = 4;

  /// Small radius (8.0) — buttons and inputs.
  static const double sm = 8;

  /// Medium radius (12.0) — cards and tiles.
  static const double md = 12;

  /// Large radius (16.0) — sheets and dialogs.
  static const double lg = 16;

  /// Extra large radius (24.0) — hero surfaces.
  static const double xl = 24;

  /// Effectively fully rounded (999.0) — pills and circular avatars.
  static const double pill = 999;

  /// Uniform [BorderRadius] of [value] (defaults to [GRadius.md]).
  static BorderRadius all([double value = md]) => BorderRadius.circular(value);

  /// [BorderRadius] applied to the top corners only.
  static BorderRadius top([double value = md]) =>
      BorderRadius.vertical(top: Radius.circular(value));

  /// [BorderRadius] applied to the bottom corners only.
  static BorderRadius bottom([double value = md]) =>
      BorderRadius.vertical(bottom: Radius.circular(value));

  /// [BorderRadius] applied to the leading corners only, honouring text
  /// direction when resolved.
  static BorderRadiusDirectional start([double value = md]) =>
      BorderRadiusDirectional.horizontal(start: Radius.circular(value));

  /// [BorderRadius] applied to the trailing corners only, honouring text
  /// direction when resolved.
  static BorderRadiusDirectional end([double value = md]) =>
      BorderRadiusDirectional.horizontal(end: Radius.circular(value));

  /// A [RoundedRectangleBorder] with uniform radius [value].
  static RoundedRectangleBorder shape([double value = md]) =>
      RoundedRectangleBorder(borderRadius: all(value));

  /// A [RoundedRectangleBorder] with uniform radius [value] and a [side].
  static RoundedRectangleBorder outlinedShape(
    BorderSide side, [
    double value = md,
  ]) => RoundedRectangleBorder(borderRadius: all(value), side: side);
}
