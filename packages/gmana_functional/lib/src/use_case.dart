import 'dart:async';

import 'package:meta/meta.dart';

import 'either.dart';

/// A singleton instance representing a unit of work with no meaningful value.
///
/// Similar to `void`, but usable in functional chains and as a return type in [Either].
const unit = Unit._unit;

/// A standard fallible result with [Failure] on the left and [T] on the right.
///
/// Use `Right` for success and `Left` for failure.
typedef Result<T> = Either<Failure, T>;

/// A [Result] for operations that return no meaningful success value.
typedef ResultUnit = Result<Unit>;

/// A future that completes with a fallible [Result].
///
/// Used for asynchronous operations that can fail and return a result of type [T].
typedef FutureResult<T> = Future<Result<T>>;

/// A [FutureResult] for operations that return no meaningful success value.
///
/// Represents asynchronous operations that return no value on success.
typedef FutureResultUnit = FutureResult<Unit>;

/// A stream that emits fallible [Result] values.
///
/// Used for streaming operations that can emit successful values or failures.
typedef StreamResult<T> = Stream<Result<T>>;

/// A [StreamResult] for streams that emit no meaningful success value.
typedef StreamResultUnit = StreamResult<Unit>;

/// Represents a failure in an operation, usually as the `Left` value of an [Either].
///
/// Contains a human-readable error [message], optional machine-readable [code],
/// and optional structured [details].
@immutable
class Failure {
  /// The error message describing the failure.
  final String message;

  /// An optional stable code for programmatic error handling.
  final String? code;

  /// Optional structured metadata describing the failure.
  final Map<String, dynamic> details;

  /// Creates a [Failure] with an optional [message]. Defaults to a generic error message.
  const Failure([
    this.message = 'An unexpected error occurred.',
    this.code,
    this.details = const {},
  ]);

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    code,
    Object.hashAllUnordered(
      details.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is Failure &&
            other.message == message &&
            other.code == code &&
            _mapEquals(other.details, details);
  }

  @override
  String toString() {
    final buffer = StringBuffer('Failure(message: $message');

    if (code != null) {
      buffer.write(', code: $code');
    }

    if (details.isNotEmpty) {
      buffer.write(', details: $details');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// A class that represents a lack of parameters.
///
/// Useful when a [UseCase] requires no input but must still follow a uniform interface.
@immutable
class NoParams {
  /// Creates a [NoParams] marker value.
  const NoParams();

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  String toString() => 'NoParams()';
}

/// A contract for defining streaming use cases.
///
/// Use this when a use case emits multiple values over time and each emission
/// can independently succeed or fail.
abstract interface class StreamUseCase<SuccessType, Params> {
  /// Executes the use case with the given [params] and returns a [StreamResult] result.
  StreamResult<SuccessType> call(Params params);
}

/// Represents a void-like value in functional programming.
///
/// Used to indicate success where no meaningful value is returned (similar to `void` in Dart).
@immutable
final class Unit {
  static const Unit _unit = Unit._instance();

  /// Private constant constructor.
  const Unit._instance();

  @override
  int get hashCode => 1;

  @override
  bool operator ==(Object other) => other is Unit;

  /// String representation of [Unit] - returns `'()'`.
  @override
  String toString() => '()';
}

/// A contract for defining use cases (application business logic) in a clean architecture approach.
///
/// [SuccessType] is the type returned on success, and [Params] is the type of the input parameters.
///
/// Use cases should return a [FutureResult] to indicate both asynchronous and fallible behavior.
abstract interface class UseCase<SuccessType, Params> {
  /// Executes the use case with the given [params] and returns a [FutureResult] result.
  FutureResult<SuccessType> call(Params params);
}

bool _mapEquals(Map<String, dynamic> left, Map<String, dynamic> right) {
  if (identical(left, right)) {
    return true;
  }

  if (left.length != right.length) {
    return false;
  }

  for (final entry in left.entries) {
    if (!right.containsKey(entry.key) || right[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}
