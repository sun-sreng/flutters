import 'package:flutter/material.dart';

/// Configuration for animating a single dot in the GSpinnerWaveDot widget.
class DotAnimationConfig {
  final Interval heightInterval;
  final Interval offsetInterval;
  final Interval reverseHeightInterval;
  final Interval reverseOffsetInterval;
  final double maxHeight;
  final double maxOffset;

  const DotAnimationConfig({
    required this.heightInterval,
    required this.offsetInterval,
    required this.reverseHeightInterval,
    required this.reverseOffsetInterval,
    required this.maxHeight,
    required this.maxOffset,
  });

  /// Creates a config for a dot based on its index and total dot count.
  factory DotAnimationConfig.forIndex({
    required int index,
    required int dotCount,
    required double baseSize,
    required bool isEven,
  }) {
    final step = 0.09; // Interval step for staggering animations
    final start = index * step;
    return DotAnimationConfig(
      heightInterval: Interval(start, start + step),
      offsetInterval: Interval(start + step, start + 2 * step),
      reverseHeightInterval: Interval(start + 2 * step, start + 3 * step),
      reverseOffsetInterval: Interval(start + 3 * step, start + 4 * step),
      maxHeight: isEven ? baseSize * 0.7 : baseSize * 0.4,
      maxOffset: -(baseSize * 0.20),
    );
  }
}
