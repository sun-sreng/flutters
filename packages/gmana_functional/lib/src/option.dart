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

  /// Keeps the value only when [test] passes, otherwise becomes [None].
  ///
  /// ```dart
  /// Some(4).filter((n) => n.isEven);  // Some(4)
  /// Some(3).filter((n) => n.isEven);  // None
  /// ```
  Option<T> filter(bool Function(T value) test) =>
      fold(None<T>.new, (value) => test(value) ? this : None<T>());

  /// The inverse of [filter] — keeps the value only when [test] fails.
  Option<T> filterNot(bool Function(T value) test) =>
      filter((value) => !test(value));

  /// Returns this option when it is [Some], otherwise the result of [other].
  ///
  /// ```dart
  /// fromCache(id).orElse(() => fromDefaults(id));
  /// ```
  Option<T> orElse(Option<T> Function() other) => fold(other, (_) => this);

  /// Runs [f] with the value, if present, and returns this option unchanged.
  Option<T> tap(void Function(T value) f) {
    fold(() {}, f);
    return this;
  }

  /// Runs [f] when the value is absent, and returns this option unchanged.
  Option<T> tapNone(void Function() f) {
    fold(f, (_) {});
    return this;
  }

  /// Whether this is [Some] *and* [test] passes for its value.
  bool isSomeAnd(bool Function(T value) test) => fold(() => false, test);

  /// Pairs this value with the value of [other], if both are present.
  Option<(T, U)> zip<U>(Option<U> other) => zipWith(other, (a, b) => (a, b));

  /// Combines this value with the value of [other] through [combine],
  /// if both are present.
  Option<R> zipWith<U, R>(
    Option<U> other,
    R Function(T first, U second) combine,
  ) => flatMap((first) => other.map((second) => combine(first, second)));

  /// A single-element list for [Some], or an empty list for [None].
  List<T> toList() => fold(() => <T>[], (value) => <T>[value]);
}
