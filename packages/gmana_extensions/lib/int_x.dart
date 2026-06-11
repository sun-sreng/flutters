/// Core extensions on [int] adding digits access and iterative range utilities.
extension IntX on int {
  /// Number of decimal digits (ignores sign). Safe against integer overflows.
  int get digitCount => this == 0 ? 1 : abs().toString().length;

  /// Individual digits, most-significant first. Optimized mathematically.
  /// ```dart
  /// 1234.digits; // [1, 2, 3, 4]
  /// ```
  List<int> get digits {
    if (this == 0) return [0];

    final result = <int>[];
    var value = abs();
    while (value > 0) {
      result.add(value % 10);
      value ~/= 10;
    }
    return result.reversed.toList();
  }

  /// Returns true if this value is negative.
  bool get isNegative => this < 0;

  /// Returns true if this value is positive.
  bool get isPositive => this > 0;

  /// Returns true if this value is zero.
  bool get isZero => this == 0;

  /// Returns this value clamped to zero or above.
  int get nonNegative => this < 0 ? 0 : this;

  /// Returns this value clamped to zero or below.
  int get nonPositive => this > 0 ? 0 : this;

  /// Executes [action] exactly `this` times. Equivalent to a `for` loop.
  /// ```dart
  /// 3.times(() => print('hi')); // hi hi hi
  /// ```
  void times(void Function() action) {
    if (this <= 0) return;
    for (var i = 0; i < this; i++) {
      action();
    }
  }

  /// Executes [action] with the current zero-based index exactly `this` times.
  /// ```dart
  /// 3.timesIndexed((i) => print(i)); // 0 1 2
  /// ```
  void timesIndexed(void Function(int index) action) {
    if (this <= 0) return;
    for (var i = 0; i < this; i++) {
      action(i);
    }
  }

  /// Inclusive range as a lazy iterable. Handles both ascending and descending ranges.
  /// ```dart
  /// 1.to(5); // (1, 2, 3, 4, 5)
  /// 5.to(1); // (5, 4, 3, 2, 1)
  /// ```
  Iterable<int> to(int end, {int step = 1}) sync* {
    if (step <= 0) {
      throw ArgumentError.value(step, 'step', 'must be positive');
    }

    if (this <= end) {
      for (var i = this; i <= end; i += step) {
        yield i;
      }
    } else {
      for (var i = this; i >= end; i -= step) {
        yield i;
      }
    }
  }

  /// Returns true if this value is evenly divisible by [divisor].
  bool isDivisibleBy(int divisor) {
    if (divisor == 0) {
      throw ArgumentError.value(divisor, 'divisor', 'must not be zero');
    }
    return this % divisor == 0;
  }

  /// Returns true if this value is a multiple of [factor].
  bool isMultipleOf(int factor) => isDivisibleBy(factor);

  /// Returns true if this value is between [min] and [max] inclusively.
  bool isBetween(int min, int max) => this >= min && this <= max;

  /// Returns this value constrained to the inclusive range [[min], [max]].
  int clampInt(int min, int max) {
    if (max < min) {
      throw ArgumentError.value(
        max,
        'max',
        'must be greater than or equal to min',
      );
    }
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}
