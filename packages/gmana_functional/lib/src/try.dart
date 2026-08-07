import 'package:meta/meta.dart';

import '../gmana_functional.dart';

/// The `Try<T>` monad represents a computation that may result in an exception or a value `T`.
@immutable
sealed class Try<T> {
  const Try();

  /// Executes [fn] synchronously, returning `TrySuccess(value)` on success or `TryFailure(error, stackTrace)` on exception.
  static Try<T> of<T>(T Function() fn) {
    try {
      return TrySuccess(fn());
    } catch (e, st) {
      return TryFailure(e, st);
    }
  }

  /// Whether this [Try] succeeded.
  bool get isSuccess => this is TrySuccess<T>;

  /// Whether this [Try] failed.
  bool get isFailure => this is TryFailure<T>;

  /// Returns the value if successful, or `null` if failed.
  T? getOrNull() => switch (this) {
        TrySuccess(:final value) => value,
        TryFailure() => null,
      };

  /// Returns the value if successful, or [fallback] if failed.
  T getOrElse(T fallback) => switch (this) {
        TrySuccess(:final value) => value,
        TryFailure() => fallback,
      };

  /// Maps the value `T` to `R` if successful.
  Try<R> map<R>(R Function(T value) fn) {
    return switch (this) {
      TrySuccess(:final value) => Try.of(() => fn(value)),
      TryFailure(:final error, :final stackTrace) => TryFailure(error, stackTrace),
    };
  }

  /// Chains another [Try] computation produced by [fn] if successful.
  Try<R> flatMap<R>(Try<R> Function(T value) fn) {
    return switch (this) {
      TrySuccess(:final value) => () {
          try {
            return fn(value);
          } catch (e, st) {
            return TryFailure<R>(e, st);
          }
        }(),
      TryFailure(:final error, :final stackTrace) => TryFailure<R>(error, stackTrace),
    };
  }

  /// Converts this [Try] to an [Option].
  Option<T> toOption() => switch (this) {
        TrySuccess(:final value) => Some(value),
        TryFailure() => const None(),
      };

  /// Converts this [Try] to an [Either].
  Either<Object, T> toEither() => switch (this) {
        TrySuccess(:final value) => Right(value),
        TryFailure(:final error) => Left(error),
      };
}

/// Successful outcome holding a value [T].
@immutable
final class TrySuccess<T> extends Try<T> {
  /// The value produced.
  final T value;

  /// Creates a [TrySuccess].
  const TrySuccess(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrySuccess<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Try.success($value)';
}

/// Failed outcome holding an error [Object] and [StackTrace].
@immutable
final class TryFailure<T> extends Try<T> {
  /// The caught error object.
  final Object error;

  /// The stack trace.
  final StackTrace stackTrace;

  /// Creates a [TryFailure].
  const TryFailure(this.error, [this.stackTrace = StackTrace.empty]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TryFailure<T> &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Try.failure($error)';
}

