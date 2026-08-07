import 'dart:async';

import '../gmana_functional.dart' show Left, None, Option, Right, Some;

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

  /// Executes [fn] and catches any exception, returning [Right] on success
  /// or [Left(onError(error, stackTrace))] on failure.
  static Either<L, R> tryCatch<L, R>(
    R Function() fn,
    L Function(Object error, StackTrace stackTrace) onError,
  ) {
    try {
      return Right(fn());
    } catch (error, stackTrace) {
      return Left(onError(error, stackTrace));
    }
  }

  /// Asynchronously executes [fn] and catches any exception, returning [Right] on success
  /// or [Left(onError(error, stackTrace))] on failure.
  static Future<Either<L, R>> tryCatchAsync<L, R>(
    FutureOr<R> Function() fn,
    L Function(Object error, StackTrace stackTrace) onError,
  ) async {
    try {
      final value = await fn();
      return Right(value);
    } catch (error, stackTrace) {
      return Left(onError(error, stackTrace));
    }
  }

  /// Builds a [Right] from [ifTrue] when [test] holds, otherwise a [Left]
  /// from [ifFalse].
  ///
  /// ```dart
  /// Either.cond(age >= 18, () => 'Too young', () => age);
  /// ```
  static Either<L, R> cond<L, R>(
    // ignore: avoid_positional_boolean_parameters
    bool test,
    L Function() ifFalse,
    R Function() ifTrue,
  ) => test ? Right<L, R>(ifTrue()) : Left<L, R>(ifFalse());

  /// Lifts a nullable [value] into an [Either], using [onNull] for the
  /// [Left] side.
  ///
  /// ```dart
  /// Either.fromNullable(map['id'], () => 'Missing id');
  /// ```
  static Either<L, R> fromNullable<L, R>(R? value, L Function() onNull) =>
      value == null ? Left<L, R>(onNull()) : Right<L, R>(value);

  /// Collapses [items] into a single [Either] holding every [Right] value.
  ///
  /// Short-circuits on the first [Left], which is what you want when any one
  /// failure invalidates the whole batch.
  ///
  /// ```dart
  /// Either.sequence([Right(1), Right(2)]);          // Right([1, 2])
  /// Either.sequence([Right(1), Left('bad'), ...]);  // Left('bad')
  /// ```
  static Either<L, List<R>> sequence<L, R>(Iterable<Either<L, R>> items) {
    final values = <R>[];
    for (final item in items) {
      if (item.isLeft()) return Left<L, List<R>>(item.getLeft());
      values.add(item.getRight());
    }
    return Right<L, List<R>>(values);
  }

  /// Applies [f] to every element of [items] and sequences the results.
  ///
  /// Short-circuits on the first [Left].
  static Either<L, List<R2>> traverse<L, R, R2>(
    Iterable<R> items,
    Either<L, R2> Function(R item) f,
  ) => sequence(items.map(f));

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

  // --- Recovery ---

  /// Returns this [Either] when it is a [Right], otherwise the result of [f].
  ///
  /// The functional counterpart of a `catch` that can itself fail.
  ///
  /// ```dart
  /// fromCache(id).orElse((_) => fromNetwork(id));
  /// ```
  Either<L, R> orElse(Either<L, R> Function(L left) f) => fold(f, (_) => this);

  /// Like [orElse] but the recovery may produce a different [Left] type.
  Either<L2, R> orElseWith<L2>(Either<L2, R> Function(L left) f) =>
      fold(f, Right<L2, R>.new);

  /// Turns a [Left] into a [Right] by computing a fallback value.
  ///
  /// Unlike [orElse] this always succeeds.
  Either<L, R> recover(R Function(L left) f) =>
      fold((left) => Right<L, R>(f(left)), (_) => this);

  /// Chains on the [Left] side — the mirror of [flatMap].
  Either<L2, R> flatMapLeft<L2>(Either<L2, R> Function(L left) f) =>
      fold(f, Right<L2, R>.new);

  // --- Refinement ---

  /// Demotes a [Right] to a [Left] when [test] fails.
  ///
  /// ```dart
  /// Right(-1).filterOrElse((n) => n > 0, (n) => 'Must be positive');
  /// // Left('Must be positive')
  /// ```
  Either<L, R> filterOrElse(
    bool Function(R right) test,
    L Function(R right) onFalse,
  ) => fold(
    (_) => this,
    (right) => test(right) ? this : Left<L, R>(onFalse(right)),
  );

  // --- Combining ---

  /// Pairs the [Right] values of this and [other].
  ///
  /// Returns the first [Left] encountered, this one taking precedence.
  Either<L, (R, R2)> zip<R2>(Either<L, R2> other) =>
      zipWith(other, (a, b) => (a, b));

  /// Combines the [Right] values of this and [other] through [combine].
  ///
  /// Returns the first [Left] encountered, this one taking precedence.
  Either<L, R3> zipWith<R2, R3>(
    Either<L, R2> other,
    R3 Function(R first, R2 second) combine,
  ) => flatMap((first) => other.map((second) => combine(first, second)));

  // --- Conversion ---

  /// Returns the [Right] value, or [defaultValue] when this is a [Left].
  ///
  /// The eager counterpart of [getOrElse].
  R getOrDefault(R defaultValue) => fold((_) => defaultValue, (right) => right);

  /// Discards the [Left] value, keeping only whether a [Right] was present.
  Option<R> toOption() => fold((_) => None<R>(), Some<R>.new);

  /// A single-element list for a [Right], or an empty list for a [Left].
  List<R> toList() => fold((_) => <R>[], (right) => <R>[right]);
}
