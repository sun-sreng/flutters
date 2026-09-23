/// Range and ordering helpers for any self-comparable type
/// ([String], [DateTime], [Duration], and your own `Comparable` types).
///
/// Numeric types are excluded by the bound because `num` already provides
/// comparison operators and [num.clamp].
extension ComparableX<T extends Comparable<T>> on T {
  /// Whether this value sorts before [other].
  bool operator <(T other) => compareTo(other) < 0;

  /// Whether this value sorts before [other] or is equal to it.
  bool operator <=(T other) => compareTo(other) <= 0;

  /// Whether this value sorts after [other].
  bool operator >(T other) => compareTo(other) > 0;

  /// Whether this value sorts after [other] or is equal to it.
  bool operator >=(T other) => compareTo(other) >= 0;

  /// Constrains this value to the inclusive range [[min], [max]].
  ///
  /// ```dart
  /// 'm'.coerceIn('a', 'f'); // 'f'
  /// ```
  T coerceIn(T min, T max) {
    if (min.compareTo(max) > 0) {
      throw ArgumentError.value(
        max,
        'max',
        'must be greater than or equal to min',
      );
    }
    if (compareTo(min) < 0) return min;
    if (compareTo(max) > 0) return max;
    return this;
  }

  /// Returns [min] when this value sorts before it, otherwise this value.
  T coerceAtLeast(T min) => compareTo(min) < 0 ? min : this;

  /// Returns [max] when this value sorts after it, otherwise this value.
  T coerceAtMost(T max) => compareTo(max) > 0 ? max : this;

  /// Whether this value falls within [[min], [max]] inclusively.
  ///
  /// Named `isInRange` rather than `isBetween` because
  /// `StringDateExtension.isBetween` already claims that name on [String]
  /// with date-parsing semantics.
  bool isInRange(T min, T max) => compareTo(min) >= 0 && compareTo(max) <= 0;

  /// Whether this value falls strictly between [min] and [max].
  bool isInRangeExclusive(T min, T max) =>
      compareTo(min) > 0 && compareTo(max) < 0;

  /// The larger of this value and [other].
  T coerceMax(T other) => compareTo(other) >= 0 ? this : other;

  /// The smaller of this value and [other].
  T coerceMin(T other) => compareTo(other) <= 0 ? this : other;
}
