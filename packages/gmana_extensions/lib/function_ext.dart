import 'dart:async';

/// Extension methods for zero-argument functions (`R Function()`).
extension Function0X<R> on R Function() {
  /// Returns a memoized version of this function that caches its result on first call.
  R Function() memoize() {
    bool evaluated = false;
    late R cachedResult;

    return () {
      if (!evaluated) {
        cachedResult = this();
        evaluated = true;
      }
      return cachedResult;
    };
  }

  /// Measures execution duration and returns a record `(result, elapsed)`.
  (R result, Duration elapsed) timed() {
    final stopwatch = Stopwatch()..start();
    final res = this();
    stopwatch.stop();
    return (res, stopwatch.elapsed);
  }
}

/// Extension methods for zero-argument async functions (`Future<R> Function()`).
extension AsyncFunction0X<R> on Future<R> Function() {
  /// Measures async execution duration and returns a record `(result, elapsed)`.
  Future<(R result, Duration elapsed)> timedAsync() async {
    final stopwatch = Stopwatch()..start();
    final res = await this();
    stopwatch.stop();
    return (res, stopwatch.elapsed);
  }
}
