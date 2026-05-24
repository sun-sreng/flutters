import 'dart:async';

/// Extension providing collection-oriented functional operations for Streams emitting Lists.
extension StreamListX<T> on Stream<List<T>> {
  /// Emits the length of each list rather than the list itself.
  Stream<int> get lengths => map((items) => items.length);

  /// Emits only non-empty lists.
  Stream<List<T>> get whereNotEmpty => where((items) => items.isNotEmpty);

  /// Filters each emitted list by [predicate].
  Stream<List<T>> filter(bool Function(T) predicate) => map((items) => items.where(predicate).toList());

  /// Flat-maps each emitted list.
  Stream<List<R>> flatMapItems<R>(Iterable<R> Function(T) transform) =>
      map((items) => items.expand(transform).toList());

  /// Flattens each emitted list into individual items.
  Stream<T> flatten() => expand((items) => items);

  /// Maps each element within emitted lists.
  Stream<List<R>> mapItems<R>(R Function(T) transform) => map((items) => items.map(transform).toList());

  /// Sorts each emitted list by [compare].
  Stream<List<T>> sortedBy(Comparator<T> compare) => map((items) => [...items]..sort(compare));
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
    await for (final value in this) {
      if (prev != null) yield (prev, value);
      prev = value;
    }
  }

  /// Suppresses events that arrive within [duration] of each other,
  /// emitting only the last one in each quiet window (debounce).
  Stream<T> debounce(Duration duration) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    T? latest;
    var hasLatest = false;
    var sourceDone = false;

    void emitLatest() {
      if (hasLatest) {
        controller.add(latest as T);
        latest = null;
        hasLatest = false;
      }
      if (sourceDone) {
        unawaited(controller.close());
      }
    }

    void listenToSource() {
      subscription = listen(
        (value) {
          latest = value;
          hasLatest = true;
          timer?.cancel();
          timer = Timer(duration, emitLatest);
        },
        onError: controller.addError,
        onDone: () {
          sourceDone = true;
          timer?.cancel();
          emitLatest();
        },
      );
    }

    Future<void> cancel() async {
      timer?.cancel();
      latest = null;
      hasLatest = false;
      await subscription?.cancel();
    }

    controller =
        isBroadcast
            ? StreamController<T>.broadcast(onListen: listenToSource, onCancel: cancel)
            : StreamController<T>(onListen: listenToSource, onCancel: cancel);
    return controller.stream;
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
  Stream<T> onErrorReturn(T fallback) =>
      transform(StreamTransformer.fromHandlers(handleError: (_, _, sink) => sink.add(fallback)));

  /// Recovers from errors by emitting the result of [recover].
  Stream<T> onErrorReturnWith(T Function(Object error) recover) =>
      transform(StreamTransformer.fromHandlers(handleError: (error, _, sink) => sink.add(recover(error))));

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

  /// Emits the first event of each [duration] window and suppresses the rest (throttle).
  Stream<T> throttle(Duration duration) {
    if (duration <= Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be greater than zero');
    }

    late StreamController<T> controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    var suppressed = false;

    void listenToSource() {
      subscription = listen(
        (value) {
          if (suppressed) return;
          controller.add(value);
          suppressed = true;
          timer?.cancel();
          timer = Timer(duration, () => suppressed = false);
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          unawaited(controller.close());
        },
      );
    }

    Future<void> cancel() async {
      timer?.cancel();
      await subscription?.cancel();
    }

    controller =
        isBroadcast
            ? StreamController<T>.broadcast(onListen: listenToSource, onCancel: cancel)
            : StreamController<T>(onListen: listenToSource, onCancel: cancel);
    return controller.stream;
  }

  /// Emits only non-null values, narrowing the type to [R].
  Stream<R> whereNotNull<R extends Object>() => where((e) => e != null).cast<R>();
}
