import 'package:meta/meta.dart';

import 'either.dart';
import 'option.dart';
import 'right.dart';

/// Represents a present value of type [T].
@immutable
final class Some<T> extends Option<T> {
  /// The underlying value.
  final T value;

  /// Creates a [Some] instance with [value].
  const Some(this.value);

  @override
  bool isSome() => true;

  @override
  bool isNone() => false;

  @override
  Option<R> map<R>(R Function(T value) f) => Some(f(value));

  @override
  Option<R> flatMap<R>(Option<R> Function(T value) f) => f(value);

  @override
  B fold<B>(B Function() ifNone, B Function(T value) ifSome) => ifSome(value);

  @override
  T getOrElse(T Function() orElse) => value;

  @override
  Either<L, T> toEither<L>(L Function() onNone) => Right(value);

  @override
  T? toNullable() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Some<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Some($value)';
}
