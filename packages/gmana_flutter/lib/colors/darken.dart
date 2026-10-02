import 'package:flutter/material.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

/// Returns a darker shade of [color] by lowering HSL lightness by [amount]
/// (clamped to `[0, 1]`).
@Deprecated(
  'Use color.darken(amount) from gmana_flutter_extensions instead. '
  'This duplicate will be removed before 1.0.',
)
Color darken(Color color, [double amount = .1]) {
  return ColorService.adjustLightness(color, amount: amount, darken: true);
}
