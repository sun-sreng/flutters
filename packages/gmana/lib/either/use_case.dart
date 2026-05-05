import '../gmana.dart';

/// A singleton instance representing a unit of work with no meaningful value.
///
/// Similar to `void`, but usable in functional chains and as a return type in [Either].
const unit = Unit._unit;

/// A type alias for an [Either] that has [Failure] as its `Left` type and [T] as its `Right` type.
///
/// Typically used for functions that may fail and return a result of type [T] on success.
typedef EitherFailure<T> = Either<Failure, T>;

/// A type alias for a `Map<String, dynamic>` often used for generic JSON-like objects or data payloads.
typedef GMap = Map<String, dynamic>;

/// A type alias for a `Future` that completes with an [EitherFailure].
///
/// Used for asynchronous operations that can fail and return a result of type [T].
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// A shorthand for a [FutureEither] that completes with a [Unit] result.
///
/// Represents asynchronous operations that return no value on success.
typedef FutureEitherUnit = FutureEither<Unit>;

/// A type alias for a `Stream` that emits fallible values.
///
/// Used for streaming operations that can emit successful values or failures.
typedef StreamEither<T> = Stream<Either<Failure, T>>;

/// A shorthand for a [StreamEither] that emits [Unit] success values.
typedef StreamEitherUnit = StreamEither<Unit>;

/// Represents a failure in an operation, usually as the `Left` value of an [Either].
///
/// Contains a human-readable error [message], optional machine-readable [code],
/// and optional structured [details].
class Failure {
  /// The error message describing the failure.
  final String message;

  /// An optional stable code for programmatic error handling.
  final String? code;

  /// Optional structured metadata describing the failure.
  final GMap details;

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
  /// Executes the use case with the given [params] and returns a [StreamEither] result.
  StreamEither<SuccessType> call(Params params);
}

/// Represents a void-like value in functional programming.
///
/// Used to indicate success where no meaningful value is returned (similar to `void` in Dart).
final class Unit {
  static const Unit _unit = Unit._instance();

  /// Private constant constructor.
  const Unit._instance();

  @override
  int get hashCode => 1;

  @override
  bool operator ==(Object other) => other is Unit;

  /// String representation of [Unit] — returns `'()'`.
  @override
  String toString() => '()';
}

/// A contract for defining use cases (application business logic) in a clean architecture approach.
///
/// [SuccessType] is the type returned on success, and [Params] is the type of the input parameters.
///
/// Use cases should return a [FutureEither] to indicate both asynchronous and fallible behavior.
abstract interface class UseCase<SuccessType, Params> {
  /// Executes the use case with the given [params] and returns a [FutureEither] result.
  FutureEither<SuccessType> call(Params params);
}

bool _mapEquals(GMap left, GMap right) {
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
