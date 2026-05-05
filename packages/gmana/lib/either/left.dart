import 'dart:async';

import 'either.dart';
import 'right.dart';

/// Represents the failure or error side of an [Either].
///
/// A `Left<L, R>` contains a value of type `L`, typically used to represent
/// an error or exceptional case. This is returned from methods that may fail,
/// instead of throwing exceptions.
///
/// Operations like [map] and [flatMap] are no-ops on `Left`, meaning they
/// return the same `Left` unchanged.
///
/// ### Example:
/// ```dart
/// Either<String, int> result = const Left('Something went wrong');
///
/// print(result.isLeft()); // true
/// print(result.isRight()); // false
/// print(result.getLeft()); // 'Something went wrong'
/// ```
class Left<L, R> extends Either<L, R> {
  /// The encapsulated value, typically representing an error or failure.
  final L value;

  /// Creates a [Left] with the given [value].
  const Left(this.value);

  @override
  Either<L2, R> mapLeft<L2>(L2 Function(L left) f) {
    return Left<L2, R>(f(value));
  }

  @override
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R right) f) {
    // Left stays unchanged during flatMap
    return Left<L, R2>(value);
  }

  @override
  Future<Either<L, R2>> flatMapAsync<R2>(
    FutureOr<Either<L, R2>> Function(R right) f,
  ) async {
    return Left<L, R2>(value);
  }

  @override
  Either<L2, R2> bimap<L2, R2>(
    L2 Function(L left) ifLeft,
    R2 Function(R right) ifRight,
  ) {
    return Left<L2, R2>(ifLeft(value));
  }

  @override
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) {
    return ifLeft(value);
  }

  @override
  L getLeft() {
    return value;
  }

  @override
  R getRight() {
    throw StateError('Cannot get a Right value from $this.');
  }

  @override
  bool isLeft() => true;

  @override
  bool isRight() => false;

  @override
  L? leftOrNull() => value;

  @override
  R? rightOrNull() => null;

  @override
  Either<L, R2> map<R2>(R2 Function(R right) f) {
    // Left stays unchanged during map
    return Left<L, R2>(value);
  }

  @override
  Future<Either<L, R2>> mapAsync<R2>(FutureOr<R2> Function(R right) f) async {
    return Left<L, R2>(value);
  }

  @override
  Either<R, L> swap() => Right<R, L>(value);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is Left &&
            other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Left($value)';
}
