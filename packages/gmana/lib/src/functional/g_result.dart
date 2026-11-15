import 'dart:async';

/// A type representing either a success value [T] or a failure error [E].
///
/// Named with a `G` prefix because this library already has `Result<T>`, the
/// alias for `Either<Failure, T>`, and the `Failure` class it refers to.
sealed class GResult<T, E> {
  const GResult();

  /// Creates a successful [GResult] containing [value].
  const factory GResult.success(T value) = GSuccess<T, E>;

  /// Creates a failed [GResult] containing [error].
  const factory GResult.failure(E error) = GFailure<T, E>;

  /// Executes [computation] and returns a [GResult].
  ///
  /// Returns [GSuccess] if [computation] completes normally.
  /// Returns [GFailure] if [computation] throws an exception/error.
  static GResult<T, Object> capture<T>(T Function() computation) {
    try {
      return GResult.success(computation());
    } catch (e) {
      return GResult.failure(e);
    }
  }

  /// Executes async [computation] and returns a `Future<GResult>`.
  static Future<GResult<T, Object>> captureAsync<T>(
    Future<T> Function() computation,
  ) async {
    try {
      return GResult.success(await computation());
    } catch (e) {
      return GResult.failure(e);
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
  /// final parsed = GResult.captureWith<int, String>(
  ///   () => int.parse(raw),
  ///   (error, stackTrace) => 'Bad number "$raw": $error',
  /// );
  /// ```
  static GResult<T, E> captureWith<T, E>(
    T Function() computation,
    E Function(Object error, StackTrace stackTrace) onError,
  ) {
    try {
      return GResult<T, E>.success(computation());
    } catch (error, stackTrace) {
      return GResult<T, E>.failure(onError(error, stackTrace));
    }
  }

  /// Executes async [computation], mapping an error and stack trace to [E].
  ///
  /// The asynchronous counterpart to [captureWith].
  static Future<GResult<T, E>> captureAsyncWith<T, E>(
    Future<T> Function() computation,
    E Function(Object error, StackTrace stackTrace) onError,
  ) async {
    try {
      return GResult<T, E>.success(await computation());
    } catch (error, stackTrace) {
      return GResult<T, E>.failure(onError(error, stackTrace));
    }
  }

  /// Wraps a nullable [value], calling [onNull] to build the error for `null`.
  ///
  /// Example:
  /// ```dart
  /// final user = GResult.fromNullable<User, String>(
  ///   cache[id],
  ///   () => 'No cached user for $id',
  /// );
  /// ```
  static GResult<T, E> fromNullable<T extends Object, E>(
    T? value,
    E Function() onNull,
  ) =>
      value == null
          ? GResult<T, E>.failure(onNull())
          : GResult<T, E>.success(value);

  /// Returns `true` if this result is [GSuccess].
  bool get isSuccess => this is GSuccess<T, E>;

  /// Returns `true` if this result is [GFailure].
  bool get isFailure => this is GFailure<T, E>;

  /// Returns the success value if present, or `null`.
  T? get valueOrNull => switch (this) {
    GSuccess(:final value) => value,
    GFailure() => null,
  };

  /// Returns the failure error if present, or `null`.
  E? get errorOrNull => switch (this) {
    GSuccess() => null,
    GFailure(:final error) => error,
  };

  /// Returns the success value, or [fallback] if this is a [GFailure].
  T getOrElse(T fallback) => switch (this) {
    GSuccess(:final value) => value,
    GFailure() => fallback,
  };

  /// Transforms the success value using [fn].
  GResult<R, E> map<R>(R Function(T value) fn) => switch (this) {
    GSuccess(:final value) => GResult.success(fn(value)),
    GFailure(:final error) => GResult.failure(error),
  };

  /// Transforms the error using [fn].
  GResult<T, F> mapError<F>(F Function(E error) fn) => switch (this) {
    GSuccess(:final value) => GResult.success(value),
    GFailure(:final error) => GResult.failure(fn(error)),
  };

  /// Binds a function that returns a [GResult].
  GResult<R, E> flatMap<R>(GResult<R, E> Function(T value) fn) =>
      switch (this) {
        GSuccess(:final value) => fn(value),
        GFailure(:final error) => GResult.failure(error),
      };

  /// Pattern-matches over the result.
  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) => switch (this) {
    GSuccess(:final value) => onSuccess(value),
    GFailure(:final error) => onFailure(error),
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
  GResult<E, T> swap() => switch (this) {
    GSuccess(:final value) => GResult<E, T>.failure(value),
    GFailure(:final error) => GResult<E, T>.success(error),
  };

  /// Transforms whichever branch is present.
  ///
  /// Equivalent to `map(onSuccess).mapError(onFailure)` in one pass.
  GResult<R, F> mapBoth<R, F>({
    required R Function(T value) onSuccess,
    required F Function(E error) onFailure,
  }) => switch (this) {
    GSuccess(:final value) => GResult<R, F>.success(onSuccess(value)),
    GFailure(:final error) => GResult<R, F>.failure(onFailure(error)),
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
  GResult<T, E> filter(
    bool Function(T value) predicate, {
    required E Function(T value) orElse,
  }) => switch (this) {
    GSuccess(:final value) =>
      predicate(value) ? this : GResult<T, E>.failure(orElse(value)),
    GFailure() => this,
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
      case GSuccess(:final value):
        return value;
      case GFailure(:final error):
        if (error is Error) throw error;
        if (error is Exception) throw error;
        throw StateError('GResult was a failure: $error');
    }
  }
}

/// A successful [GResult] holding a [value].
final class GSuccess<T, E> extends GResult<T, E> {
  /// The success value.
  final T value;

  /// Creates a [GSuccess] instance with [value].
  const GSuccess(this.value);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GSuccess<T, E> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result.success($value)';
}

/// A failed [GResult] holding an [error].
final class GFailure<T, E> extends GResult<T, E> {
  /// The failure error.
  final E error;

  /// Creates a [GFailure] instance with [error].
  const GFailure(this.error);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GFailure<T, E> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Result.failure($error)';
}
