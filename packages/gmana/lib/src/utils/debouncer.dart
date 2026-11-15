import 'dart:async';

/// Default debounce time in milliseconds.
const kDefaultDebounceTime = 150;

/// Thrown when a debounced action never runs.
///
/// A pending [Debouncer.runAsync] call completes with this once a later call
/// supersedes it, or once the debouncer is disposed. It signals "this action
/// was intentionally dropped", not that the action itself failed.
class DebouncedException implements Exception {
  /// Explains why the action was dropped.
  final String message;

  /// Creates a [DebouncedException].
  const DebouncedException([
    this.message = 'Action was superseded before it ran',
  ]);

  @override
  String toString() => 'DebouncedException: $message';
}

/// A small utility to debounce function execution.
class Debouncer {
  /// Debounce delay duration.
  final Duration delay;

  /// Debounce delay in milliseconds.
  int get milliseconds => delay.inMilliseconds;

  Timer? _timer;
  void Function()? _pendingAction;
  void Function(DebouncedException error)? _pendingCancel;

  /// Creates a debouncer with the provided [milliseconds] or [duration] delay.
  Debouncer({int? milliseconds, Duration? duration})
    : delay =
          duration ??
          Duration(milliseconds: milliseconds ?? kDefaultDebounceTime) {
    if (delay.inMicroseconds <= 0) {
      throw ArgumentError.value(delay, 'delay', 'must be greater than zero');
    }
  }

  /// Creates a debouncer with the provided [duration] delay.
  factory Debouncer.duration(Duration duration) =>
      Debouncer(duration: duration);

  /// Whether a debounced action is currently scheduled.
  bool get isPending => _timer?.isActive ?? false;

  /// Cancels any pending action.
  ///
  /// A pending [runAsync] future completes with a [DebouncedException].
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
    _rejectPending('Debouncer was disposed');
  }

  /// Alias for [dispose].
  void cancel() => dispose();

  /// Immediately executes any pending action and cancels the timer.
  void flush() {
    if (isPending && _pendingAction != null) {
      final action = _pendingAction!;
      _timer?.cancel();
      _timer = null;
      _pendingAction = null;
      _pendingCancel = null;
      action();
    }
  }

  /// Schedules [action], replacing any pending action.
  void run(void Function() action) {
    _supersede();
    _pendingAction = action;
    _timer = Timer(delay, () {
      _pendingAction = null;
      _pendingCancel = null;
      action();
    });
  }

  /// Schedules [action] and returns its eventual result.
  ///
  /// Only the final call of a burst runs. Every superseded call — and any call
  /// still pending when [dispose] is invoked — completes with a
  /// [DebouncedException], so no returned future is left hanging.
  ///
  /// Errors thrown by [action] complete the returned future with that error.
  ///
  /// Example:
  /// ```dart
  /// final debouncer = Debouncer(milliseconds: 300);
  ///
  /// Future<void> onQueryChanged(String query) async {
  ///   try {
  ///     final results = await debouncer.runAsync(() => search(query));
  ///     setState(() => _results = results);
  ///   } on DebouncedException {
  ///     // A newer keystroke took over; nothing to do.
  ///   }
  /// }
  /// ```
  Future<T> runAsync<T>(FutureOr<T> Function() action) {
    _supersede();

    final completer = Completer<T>();
    _pendingCancel = (error) {
      if (completer.isCompleted) return;
      completer.completeError(error);
      // A superseded action is routinely fire-and-forget, and a rejected
      // future with no listener yet would surface as an unhandled async
      // error. Marking it handled suppresses that; a caller that does await
      // still receives the DebouncedException.
      completer.future.ignore();
    };

    _timer = Timer(delay, () async {
      _pendingAction = null;
      _pendingCancel = null;
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  /// Cancels the active timer and rejects any pending [runAsync] future.
  void _supersede() {
    _timer?.cancel();
    _rejectPending('Action was superseded before it ran');
  }

  void _rejectPending(String message) {
    final cancel = _pendingCancel;
    _pendingCancel = null;
    cancel?.call(DebouncedException(message));
  }
}
