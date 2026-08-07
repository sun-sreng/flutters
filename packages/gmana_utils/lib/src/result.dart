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

