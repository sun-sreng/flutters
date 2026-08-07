import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Position queries and scroll shortcuts on [ScrollController].
///
/// Every member checks [ScrollController.hasClients] first. Reading
/// `controller.position` before the controller is attached throws, and that
/// is the single most common bug with scroll controllers — build order and
/// disposal both leave you briefly detached.
extension ScrollControllerX on ScrollController {
  /// Current offset, or `0` when not attached.
  double get offsetOrZero => hasClients ? offset : 0;

  /// Maximum scrollable extent, or `0` when not attached.
  double get maxScroll => hasClients ? position.maxScrollExtent : 0;

  /// Minimum scrollable extent, or `0` when not attached.
  double get minScroll => hasClients ? position.minScrollExtent : 0;

  /// Scroll progress in `[0, 1]`, or `0` when not attached or not scrollable.
  double get progress {
    if (!hasClients) return 0;
    final range = position.maxScrollExtent - position.minScrollExtent;
    if (range <= 0) return 0;
    return ((offset - position.minScrollExtent) / range).clamp(0.0, 1.0);
  }

  /// Whether the view is scrolled to (or past) the top.
  ///
  /// Returns `false` when not attached, so it never reports a position the
  /// widget has not reached.
  bool get isAtTop => hasClients && offset <= position.minScrollExtent;

  /// Whether the view is scrolled to (or past) the bottom.
  bool get isAtBottom => hasClients && offset >= position.maxScrollExtent;

  /// Whether there is anything to scroll.
  bool get isScrollable =>
      hasClients && position.maxScrollExtent > position.minScrollExtent;

  /// Whether the user is currently dragging the content upward (revealing
  /// later items). `false` when not attached or idle.
  bool get isScrollingDown =>
      hasClients && position.userScrollDirection == ScrollDirection.reverse;

  /// Whether the user is currently dragging the content downward.
  bool get isScrollingUp =>
      hasClients && position.userScrollDirection == ScrollDirection.forward;

  /// Whether [offset] is within [tolerance] of the bottom.
  ///
  /// Use this for infinite-scroll triggers so loading starts slightly before
  /// the user actually hits the end.
  bool isNearBottom({double tolerance = 200}) {
    if (tolerance < 0) {
      throw ArgumentError.value(tolerance, 'tolerance', 'must not be negative');
    }
    return hasClients && offset >= position.maxScrollExtent - tolerance;
  }

  /// Whether [offset] is within [tolerance] of the top.
  bool isNearTop({double tolerance = 200}) {
    if (tolerance < 0) {
      throw ArgumentError.value(tolerance, 'tolerance', 'must not be negative');
    }
    return hasClients && offset <= position.minScrollExtent + tolerance;
  }

  /// Animates to the top. No-op when not attached.
  Future<void> animateToTop({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) async {
    if (!hasClients) return;
    await animateTo(position.minScrollExtent, duration: duration, curve: curve);
  }

  /// Animates to the bottom. No-op when not attached.
  Future<void> animateToBottom({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) async {
    if (!hasClients) return;
    await animateTo(position.maxScrollExtent, duration: duration, curve: curve);
  }

  /// Jumps to the top without animating. No-op when not attached.
  void jumpToTop() {
    if (hasClients) jumpTo(position.minScrollExtent);
  }

  /// Jumps to the bottom without animating. No-op when not attached.
  void jumpToBottom() {
    if (hasClients) jumpTo(position.maxScrollExtent);
  }

  /// Jumps to [target], clamped to the scrollable range. No-op when not
  /// attached.
  void jumpToClamped(double target) {
    if (!hasClients) return;
    jumpTo(target.clamp(position.minScrollExtent, position.maxScrollExtent));
  }
}
