import 'package:flutter/animation.dart';

/// Extension methods for [AnimationController].
extension AnimationControllerX on AnimationController {
  /// Toggles animation state: plays forward if dismissed/reversed, or reverses if completed/forward.
  TickerFuture toggle({double? from}) {
    if (isCompleted || status == AnimationStatus.forward) {
      return reverse(from: from);
    } else {
      return forward(from: from);
    }
  }

  /// Resets controller to 0.0 and starts playing forward.
  TickerFuture restart({double? from}) {
    reset();
    return forward(from: from);
  }
}

/// Extension getters and methods for [Animation].
extension AnimationX<T> on Animation<T> {
  /// Whether the animation is currently running forward or in reverse.
  bool get isAnimating =>
      status == AnimationStatus.forward || status == AnimationStatus.reverse;
}
