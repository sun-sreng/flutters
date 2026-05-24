import 'package:flutter/material.dart';

/// Returns a lighter shade of [color] by raising HSL lightness by [amount]
/// (clamped to `[0, 1]`).
Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
