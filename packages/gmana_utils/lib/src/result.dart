import 'dart:async';

/// A type representing either a success value [T] or a failure error [E].
sealed class Result<T, E> {
  const Result();

  /// Creates a successful [Result] containing [value].
  const factory Result.success(T value) = Success<T, E>;

  /// Creates a failed [Result] containing [error].
  const factory Result.failure(E error) = Failure<T, E>;

  /// Executes [computation] and returns a [Result].
  ///
  /// Returns [Success] if [computation] completes normally.
  /// Returns [Failure] if [computation] throws an exception/error.
  static Result<T, Object> capture<T>(T Function() computation) {
    try {
      return Result.success(computation());
    } catch (e) {
      return Result.failure(e);
    }
  }

  /// Executes async [computation] and returns a `Future<Result>`.
  static Future<Result<T, Object>> captureAsync<T>(
    Future<T> Function() computation,
  ) async {
    try {
      return Result.success(await computation());
    } catch (e) {
      return Result.failure(e);
    }
  }

  /// Executes [computation], mapping a thrown error and its stack trace to [E].
  ///
  /// Unlike [capture], which discards the stack trace, this hands both the
  /// error and its original trace to [onError] so the failure can carry
  /// diagnostic context.
  ///
  /// Example:
  /// ```dart
  /// final parsed = Result.captureWith<int, String>(
  ///   () => int.parse(raw),
  ///   (error, stackTrace) => 'Bad number "$raw": $error',
  /// );
  /// ```
  static Result<T, E> captureWith<T, E>(
    T Function() computation,
    E Function(Object error, StackTrace stackTrace) onError,
  ) {
    try {
      return Result<T, E>.success(computation());
    } catch (error, stackTrace) {
      return Result<T, E>.failure(onError(error, stackTrace));
    }
  }

  /// Executes async [computation], mapping an error and stack trace to [E].
  ///
  /// The asynchronous counterpart to [captureWith].
  static Future<Result<T, E>> captureAsyncWith<T, E>(
    Future<T> Function() computation,
    E Function(Object error, StackTrace stackTrace) onError,
  ) async {
    try {
      return Result<T, E>.success(await computation());
    } catch (error, stackTrace) {
      return Result<T, E>.failure(onError(error, stackTrace));
    }
  }

  /// Wraps a nullable [value], calling [onNull] to build the error for `null`.
  ///
  /// Example:
  /// ```dart
  /// final user = Result.fromNullable<User, String>(
  ///   cache[id],
  ///   () => 'No cached user for $id',
  /// );
  /// ```
  static Result<T, E> fromNullable<T extends Object, E>(
    T? value,
    E Function() onNull,
  ) => value == null
      ? Result<T, E>.failure(onNull())
      : Result<T, E>.success(value);

  /// Returns `true` if this result is [Success].
  bool get isSuccess => this is Success<T, E>;

  /// Returns `true` if this result is [Failure].
  bool get isFailure => this is Failure<T, E>;

  /// Returns the success value if present, or `null`.
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// Returns the failure error if present, or `null`.
  E? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  /// Returns the success value, or [fallback] if this is a [Failure].
  T getOrElse(T fallback) => switch (this) {
    Success(:final value) => value,
    Failure() => fallback,
  };

  /// Transforms the success value using [fn].
  Result<R, E> map<R>(R Function(T value) fn) => switch (this) {
    Success(:final value) => Result.success(fn(value)),
    Failure(:final error) => Result.failure(error),
  };

  /// Transforms the error using [fn].
  Result<T, F> mapError<F>(F Function(E error) fn) => switch (this) {
    Success(:final value) => Result.success(value),
    Failure(:final error) => Result.failure(fn(error)),
  };

  /// Binds a function that returns a [Result].
  Result<R, E> flatMap<R>(Result<R, E> Function(T value) fn) => switch (this) {
    Success(:final value) => fn(value),
    Failure(:final error) => Result.failure(error),
  };

  /// Pattern-matches over the result.
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failure(:final error) => onFailure(error),
  };

  /// Collapses both branches into a single value of type [R].
  ///
  /// An alias for [when], named for readers who know the operation as `fold`.
  ///
  /// Example:
  /// ```dart
  /// final label = result.fold(
  ///   onSuccess: (port) => 'Listening on $port',
  ///   onFailure: (error) => 'Cannot start: $error',
  /// );
  /// ```
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) => when(onSuccess: onSuccess, onFailure: onFailure);

  /// Exchanges the success and failure branches.
  ///
  /// Useful when the error is the interesting case, for example to run the
  /// success-side combinators over it.
  Result<E, T> swap() => switch (this) {
    Success(:final value) => Result<E, T>.failure(value),
    Failure(:final error) => Result<E, T>.success(error),
  };

  /// Transforms whichever branch is present.
  ///
  /// Equivalent to `map(onSuccess).mapError(onFailure)` in one pass.
  Result<R, F> mapBoth<R, F>({
    required R Function(T value) onSuccess,
    required F Function(E error) onFailure,
  }) => switch (this) {
    Success(:final value) => Result<R, F>.success(onSuccess(value)),
    Failure(:final error) => Result<R, F>.failure(onFailure(error)),
  };

  /// Demotes a success that fails [predicate] into a failure built by [orElse].
  ///
  /// An existing failure passes through untouched and [predicate] is not run.
  ///
  /// Example:
  /// ```dart
  /// final port = parsed.filter(
  ///   (value) => value > 0 && value < 65536,
  ///   orElse: (value) => '$value is not a valid port',
  /// );
  /// ```
  Result<T, E> filter(
    bool Function(T value) predicate, {
    required E Function(T value) orElse,
  }) => switch (this) {
    Success(:final value) =>
      predicate(value) ? this : Result<T, E>.failure(orElse(value)),
    Failure() => this,
  };

  /// Returns the success value, or throws the failure error.
  ///
  /// An error that is already an [Exception] or [Error] is thrown as-is,
  /// preserving its type for `catch` clauses. Any other error type is wrapped
  /// in a [StateError] describing it, since throwing an arbitrary value would
  /// be hard for callers to handle.
  ///
  /// Prefer [getOrElse] or [when] where a throw is not wanted.
  T getOrThrow() {
    switch (this) {
      case Success(:final value):
        return value;
      case Failure(:final error):
        if (error is Error) throw error;
        if (error is Exception) throw error;
        throw StateError('Result was a failure: $error');
    }
  }
}

/// A successful [Result] holding a [value].
final class Success<T, E> extends Result<T, E> {
  /// The success value.
  final T value;

  /// Creates a [Success] instance with [value].
  const Success(this.value);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result.success($value)';
}

/// A failed [Result] holding an [error].
final class Failure<T, E> extends Result<T, E> {
  /// The failure error.
  final E error;

  /// Creates a [Failure] instance with [error].
  const Failure(this.error);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Result.failure($error)';
}

