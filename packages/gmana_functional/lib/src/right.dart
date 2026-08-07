import 'dart:async';

import 'package:meta/meta.dart';

import 'either.dart';
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Right<L, R>) return false;
    final otherVal = other.value;
    if (value is List && otherVal is List) {
      final listA = value as List;
      final listB = otherVal as List;
      if (listA.length != listB.length) return false;
      for (var i = 0; i < listA.length; i++) {
        if (listA[i] != listB[i]) return false;
      }
      return true;
    }
    return value == otherVal;
  }



  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Right($value)';
}
