import 'package:meta/meta.dart';

import 'either.dart';
import 'none.dart';
import 'some.dart';

/// Represents an optional value of type [T] that may be present ([Some]) or absent ([None]).
@immutable
abstract class Option<T> {
  /// Creates an [Option] instance.
  const Option();

  /// Constructs an [Option] from a nullable [value].
  /// Returns [Some] if [value] is non-null, or [None] if [value] is null.
  factory Option.fromNullable(T? value) {
    if (value == null) return None<T>();
    return Some<T>(value);
  }

  /// Returns `true` if this option is [Some].
  bool isSome();

  /// Returns `true` if this option is [None].
  bool isNone();

  /// Maps the contained value using [f] if present.
  Option<R> map<R>(R Function(T value) f);

  /// Flat maps the contained value using [f] if present.
  Option<R> flatMap<R>(Option<R> Function(T value) f);

  /// Folds this option into [B] using [ifNone] or [ifSome].
  B fold<B>(B Function() ifNone, B Function(T value) ifSome);

  /// Returns the contained value if present, or [orElse] computation if absent.
  T getOrElse(T Function() orElse);

  /// Converts this option to [Either<L, T>].
  Either<L, T> toEither<L>(L Function() onNone);

  /// Returns the contained value if present, or `null` if absent.
  T? toNullable();
}
