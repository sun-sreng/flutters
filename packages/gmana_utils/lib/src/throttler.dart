import 'dart:async';

/// Default throttle time in milliseconds.
const kDefaultThrottleDuration = 300;

/// A small utility to throttle function execution.
class Throttler {
  /// Throttle delay duration.
  final Duration duration;

  /// Throttle delay in milliseconds.
  int get milliseconds => duration.inMilliseconds;

  Timer? _timer;

  /// Creates a throttler with the provided [milliseconds] or [duration] window.
  Throttler({int? milliseconds, Duration? duration})
      : duration = duration ?? Duration(milliseconds: milliseconds ?? kDefaultThrottleDuration) {
    if (this.duration.inMicroseconds <= 0) {
      throw ArgumentError.value(
        this.duration,
        'duration',
        'must be greater than zero',
      );
    }
  }

  /// Creates a throttler with the provided [duration] window.
  factory Throttler.duration(Duration duration) =>
      Throttler(duration: duration);

  /// Whether a throttle cooldown window is currently active.
  bool get isActive => _timer?.isActive ?? false;

  /// Cancels the active throttle window.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Alias for [dispose].
  void cancel() => dispose();

  /// Runs [action] immediately if not currently throttled.
  void run(void Function() action) {
    if (isActive) return;

    action();
    _timer = Timer(duration, () {});
  }
}
