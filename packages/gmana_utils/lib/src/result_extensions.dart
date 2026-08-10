import 'dart:async';

import 'result.dart';

/// Recovery, observation, and asynchronous composition for [Result].
extension GmanaResultX<T, E> on Result<T, E> {
  /// Returns the success value, or lazily creates a fallback from the error.
  ///
  /// [fallback] is called only when this result is a [Failure].
  T getOrElseGet(T Function(E error) fallback) => switch (this) {
    Success(:final value) => value,
    Failure(:final error) => fallback(error),
  };

  /// Converts a [Failure] into a [Success] using [transform].
  ///
  /// [transform] is not called for an existing [Success]. Exceptions thrown by
  /// [transform] propagate to the caller.
  Result<T, E> recover(T Function(E error) transform) => switch (this) {
    Success() => this,
    Failure(:final error) => Result.success(transform(error)),
  };

  /// Replaces a [Failure] with the result returned by [transform].
  ///
  /// [transform] can either recover with a [Success] or replace the original
  /// failure. It is not called for an existing [Success].
  Result<T, E> recoverWith(Result<T, E> Function(E error) transform) =>
      switch (this) {
        Success() => this,
        Failure(:final error) => transform(error),
      };

  /// Runs [action] for a [Success], then returns this result unchanged.
  ///
  /// Exceptions thrown by [action] propagate to the caller.
  Result<T, E> inspectSuccess(void Function(T value) action) {
    if (this case Success(:final value)) action(value);
    return this;
  }

  /// Runs [action] for a [Failure], then returns this result unchanged.
  ///
  /// Exceptions thrown by [action] propagate to the caller.
  Result<T, E> inspectFailure(void Function(E error) action) {
    if (this case Failure(:final error)) action(error);
    return this;
  }

  /// Asynchronously transforms a success value using [transform].
  ///
  /// An existing [Failure] is forwarded without invoking [transform]. Errors
  /// thrown by [transform], including failed futures, complete the returned
  /// future with that error rather than converting it to a [Failure].
  Future<Result<R, E>> mapAsync<R>(
    FutureOr<R> Function(T value) transform,
  ) async => switch (this) {
    Success(:final value) => Result<R, E>.success(await transform(value)),
    Failure(:final error) => Result<R, E>.failure(error),
  };

  /// Asynchronously chains a success into another [Result].
  ///
  /// An existing [Failure] is forwarded without invoking [transform]. Errors
  /// thrown by [transform], including failed futures, complete the returned
  /// future with that error rather than converting it to a [Failure].
  Future<Result<R, E>> flatMapAsync<R>(
    FutureOr<Result<R, E>> Function(T value) transform,
  ) async => switch (this) {
    Success(:final value) => await transform(value),
    Failure(:final error) => Result<R, E>.failure(error),
  };
}

/// Converts a [Future] completion into a [Result].
extension GmanaFutureToResultX<T> on Future<T> {
  /// Completes with a [Success], or captures the future's error as a [Failure].
  ///
  /// This observes an already-created future. It cannot capture a synchronous
  /// error thrown before that future was returned; use [Result.captureAsync]
  /// when the operation itself must be invoked inside the capture boundary.
  Future<Result<T, Object>> toResult() =>
      toResultWith<Object>((error, stackTrace) => error);

  /// Completes with a [Success], or maps the future's error to a [Failure].
  ///
  /// [mapError] receives both the error and its original stack trace. If
  /// [mapError] throws, that new error completes the returned future.
  Future<Result<T, E>> toResultWith<E>(
    E Function(Object error, StackTrace stackTrace) mapError,
  ) async {
    try {
      return Result.success(await this);
    } catch (error, stackTrace) {
      return Result.failure(mapError(error, stackTrace));
    }
  }
}

/// Asynchronous composition for a [Future] that completes with a [Result].
extension GmanaFutureResultX<T, E> on Future<Result<T, E>> {
  /// Transforms a successful result with a synchronous or asynchronous callback.
  ///
  /// A failed source future or an error from [transform] remains a future error.
  Future<Result<R, E>> mapResult<R>(
    FutureOr<R> Function(T value) transform,
  ) async {
    final result = await this;
    return result.mapAsync(transform);
  }

  /// Chains a successful result with a synchronous or asynchronous callback.
  ///
  /// A failed source future or an error from [transform] remains a future error.
  Future<Result<R, E>> flatMapResult<R>(
    FutureOr<Result<R, E>> Function(T value) transform,
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

/// Aggregation helpers for collections of [Result] values.
extension GmanaIterableResultX<T, E> on Iterable<Result<T, E>> {
  /// Collects every success value, or returns the first failure encountered.
  ///
  /// Results are consumed once and in iteration order. Iteration stops at the
  /// first [Failure]. An empty iterable produces a successful empty list.
  Result<List<T>, E> sequenceResults() {
    final values = <T>[];
    for (final result in this) {
      switch (result) {
        case Success(:final value):
          values.add(value);
        case Failure(:final error):
          return Result.failure(error);
      }
    }
    return Result.success(values);
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
        case Success(:final value):
          successes.add(value);
        case Failure(:final error):
          failures.add(error);
      }
    }
    return (successes: successes, failures: failures);
  }
}
