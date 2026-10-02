import 'package:flutter/material.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

/// Returns a lighter shade of [color] by raising HSL lightness by [amount]
/// (clamped to `[0, 1]`).
@Deprecated(
  'Use color.lighten(amount) from gmana_flutter_extensions instead. '
  'This duplicate will be removed before 1.0.',
)
Color lighten(Color color, [double amount = .1]) {
  return ColorMath.adjustLightness(color, amount: amount, darken: false);
}
