import 'package:flutter/material.dart';

/// Configuration for animating a single dot in the GWaveDotSpinner widget.
class DotAnimationConfig {
  /// Interval used to animate the dot height upward.
  final Interval heightInterval;

  /// Interval used to animate the dot offset upward.
  final Interval offsetInterval;

  /// Interval used to animate the dot height back down.
  final Interval reverseHeightInterval;

  /// Interval used to animate the dot offset back down.
  final Interval reverseOffsetInterval;

  /// Maximum dot height.
  final double maxHeight;

  /// Maximum vertical dot offset.
  final double maxOffset;

  /// Creates a config with explicit intervals and dot bounds.
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
    assert(index >= 0, 'index must be zero or greater.');
    assert(dotCount > 0, 'dotCount must be greater than zero.');
    assert(index < dotCount, 'index must be less than dotCount.');
    assert(baseSize > 0, 'baseSize must be greater than zero.');

    const step = 0.09;
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
