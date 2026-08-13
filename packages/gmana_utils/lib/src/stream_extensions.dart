import 'dart:async';

import 'debouncer.dart';
import 'throttler.dart';

/// Time-based rate shaping for [Stream].
///
/// These are the stream counterparts to [Debouncer] and [Throttler], for cases
/// where the events already arrive as a stream rather than as callbacks.
extension GmanaStreamTimingX<T> on Stream<T> {
  /// Emits an event only after [duration] has passed without another event.
  ///
  /// Each incoming event replaces the pending one and restarts the timer, so a
  /// burst produces a single emission carrying the burst's last value. If the
  /// source closes while an event is pending, that event is emitted before the
  /// done signal rather than dropped.
  ///
  /// Errors are forwarded immediately and do not reset the timer.
  ///
  /// Throws an [ArgumentError] if [duration] is not positive.
  ///
  /// Example:
  /// ```dart
  /// // One search per typing pause, not one per keystroke.
  /// queryController.stream
  ///     .debounce(const Duration(milliseconds: 300))
  ///     .listen(performSearch);
  /// ```
  Stream<T> debounce(Duration duration) {
    _checkDuration(duration);

    return Stream<T>.eventTransformed(
      this,
      (sink) => _DebounceSink<T>(sink, duration),
    );
  }

  /// Emits the first event of each [duration] window and drops the rest.
  ///
  /// With [trailing] enabled, the most recent dropped event is emitted at the
  /// end of the window; a window during which nothing was dropped emits
  /// nothing extra.
  ///
  /// Errors are forwarded immediately and do not open or close a window.
  ///
  /// Throws an [ArgumentError] if [duration] is not positive.
  ///
  /// Example:
  /// ```dart
  /// // Update the header at most ten times a second while scrolling.
  /// scrollEvents
  ///     .throttle(const Duration(milliseconds: 100))
  ///     .listen(updateHeader);
  /// ```
  Stream<T> throttle(Duration duration, {bool trailing = false}) {
    _checkDuration(duration);

    return Stream<T>.eventTransformed(
      this,
      (sink) => _ThrottleSink<T>(sink, duration, trailing: trailing),
    );
  }

  static void _checkDuration(Duration duration) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be positive');
    }
  }
}

class _DebounceSink<T> implements EventSink<T> {
  _DebounceSink(this._output, this._duration);

  final EventSink<T> _output;
  final Duration _duration;

  Timer? _timer;
  T? _pending;
  bool _hasPending = false;

  @override
  void add(T data) {
    _timer?.cancel();
    _pending = data;
    _hasPending = true;
    _timer = Timer(_duration, _emitPending);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _output.addError(error, stackTrace);
  }

  @override
  void close() {
    _timer?.cancel();
    _timer = null;
    _emitPending();
    _output.close();
  }

  void _emitPending() {
    if (!_hasPending) return;
    final data = _pending as T;
    _pending = null;
    _hasPending = false;
    _output.add(data);
  }
}

class _ThrottleSink<T> implements EventSink<T> {
  _ThrottleSink(this._output, this._duration, {required bool trailing})
    : _trailing = trailing;

  final EventSink<T> _output;
  final Duration _duration;
  final bool _trailing;

  Timer? _timer;
  T? _pending;
  bool _hasPending = false;

  @override
  void add(T data) {
    if (_timer != null) {
      if (_trailing) {
        _pending = data;
        _hasPending = true;
      }
      return;
    }

    _output.add(data);
    _openWindow();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _output.addError(error, stackTrace);
  }

  @override
  void close() {
    _timer?.cancel();
    _timer = null;
    _emitPending();
    _output.close();
  }

  void _openWindow() {
    _timer = Timer(_duration, () {
      _timer = null;
      if (_hasPending) {
        _emitPending();
        // A trailing emission starts the next window, so a steady stream is
        // shaped to one event per duration rather than two.
        _openWindow();
      }
    });
  }

  void _emitPending() {
    if (!_hasPending) return;
    final data = _pending as T;
    _pending = null;
    _hasPending = false;
    _output.add(data);
  }
}
