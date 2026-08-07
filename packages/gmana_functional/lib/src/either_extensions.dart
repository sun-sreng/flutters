import 'dart:async';

import 'either.dart';
import 'left.dart';
import 'right.dart';

/// Chains [Either] operations across an awaited boundary.
///
/// Repository calls almost always return `Future<Either<L, R>>`, which forces
/// an `await` before every step. These mirror the synchronous [Either] API so
/// a pipeline stays one expression:
///
/// ```dart
/// final name = await repo
///     .fetchUser(id)
///     .map((user) => user.name)
///     .getOrElse((failure) => 'Unknown');
/// ```
extension FutureEitherX<L, R> on Future<Either<L, R>> {
  /// Transforms the [Right] value once this future completes.
  Future<Either<L, R2>> map<R2>(FutureOr<R2> Function(R right) f) async =>
      (await this).mapAsync(f);

  /// Transforms the [Left] value once this future completes.
  Future<Either<L2, R>> mapLeft<L2>(FutureOr<L2> Function(L left) f) async {
    final either = await this;
    return either.fold(
      (left) async => Left<L2, R>(await f(left)),
      (right) async => Right<L2, R>(right),
    );
  }

  /// Chains another fallible step onto the [Right] value.
  Future<Either<L, R2>> flatMap<R2>(
    FutureOr<Either<L, R2>> Function(R right) f,
  ) async => (await this).flatMapAsync(f);

  /// Collapses both sides into a single value.
  Future<B> fold<B>(
    FutureOr<B> Function(L left) ifLeft,
    FutureOr<B> Function(R right) ifRight,
  ) async => (await this).foldAsync(ifLeft, ifRight);

  /// The [Right] value, or the result of [orElse] for a [Left].
  Future<R> getOrElse(FutureOr<R> Function(L left) orElse) async =>
      fold(orElse, (right) => right);

  /// The [Right] value, or [defaultValue] for a [Left].
  Future<R> getOrDefault(R defaultValue) async =>
      (await this).getOrDefault(defaultValue);

  /// The [Right] value, or `null` for a [Left].
  Future<R?> getOrNull() async => (await this).getOrNull();

  /// Runs [f] with the [Right] value, if present, and passes the [Either] on.
  Future<Either<L, R>> tap(FutureOr<void> Function(R right) f) async {
    final either = await this;
    if (either.isRight()) await f(either.getRight());
    return either;
  }

  /// Runs [f] with the [Left] value, if present, and passes the [Either] on.
  Future<Either<L, R>> tapLeft(FutureOr<void> Function(L left) f) async {
    final either = await this;
    if (either.isLeft()) await f(either.getLeft());
    return either;
  }

  /// Recovers a [Left] with another fallible step.
  Future<Either<L, R>> orElseWith(
    FutureOr<Either<L, R>> Function(L left) f,
  ) async {
    final either = await this;
    return either.isLeft() ? await f(either.getLeft()) : either;
  }

  /// Whether this completed with a [Right].
  Future<bool> get isRight async => (await this).isRight();

  /// Whether this completed with a [Left].
  Future<bool> get isLeft async => (await this).isLeft();
}

/// Batch operations over a collection of [Either] values.
extension IterableEitherX<L, R> on Iterable<Either<L, R>> {
  /// Collapses the collection into one [Either] holding every [Right] value,
  /// short-circuiting on the first [Left].
  ///
  /// The instance-side counterpart of [Either.sequence].
  Either<L, List<R>> sequence() => Either.sequence(this);

  /// Every [Left] value, in order.
  List<L> get lefts => [
    for (final either in this)
      if (either.isLeft()) either.getLeft(),
  ];

  /// Every [Right] value, in order.
  List<R> get rights => [
    for (final either in this)
      if (either.isRight()) either.getRight(),
  ];

  /// Splits into `(lefts, rights)` in a single pass.
  ///
  /// Use this instead of [sequence] when you want to report *every* failure
  /// rather than stopping at the first one.
  (List<L> lefts, List<R> rights) partitionEithers() {
    final leftValues = <L>[];
    final rightValues = <R>[];

    for (final either in this) {
      either.fold(leftValues.add, rightValues.add);
    }

    return (leftValues, rightValues);
  }

  /// Whether every element is a [Right]. Vacuously true when empty.
  bool get allRight => every((either) => either.isRight());

  /// Whether any element is a [Left].
  bool get anyLeft => any((either) => either.isLeft());
}
