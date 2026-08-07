import 'package:flutter/animation.dart';

/// Animation duration and curve tokens.
///
/// Keeping these in one place stops each widget from inventing its own
/// timing, which is what makes a set of components feel like one product.
abstract final class GMotion {
  /// Effectively no animation (0ms) — use to disable motion.
  static const Duration instant = Duration.zero;

  /// Very quick feedback (100ms) — ripples, hover tints.
  static const Duration xfast = Duration(milliseconds: 100);

  /// Quick feedback (150ms) — icon swaps, small fades.
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard transition (250ms) — the default for most state changes.
  static const Duration normal = Duration(milliseconds: 250);

  /// Deliberate transition (400ms) — expanding panels, sheets.
  static const Duration slow = Duration(milliseconds: 400);

  /// Long transition (700ms) — page-level or onboarding motion.
  static const Duration xslow = Duration(milliseconds: 700);

  /// Default easing for most transitions.
  static const Curve standard = Curves.easeInOut;

  /// Easing for elements entering the screen.
  static const Curve enter = Curves.easeOut;

  /// Easing for elements leaving the screen.
  static const Curve exit = Curves.easeIn;

  /// Playful overshoot for emphasis.
  static const Curve emphasized = Curves.easeOutBack;
}
