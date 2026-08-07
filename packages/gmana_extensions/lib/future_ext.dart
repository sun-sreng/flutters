import 'dart:async';

/// Timeout, recovery, and chaining helpers on [Future].
extension FutureX<T> on Future<T> {
  /// Completes with `null` instead of throwing if this future does not
  /// finish within [duration].
  ///
  /// ```dart
  /// final profile = await fetchProfile().timeoutOrNull(2.seconds);
  /// ```
  Future<T?> timeoutOrNull(Duration duration) async {
    try {
      return await timeout(duration);
    } on TimeoutException {
      return null;
    }
  }

  /// Completes with [fallback] if this future does not finish within [duration].
  Future<T> timeoutWith(Duration duration, T fallback) =>
      timeout(duration, onTimeout: () => fallback);

  /// Swallows any error and completes with `null` instead.
  ///
  /// ```dart
  /// final cached = await readCache().orNull();
  /// ```
  Future<T?> orNull() async {
    try {
      return await this;
    } catch (_) {
      return null;
    }
  }

  /// Recovers from any error by completing with [fallback].
  Future<T> onErrorReturn(T fallback) async {
    try {
      return await this;
    } catch (_) {
      return fallback;
    }
  }

  /// Recovers from any error by completing with the result of [recover].
  Future<T> onErrorReturnWith(
    T Function(Object error, StackTrace stackTrace) recover,
  ) async {
    try {
      return await this;
    } catch (error, stackTrace) {
      return recover(error, stackTrace);
    }
  }

  /// Maps the completed value through [transform].
  ///
  /// A terser `then` for the common non-async case.
  Future<R> thenMap<R>(R Function(T value) transform) => then(transform);

  /// Runs [action] with the completed value and returns the value unchanged.
  Future<T> tap(void Function(T value) action) async {
    final value = await this;
    action(value);
    return value;
  }

  /// Delays the completion of this future by at least [duration].
  Future<T> delayedBy(Duration duration) async {
    final value = await this;
    await Future<void>.delayed(duration);
    return value;
  }

  /// Converts a failure into a successfully completed record of
  /// `(value, error)`, so a caller can branch without a `try`/`catch`.
  ///
  /// Exactly one side is non-null unless the future legitimately completes
  /// with `null`.
  ///
  /// ```dart
  /// final (value, error) = await risky().settled();
  /// if (error != null) log(error);
  /// ```
  Future<(T? value, Object? error)> settled() async {
    try {
      return (await this, null);
    } catch (error) {
      return (null, error);
    }
  }
}

/// Async mapping helpers on any [Iterable].
extension IterableFutureX<T> on Iterable<T> {
  /// Applies [transform] to each element one at a time, in order.
  ///
  /// Use when the work must not overlap (rate limits, ordered writes).
  Future<List<R>> mapSequential<R>(
    Future<R> Function(T element) transform,
  ) async {
    final results = <R>[];
    for (final element in this) {
      results.add(await transform(element));
    }
    return results;
  }

  /// Applies [transform] to every element concurrently and waits for all.
  ///
  /// ```dart
  /// final pages = await urls.mapParallel(fetch);
  /// ```
  Future<List<R>> mapParallel<R>(
    Future<R> Function(T element) transform, {
    bool eagerError = false,
  }) => Future.wait(map(transform), eagerError: eagerError);

  /// Applies [transform] concurrently, at most [concurrency] futures in flight.
  Future<List<R>> mapConcurrent<R>(
    Future<R> Function(T element) transform, {
    required int concurrency,
  }) async {
    if (concurrency <= 0) {
      throw ArgumentError.value(
        concurrency,
        'concurrency',
        'must be greater than zero',
      );
    }

    final elements = toList();
    final results = List<R?>.filled(elements.length, null);
    var next = 0;

    Future<void> worker() async {
      while (true) {
        final index = next++;
        if (index >= elements.length) return;
        results[index] = await transform(elements[index]);
      }
    }

    final workerCount =
        concurrency < elements.length ? concurrency : elements.length;
    await Future.wait(List.generate(workerCount, (_) => worker()));
    return results.cast<R>();
  }

  /// Keeps only the elements for which [test] resolves to `true`.
  Future<List<T>> whereAsync(Future<bool> Function(T element) test) async {
    final results = <T>[];
    for (final element in this) {
      if (await test(element)) results.add(element);
    }
    return results;
  }
}
