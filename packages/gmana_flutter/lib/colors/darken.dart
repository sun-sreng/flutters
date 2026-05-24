import 'package:flutter/material.dart';

/// Returns a darker shade of [color] by lowering HSL lightness by [amount]
/// (clamped to `[0, 1]`).
Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}
