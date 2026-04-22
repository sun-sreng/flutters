import 'dart:async';

/// Default throttle time in milliseconds.
const kDefaultThrottleDuration = 300;

/// A small utility to throttle function execution.
class Throttler {
  /// Throttle delay in milliseconds.
  final int milliseconds;

  Timer? _timer;

  /// Creates a throttler with the provided [milliseconds] window.
  Throttler({this.milliseconds = kDefaultThrottleDuration});

  /// Cancels the active throttle window.
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
  }

  /// Runs [action] immediately if not currently throttled.
  void run(void Function() action) {
    if (_timer?.isActive ?? false) return;

    action();
    _timer = Timer(Duration(milliseconds: milliseconds), () {});
  }
}

/// Extension that throttles a callback inline.
extension ThrottledCallbackX on void Function() {
  /// Runs this callback through a newly created throttler.
  void throttle({int milliseconds = kDefaultThrottleDuration}) {
    final throttler = Throttler(milliseconds: milliseconds);
    throttler.run(call);
  }
}
