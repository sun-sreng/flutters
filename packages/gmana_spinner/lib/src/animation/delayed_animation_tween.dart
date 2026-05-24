import 'dart:math' show sin, pi;

import 'package:flutter/material.dart';

/// A tween that applies a delay to a repeating staggered animation.
class DelayedAnimationTween extends Tween<double> {
  /// Phase delay applied before transforming the animation value.
  final double delay;

  /// Curve applied after the delayed sine wave transform.
  final Curve curve;

  /// Creates a tween that phase-shifts the parent animation by [delay].
  DelayedAnimationTween({
    super.begin = 0.0,
    super.end = 1.0,
    required this.delay,
    this.curve = Curves.easeInOut,
  });

  @override
  double lerp(double t) {
    final adjustedT = (sin((t - delay) * 2 * pi) + 1) / 2;
    return super.lerp(curve.transform(adjustedT));
  }
}
