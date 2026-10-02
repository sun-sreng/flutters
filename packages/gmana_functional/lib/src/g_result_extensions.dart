import 'dart:async';

import 'g_result.dart';

/// Recovery, observation, and asynchronous composition for [GResult].
extension GmanaResultX<T, E> on GResult<T, E> {
  /// Returns the success value, or lazily creates a fallback from the error.
  ///
  /// [fallback] is called only when this result is a [GFailure].
  T getOrElseGet(T Function(E error) fallback) => switch (this) {
    GSuccess(:final value) => value,
    GFailure(:final error) => fallback(error),
  };

  /// Converts a [GFailure] into a [GSuccess] using [transform].
  ///
  /// [transform] is not called for an existing [GSuccess]. Exceptions thrown by
  /// [transform] propagate to the caller.
  GResult<T, E> recover(T Function(E error) transform) => switch (this) {
    GSuccess() => this,
    GFailure(:final error) => GResult.success(transform(error)),
  };

  /// Replaces a [GFailure] with the result returned by [transform].
  ///
  /// [transform] can either recover with a [GSuccess] or replace the original
  /// failure. It is not called for an existing [GSuccess].
  GResult<T, E> recoverWith(GResult<T, E> Function(E error) transform) =>
      switch (this) {
        GSuccess() => this,
        GFailure(:final error) => transform(error),
      };

  /// Runs [action] for a [GSuccess], then returns this result unchanged.
  ///
  /// Exceptions thrown by [action] propagate to the caller.
  GResult<T, E> inspectSuccess(void Function(T value) action) {
    if (this case GSuccess(:final value)) action(value);
    return this;
  }

  /// Runs [action] for a [GFailure], then returns this result unchanged.
  ///
  /// Exceptions thrown by [action] propagate to the caller.
  GResult<T, E> inspectFailure(void Function(E error) action) {
    if (this case GFailure(:final error)) action(error);
    return this;
  }

  /// Asynchronously transforms a success value using [transform].
  ///
  /// An existing [GFailure] is forwarded without invoking [transform]. Errors
  /// thrown by [transform], including failed futures, complete the returned
  /// future with that error rather than converting it to a [GFailure].
  Future<GResult<R, E>> mapAsync<R>(
    FutureOr<R> Function(T value) transform,
  ) async => switch (this) {
    GSuccess(:final value) => GResult<R, E>.success(await transform(value)),
    GFailure(:final error) => GResult<R, E>.failure(error),
  };

  /// Asynchronously chains a success into another [GResult].
  ///
  /// An existing [GFailure] is forwarded without invoking [transform]. Errors
  /// thrown by [transform], including failed futures, complete the returned
  /// future with that error rather than converting it to a [GFailure].
  Future<GResult<R, E>> flatMapAsync<R>(
    FutureOr<GResult<R, E>> Function(T value) transform,
  ) async => switch (this) {
    GSuccess(:final value) => await transform(value),
    GFailure(:final error) => GResult<R, E>.failure(error),
  };
}

/// Converts a [Future] completion into a [GResult].
extension GmanaFutureToResultX<T> on Future<T> {
  /// Completes with a [GSuccess], or captures the future's error as a [GFailure].
  ///
  /// This observes an already-created future. It cannot capture a synchronous
  /// error thrown before that future was returned; use [GResult.captureAsync]
  /// when the operation itself must be invoked inside the capture boundary.
  Future<GResult<T, Object>> toResult() =>
      toResultWith<Object>((error, stackTrace) => error);

  /// Completes with a [GSuccess], or maps the future's error to a [GFailure].
  ///
  /// [mapError] receives both the error and its original stack trace. If
  /// [mapError] throws, that new error completes the returned future.
  Future<GResult<T, E>> toResultWith<E>(
    E Function(Object error, StackTrace stackTrace) mapError,
  ) async {
    try {
      return GResult.success(await this);
    } catch (error, stackTrace) {
      return GResult.failure(mapError(error, stackTrace));
    }
  }
}

/// Asynchronous composition for a [Future] that completes with a [GResult].
extension GmanaFutureResultX<T, E> on Future<GResult<T, E>> {
  /// Transforms a successful result with a synchronous or asynchronous callback.
  ///
  /// A failed source future or an error from [transform] remains a future error.
  Future<GResult<R, E>> mapResult<R>(
    FutureOr<R> Function(T value) transform,
  ) async {
    final result = await this;
    return result.mapAsync(transform);
  }

  /// Chains a successful result with a synchronous or asynchronous callback.
  ///
  /// A failed source future or an error from [transform] remains a future error.
  Future<GResult<R, E>> flatMapResult<R>(
    FutureOr<GResult<R, E>> Function(T value) transform,
  ) async {
    final result = await this;
    return result.flatMapAsync(transform);
  }

  /// Resolves this future and handles either result branch.
  ///
  /// Exactly one callback is invoked. Both callbacks may return either a value
  /// or a future, and callback errors remain future errors.
  Future<R> whenResult<R>({
    required FutureOr<R> Function(T value) onSuccess,
    required FutureOr<R> Function(E error) onFailure,
  }) async {
    final result = await this;
    return result.when(onSuccess: onSuccess, onFailure: onFailure);
  }
}

/// Aggregation helpers for collections of [GResult] values.
extension GmanaIterableResultX<T, E> on Iterable<GResult<T, E>> {
  /// Collects every success value, or returns the first failure encountered.
  ///
  /// Results are consumed once and in iteration order. Iteration stops at the
  /// first [GFailure]. An empty iterable produces a successful empty list.
  GResult<List<T>, E> sequenceResults() {
    final values = <T>[];
    for (final result in this) {
      switch (result) {
        case GSuccess(:final value):
          values.add(value);
        case GFailure(:final error):
          return GResult.failure(error);
      }
    }
    return GResult.success(values);
  }

  /// Separates success values and failure errors in a single pass.
  ///
  /// The returned lists are new, growable lists that preserve the relative
  /// iteration order of their respective branches.
  ({List<T> successes, List<E> failures}) partitionResults() {
    final successes = <T>[];
    final failures = <E>[];
    for (final result in this) {
      switch (result) {
        case GSuccess(:final value):
          successes.add(value);
        case GFailure(:final error):
          failures.add(error);
      }
    }
    return (successes: successes, failures: failures);
  }
}
