import 'package:meta/meta.dart';

import 'either.dart';
import 'left.dart';
import 'option.dart';

/// Represents an absent value of type [T].
@immutable
final class None<T> extends Option<T> {
  /// Creates a [None] instance.
  const None();

  @override
  bool isSome() => false;

  @override
  bool isNone() => true;

  @override
  Option<R> map<R>(R Function(T value) f) => None<R>();

  @override
  Option<R> flatMap<R>(Option<R> Function(T value) f) => None<R>();

  @override
  B fold<B>(B Function() ifNone, B Function(T value) ifSome) => ifNone();

  @override
  T getOrElse(T Function() orElse) => orElse();

  @override
  Either<L, T> toEither<L>(L Function() onNone) => Left(onNone());

  @override
  T? toNullable() => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is None<T> && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'None';
}
