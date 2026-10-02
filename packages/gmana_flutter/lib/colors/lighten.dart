import 'package:flutter/material.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

/// Returns a lighter shade of [color] by raising HSL lightness by [amount]
/// (clamped to `[0, 1]`).
Color lighten(Color color, [double amount = .1]) {
  return ColorService.adjustLightness(color, amount: amount, darken: false);
}
