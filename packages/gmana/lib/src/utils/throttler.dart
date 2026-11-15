import 'dart:async';

/// Default throttle time in milliseconds.
const kDefaultThrottleDuration = 300;

/// A small utility to throttle function execution.
class Throttler {
  /// Throttle delay duration.
  final Duration duration;

  /// Whether the last suppressed action runs when the window closes.
  ///
  /// With this disabled — the default — actions arriving inside an active
  /// window are dropped outright.
  final bool trailing;

  /// Throttle delay in milliseconds.
  int get milliseconds => duration.inMilliseconds;

  Timer? _timer;
  void Function()? _pendingAction;

  /// Creates a throttler with the provided [milliseconds] or [duration] window.
  ///
  /// Set [trailing] to run the most recent suppressed action at the end of the
  /// window, so the final event of a burst is not lost.
  Throttler({int? milliseconds, Duration? duration, this.trailing = false})
    : duration =
          duration ??
          Duration(milliseconds: milliseconds ?? kDefaultThrottleDuration) {
    if (this.duration.inMicroseconds <= 0) {
      throw ArgumentError.value(
        this.duration,
        'duration',
        'must be greater than zero',
      );
    }
  }

  /// Creates a throttler with the provided [duration] window.
  factory Throttler.duration(Duration duration, {bool trailing = false}) =>
      Throttler(duration: duration, trailing: trailing);

  /// Whether a throttle cooldown window is currently active.
  bool get isActive => _timer?.isActive ?? false;

  /// Whether a trailing action is waiting for the window to close.
  bool get hasPendingAction => _pendingAction != null;

  /// Cancels the active throttle window and discards any trailing action.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }

  /// Alias for [dispose].
  void cancel() => dispose();

  /// Runs [action] immediately if not currently throttled.
  ///
  /// While a window is active the action is dropped, or retained as the
  /// trailing action when [trailing] is enabled. Only the most recent
  /// suppressed action is retained.
  void run(void Function() action) {
    if (isActive) {
      if (trailing) _pendingAction = action;
      return;
    }

    action();
    _openWindow();
  }

  void _openWindow() {
    _timer = Timer(duration, () {
      _timer = null;
      final pending = _pendingAction;
      if (pending != null) {
        _pendingAction = null;
        pending();
        // The trailing run leads the next window, so a steady stream is shaped
        // to one action per duration rather than two.
        _openWindow();
      }
    });
  }
}
