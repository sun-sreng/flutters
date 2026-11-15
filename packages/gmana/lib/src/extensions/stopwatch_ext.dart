import 'dart:async';

/// Extension helpers for [Stopwatch].
extension StopwatchX on Stopwatch {
  /// Measures the execution duration of a synchronous [action] function.
  static (R result, Duration elapsed) measure<R>(R Function() action) {
    final sw = Stopwatch()..start();
    final res = action();
    sw.stop();
    return (res, sw.elapsed);
  }

  /// Measures the execution duration of an asynchronous [action] function.
  static Future<(R result, Duration elapsed)> measureAsync<R>(
    Future<R> Function() action,
  ) async {
    final sw = Stopwatch()..start();
    final res = await action();
    sw.stop();
    return (res, sw.elapsed);
  }
}
