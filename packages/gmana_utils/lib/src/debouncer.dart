import 'dart:async';

/// Default debounce time in milliseconds.
const kDefaultDebounceTime = 150;

/// A small utility to debounce function execution.
class Debouncer {
  /// Debounce delay duration.
  final Duration delay;

  /// Debounce delay in milliseconds.
  int get milliseconds => delay.inMilliseconds;

  Timer? _timer;
  void Function()? _pendingAction;

  /// Creates a debouncer with the provided [milliseconds] or [duration] delay.
  Debouncer({int? milliseconds, Duration? duration})
      : delay = duration ?? Duration(milliseconds: milliseconds ?? kDefaultDebounceTime) {
    if (delay.inMicroseconds <= 0) {
      throw ArgumentError.value(
        delay,
        'delay',
        'must be greater than zero',
      );
    }
  }

  /// Creates a debouncer with the provided [duration] delay.
  factory Debouncer.duration(Duration duration) =>
      Debouncer(duration: duration);

  /// Whether a debounced action is currently scheduled.
  bool get isPending => _timer?.isActive ?? false;

  /// Cancels any pending action.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
  }

  /// Alias for [dispose].
  void cancel() => dispose();

  /// Immediately executes any pending action and cancels the timer.
  void flush() {
    if (isPending && _pendingAction != null) {
      final action = _pendingAction!;
      dispose();
      action();
    }
  }

  /// Schedules [action], replacing any pending action.
  void run(void Function() action) {
    _timer?.cancel();
    _pendingAction = action;
    _timer = Timer(delay, () {
      _pendingAction = null;
      action();
    });
  }
}
