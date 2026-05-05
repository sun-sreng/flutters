import 'dart:async';

/// A generic type that represents a value of one of two possible types (a disjoint union).
///
/// Instances of `Either` are either an instance of [Left] or [Right].
/// - [Left] is used to represent failure, typically holding an error or exception.
/// - [Right] is used to represent success, typically holding a valid result.
///
/// `Either<L, R>` is commonly used as a functional alternative to throwing exceptions.
///
/// ### Example:
/// ```dart
/// void main() {
///   final result1 = divide(10, 2);
///   final result2 = divide(5, 0);
///
///   result1.fold(
///     (error) => print('Error: $error'),
///     (value) => print('Result: $value'),
///   ); // Prints: Result: 5
///
///   result2.fold(
///     (error) => print('Error: $error'),
///     (value) => print('Result: $value'),
///   ); // Prints: Error: Cannot divide by zero
///
///   // Using map
///   final mappedResult = result1.map((value) => value * 2);
///   print(mappedResult.getRight()); // Prints: 10
/// }
///
/// Either<String, int> divide(int a, int b) {
///   if (b == 0) {
///     return const Left('Cannot divide by zero');
///   } else {
///     return Right(a ~/ b);
///   }
/// }
/// ```
abstract class Either<L, R> {
  /// Creates an [Either] instance.
  const Either();

  /// Maps the [Left] value using [f], if present.
  ///
  /// If this is a [Right], the same successful value is returned unchanged.
  Either<L2, R> mapLeft<L2>(L2 Function(L left) f);

  /// Applies the function [f] to the value contained in [Right], if it exists,
  /// and returns a new [Either] containing the result. If this is a [Left],
  /// it is returned unchanged.
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R right) f);

  /// Asynchronously applies [f] to the [Right] value, if present.
  ///
  /// If this is a [Left], the left value is returned unchanged.
  Future<Either<L, R2>> flatMapAsync<R2>(
    FutureOr<Either<L, R2>> Function(R right) f,
  );

  /// Applies [ifLeft] or [ifRight] and returns a new [Either] with mapped values.
  Either<L2, R2> bimap<L2, R2>(
    L2 Function(L left) ifLeft,
    R2 Function(R right) ifRight,
  );

  /// Applies one of two functions depending on whether this is a [Left] or [Right].
  ///
  /// - If this is a [Left], returns `ifLeft(left)`.
  /// - If this is a [Right], returns `ifRight(right)`.
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight);

  /// Asynchronously applies one of two functions depending on the side present.
  Future<B> foldAsync<B>(
    FutureOr<B> Function(L left) ifLeft,
    FutureOr<B> Function(R right) ifRight,
  ) async {
    return fold(ifLeft, ifRight);
  }

  /// Returns the [Left] value if this is a [Left], otherwise throws.
  L getLeft();

  /// Returns the [Right] value if this is a [Right], otherwise throws.
  R getRight();

  /// Returns the [Left] value if this is a [Left], otherwise `null`.
  L? leftOrNull();

  /// Returns the [Right] value if this is a [Right], otherwise `null`.
  R? rightOrNull();

  /// Returns the [Right] value if this is a [Right], otherwise `null`.
  R? getOrNull() => rightOrNull();

  /// Returns the [Right] value if this is a [Right], otherwise computes a fallback.
  R getOrElse(R Function(L left) orElse) => fold(orElse, (right) => right);

  /// Returns `true` when this is a [Right] containing [value].
  bool contains(R value) => fold((left) => false, (right) => right == value);

  /// Returns `true` when this is a [Right] and [test] passes.
  bool exists(bool Function(R right) test) => fold((left) => false, test);

  /// Returns `true` when this is a [Left] or when [test] passes for the [Right] value.
  bool all(bool Function(R right) test) => fold((left) => true, test);

  /// Returns `true` if this is a [Left].
  bool isLeft();

  /// Returns `true` if this is a [Right].
  bool isRight();

  /// Transforms the value contained in [Right] using the given function [f],
  /// returning a new [Either] with the transformed value.
  ///
  /// If this is a [Left], the same instance is returned unchanged.
  Either<L, R2> map<R2>(R2 Function(R right) f);

  /// Asynchronously transforms the [Right] value using [f], if present.
  ///
  /// If this is a [Left], the left value is returned unchanged.
  Future<Either<L, R2>> mapAsync<R2>(FutureOr<R2> Function(R right) f);

  /// Runs [f] with the [Right] value, if present, and returns this [Either].
  Either<L, R> tap(void Function(R right) f) {
    if (isRight()) {
      f(getRight());
    }

    return this;
  }

  /// Runs [f] with the [Left] value, if present, and returns this [Either].
  Either<L, R> tapLeft(void Function(L left) f) {
    if (isLeft()) {
      f(getLeft());
    }

    return this;
  }

  /// Swaps the sides of this [Either], turning [Left] into [Right] and vice versa.
  Either<R, L> swap();
}
