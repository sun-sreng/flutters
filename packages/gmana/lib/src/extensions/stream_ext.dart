import 'dart:async';

/// Extension providing collection-oriented functional operations for Streams emitting Lists.
extension StreamListX<T> on Stream<List<T>> {
  /// Emits the length of each list rather than the list itself.
  Stream<int> get lengths => map((items) => items.length);

  /// Emits only non-empty lists.
  Stream<List<T>> get whereNotEmpty => where((items) => items.isNotEmpty);

  /// Filters each emitted list by [predicate].
  Stream<List<T>> filter(bool Function(T) predicate) =>
      map((items) => items.where(predicate).toList());

  /// Flat-maps each emitted list.
  Stream<List<R>> flatMapItems<R>(Iterable<R> Function(T) transform) =>
      map((items) => items.expand(transform).toList());

  /// Flattens each emitted list into individual items.
  Stream<T> flatten() => expand((items) => items);

  /// Maps each element within emitted lists.
  Stream<List<R>> mapItems<R>(R Function(T) transform) =>
      map((items) => items.map(transform).toList());

  /// Sorts each emitted list by [compare].
  Stream<List<T>> sortedBy(Comparator<T> compare) =>
      map((items) => [...items]..sort(compare));
}

/// General-purpose utility extension on [Stream] providing enhanced filtering,
/// timing controls (like debounce/throttle), error handling, and scanning operators.
extension StreamX<T> on Stream<T> {
  /// Emits `(index, value)` pairs - like `enumerate` in Python.
  Stream<(int, T)> get indexed {
    var i = 0;
    return map((value) => (i++, value));
  }

  /// Pairs each event with the previous one as `(previous, current)`.
  /// Skips the first event (no previous exists).
  Stream<(T, T)> get pairwise async* {
    T? prev;
    var hasPrev = false;
    await for (final value in this) {
      if (hasPrev) yield (prev as T, value);
      prev = value;
      hasPrev = true;
    }
  }

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

  /// Emits only values that differ from the previous emission.
  /// Optionally compare via the provided [equals] callback instead of `==`.
  ///
  /// ```dart
  /// stream.distinct((a, b) => a.id == b.id)
  /// ```
  Stream<T> distinctUntilChanged([bool Function(T, T)? equals]) async* {
    T? prev;
    var hasPrev = false;
    await for (final value in this) {
      if (!hasPrev || !(equals?.call(prev as T, value) ?? (prev == value))) {
        prev = value;
        hasPrev = true;
        yield value;
      }
    }
  }

  /// Emits the stream's last value, or `null` if the stream closes empty.
  Future<T?> lastOrNull() async {
    T? last;
    await for (final value in this) {
      last = value;
    }
    return last;
  }

  /// Recovers from errors by emitting [fallback].
  Stream<T> onErrorReturn(T fallback) => transform(
    StreamTransformer.fromHandlers(
      handleError: (_, _, sink) => sink.add(fallback),
    ),
  );

  /// Recovers from errors by emitting the result of [recover].
  Stream<T> onErrorReturnWith(T Function(Object error) recover) => transform(
    StreamTransformer.fromHandlers(
      handleError: (error, _, sink) => sink.add(recover(error)),
    ),
  );

  /// Accumulates state across events using [seed] and [accumulate].
  ///
  /// ```dart
  /// countStream.scan(0, (acc, n) => acc + n) // running total
  /// ```
  Stream<S> scan<S>(S seed, S Function(S acc, T value) accumulate) async* {
    var state = seed;
    await for (final value in this) {
      state = accumulate(state, value);
      yield state;
    }
  }

  /// Discards events until [predicate] returns `true`, then emits all subsequent ones.
  Stream<T> skipUntil(bool Function(T) predicate) async* {
    var triggered = false;
    await for (final value in this) {
      if (!triggered && predicate(value)) triggered = true;
      if (triggered) yield value;
    }
  }

  /// Emits events only while [predicate] holds; closes the stream on first failure.
  Stream<T> takeWhileInclusive(bool Function(T) predicate) async* {
    await for (final value in this) {
      yield value;
      if (!predicate(value)) break;
    }
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

  /// Emits only non-null values, narrowing the type to [R].
  Stream<R> whereNotNull<R extends Object>() =>
      where((e) => e != null).cast<R>();

  /// Groups events into lists of [count]. The final buffer is emitted even
  /// when it is short.
  ///
  /// ```dart
  /// events.bufferCount(50).listen(batchUpload);
  /// ```
  Stream<List<T>> bufferCount(int count) async* {
    if (count <= 0) {
      throw ArgumentError.value(count, 'count', 'must be greater than zero');
    }

    var buffer = <T>[];
    await for (final value in this) {
      buffer.add(value);
      if (buffer.length == count) {
        yield buffer;
        buffer = <T>[];
      }
    }
    if (buffer.isNotEmpty) yield buffer;
  }

  /// Emits [value] immediately, then everything from this stream.
  ///
  /// Handy for giving a state stream an initial value.
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }

  /// Emits every element of [values] in order, then this stream's events.
  Stream<T> startWithMany(Iterable<T> values) async* {
    yield* Stream.fromIterable(values);
    yield* this;
  }

  /// Runs [action] for each event without modifying the stream.
  Stream<T> doOnData(void Function(T value) action) => transform(
    StreamTransformer.fromHandlers(
      handleData: (value, sink) {
        action(value);
        sink.add(value);
      },
    ),
  );

  /// Runs [action] for each error without swallowing it.
  Stream<T> doOnError(
    void Function(Object error, StackTrace stackTrace) action,
  ) => transform(
    StreamTransformer.fromHandlers(
      handleError: (error, stackTrace, sink) {
        action(error, stackTrace);
        sink.addError(error, stackTrace);
      },
    ),
  );

  /// Runs [action] when the stream closes.
  Stream<T> doOnDone(void Function() action) => transform(
    StreamTransformer.fromHandlers(
      handleDone: (sink) {
        action();
        sink.close();
      },
    ),
  );

  /// Maps each event and drops the `null` results.
  Stream<R> mapNotNull<R extends Object>(R? Function(T value) transform) =>
      map(transform).where((value) => value != null).cast<R>();

  /// Emits only the events that do *not* satisfy [test].
  Stream<T> whereNot(bool Function(T value) test) =>
      where((value) => !test(value));

  /// Discards errors instead of forwarding them.
  Stream<T> ignoreErrors() => handleError((Object _) {});

  /// The first event, or `null` if the stream closes empty.
  ///
  /// Unlike [Stream.first] this never throws a [StateError].
  Future<T?> firstOrNull() async {
    await for (final value in this) {
      return value;
    }
    return null;
  }

  /// Interleaves this stream with [others], closing once all are done.
  Stream<T> mergeWith(Iterable<Stream<T>> others) {
    final sources = <Stream<T>>[this, ...others];

    late StreamController<T> controller;
    final subscriptions = <StreamSubscription<T>>[];
    var remaining = 0;

    void listenToSources() {
      remaining = sources.length;
      for (final source in sources) {
        subscriptions.add(
          source.listen(
            controller.add,
            onError: controller.addError,
            onDone: () {
              remaining--;
              if (remaining == 0) unawaited(controller.close());
            },
          ),
        );
      }
    }

    Future<void> cancel() async {
      await Future.wait(subscriptions.map((s) => s.cancel()));
      subscriptions.clear();
    }

    controller =
        isBroadcast
            ? StreamController<T>.broadcast(
              onListen: listenToSources,
              onCancel: cancel,
            )
            : StreamController<T>(onListen: listenToSources, onCancel: cancel);
    return controller.stream;
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
