import 'none.dart';
import 'option.dart';
import 'some.dart';

/// Batch operations over a collection of [Option] values.
extension IterableOptionX<T> on Iterable<Option<T>> {
  /// Collapses the collection into one [Option] holding every value,
  /// short-circuiting to [None] on the first absent value.
  ///
  /// ```dart
  /// [Some(1), Some(2)].sequence();  // Some([1, 2])
  /// [Some(1), None<int>()].sequence();  // None
  /// ```
  Option<List<T>> sequence() {
    final result = <T>[];
    for (final option in this) {
      final present = option.fold(() => false, (value) {
        result.add(value);
        return true;
      });
      if (!present) return None<List<T>>();
    }
    return Some<List<T>>(result);
  }

  /// Every present value, discarding the absent ones.
  ///
  /// The lenient counterpart of [sequence].
  List<T> get values => [for (final option in this) ...option.toList()];

  /// The first present value, or [None] when every element is absent.
  Option<T> get firstSome {
    for (final option in this) {
      if (option.isSome()) return option;
    }
    return None<T>();
  }
}

/// Lifts a nullable value into an [Option].
extension NullableOptionX<T extends Object> on T? {
  /// Wraps this value in [Some], or [None] when it is `null`.
  ///
  /// The entry point from ordinary nullable Dart into the [Option] API.
  ///
  /// ```dart
  /// map['id'].toOption().map(int.parse).getOrElse(() => 0);
  /// ```
  Option<T> toOption() {
    final self = this;
    return self == null ? None<T>() : Some<T>(self);
  }
}
