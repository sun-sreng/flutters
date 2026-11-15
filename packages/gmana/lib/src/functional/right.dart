import 'dart:async';

import 'package:meta/meta.dart';

import 'either.dart';
import 'either_value_equality.dart';
import 'left.dart';

/// A concrete implementation of [Either] that represents the successful value (`Right`) in a computation.
///
/// Commonly used in functional programming to wrap a successful result, while the `Left` represents a failure or error.
///
/// Example usage:
/// ```dart
/// Either<String, int> result = Right(42);
/// print(result.isRight()); // true
/// ```
@immutable
class Right<L, R> extends Either<L, R> {
  /// The successful value held by this [Right].
  final R value;

  /// Creates a [Right] instance with the given [value].
  const Right(this.value);

  @override
  Either<L2, R> mapLeft<L2>(L2 Function(L left) f) {
    return Right<L2, R>(value);
  }

  /// Applies the given function [f] to the contained value, and flattens the result.
  ///
  /// Used for chaining operations that return an [Either].
  @override
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R right) f) {
    return f(value);
  }

  @override
  Future<Either<L, R2>> flatMapAsync<R2>(
    FutureOr<Either<L, R2>> Function(R right) f,
  ) async {
    return f(value);
  }

  @override
  Either<L2, R2> bimap<L2, R2>(
    L2 Function(L left) ifLeft,
    R2 Function(R right) ifRight,
  ) {
    return Right<L2, R2>(ifRight(value));
  }

  /// Applies [ifRight] to the contained value and returns its result.
  ///
  /// Since this is a [Right], [ifLeft] is ignored.
  @override
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) {
    return ifRight(value);
  }

  /// Throws a [StateError] because this is a [Right] and does not contain a [Left] value.
  ///
  /// Use [getRight] if you expect the right value.
  @override
  L getLeft() {
    throw StateError('Cannot get a Left value from $this.');
  }

  /// Returns the contained value.
  @override
  R getRight() => value;

  /// Always returns `false` because this is a [Right].
  @override
  bool isLeft() => false;

  /// Always returns `true` because this is a [Right].
  @override
  bool isRight() => true;

  @override
  L? leftOrNull() => null;

  @override
  R? rightOrNull() => value;

  /// Transforms the contained value using the provided function [f], returning a new [Right].
  @override
  Either<L, R2> map<R2>(R2 Function(R right) f) {
    return Right<L, R2>(f(value));
  }

  @override
  Future<Either<L, R2>> mapAsync<R2>(FutureOr<R2> Function(R right) f) async {
    return Right<L, R2>(await f(value));
  }

  @override
  Either<R, L> swap() => Left<R, L>(value);

  /// Whether [other] is a [Right] with an equal value.
  ///
  /// Type arguments are not compared, so the result is the same either way
  /// round. Two list values are equal when their elements are, in order.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right && eitherValueEquals(value, other.value);

  @override
  int get hashCode => Object.hash(Right, eitherValueHash(value));

  @override
  String toString() => 'Right($value)';
}
