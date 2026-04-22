import 'dart:math';

/// Extensions for nullable [bool] values providing safe defaults.
extension BoolNullableX on bool? {
  /// Checks if the value is null or false.
  bool get isNullOrFalse => this == null || this == false;

  /// Returns the value or `false` if null.
  bool get orFalse => this ?? false;

  /// Returns the value or `true` if null.
  bool get orTrue => this ?? true;
}

/// Extensions for nullable [double] values providing safe defaults.
extension DoubleNullableX on double? {
  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0.0;

  /// Returns the value or `0.0` if null.
  double get orZero => this ?? 0.0;

  /// Returns the value or [fallback] if null.
  double orDefault(double fallback) => this ?? fallback;
}

/// Extensions for nullable [int] values providing safe defaults.
extension IntNullableX on int? {
  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0;

  /// Returns the value or `0` if null.
  int get orZero => this ?? 0;

  /// Returns the value or [fallback] if null.
  int orDefault(int fallback) => this ?? fallback;
}

/// Core extensions on [int] adding parity checks, digits access, and iterative utilities.
extension IntX on int {
  // Parity
  /// Number of decimal digits (ignores sign).
  int get digitCount => this == 0 ? 1 : (log(abs()) / ln10).floor() + 1;

  /// Individual digits, most-significant first.
  /// ```dart
  /// 1234.digits; // [1, 2, 3, 4]
  /// ```
  List<int> get digits =>
      toString().replaceAll('-', '').split('').map(int.parse).toList();

  // Digits
  /// Returns true if the number is even.
  bool get isEven => this % 2 == 0; // mirrors dart core, but handy in chains

  /// Returns true if the number is odd.
  bool get isOdd => this % 2 != 0;

  // Range helpers
  /// Checks if the integer is between [min] and [max] inclusively.
  bool isBetween(int min, int max) => this >= min && this <= max;

  /// Executes [action] [this] times. Equivalent to a `for` loop.
  /// ```dart
  /// 3.times(() => print('hi')); // hi hi hi
  /// ```
  void times(void Function() action) {
    for (var i = 0; i < this; i++) {
      action();
    }
  }

  /// Inclusive range as a lazy iterable.
  /// ```dart
  /// 1.to(5); // (1, 2, 3, 4, 5)
  /// ```
  Iterable<int> to(int end, {int step = 1}) sync* {
    assert(step > 0, 'step must be positive');
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
}

// ─── int ─────────────────────────────────────────────────────────────────

/// Extensions for nullable [num] values providing safe defaults.
extension NumNullableX on num? {
  /// Checks if the value is null or zero.
  bool get isNullOrZero => this == null || this == 0;

  /// Returns the value or `0` if null.
  num get orZero => this ?? 0;

  /// Returns the value or [fallback] if null.
  num orDefault(num fallback) => this ?? fallback;
}

// ─── num (shared int + double) ────────────────────────────────────────────

/// Shared mathematical, formatting, and conversion extensions on [num] (covering both int and double).
extension NumX on num {
  // ── Temperature ────────────────────────────────────────────────────────

  /// Converts Celsius to Fahrenheit.
  double get celsiusToFahrenheit => this * 9 / 5 + 32;

  /// Converts Celsius to Kelvin.
  double get celsiusToKelvin => toDouble() + 273.15;

  /// Converts Fahrenheit to Celsius.
  double get fahrenheitToCelsius => (this - 32) * 5 / 9;

  /// Converts Fahrenheit to Kelvin.
  double get fahrenheitToKelvin => fahrenheitToCelsius.celsiusToKelvin;

  /// Checks if the number is a whole number (has no fractional part).
  bool get isWholeNumber => this % 1 == 0;

  /// Converts Kelvin to Celsius.
  double get kelvinToCelsius => toDouble() - 273.15;

  // ── Rounding ────────────────────────────────────────────────────────────

  /// Converts Kelvin to Fahrenheit.
  double get kelvinToFahrenheit => kelvinToCelsius.celsiusToFahrenheit;

  /// Ceil to the nearest [multiple].
  num ceilToMultiple(num multiple) => (this / multiple).ceil() * multiple;

  /// Floor to the nearest [multiple].
  num floorToMultiple(num multiple) => (this / multiple).floor() * multiple;

  /// Checks if the number is between [min] and [max] inclusively.
  bool isBetween(num min, num max) => this >= min && this <= max;

  // ── Normalization ───────────────────────────────────────────────────────

  /// Linear interpolation between [a] and [b] where [this] is `t ∈ [0, 1]`.
  /// ```dart
  /// 0.25.lerp(0, 100); // 25.0
  /// ```
  double lerp(num a, num b) => (a + (b - a) * this).toDouble();

  /// Normalizes this value from `[fromMin, fromMax]` into `[toMin, toMax]`.
  double normalized(
    num fromMin,
    num fromMax, [
    num toMin = 0.0,
    num toMax = 1.0,
  ]) {
    final range = fromMax - fromMin;
    if (range == 0) {
      throw ArgumentError(
        'Source range cannot be zero (fromMin == fromMax == $fromMin)',
      );
    }
    return ((toMax - toMin) * ((this - fromMin) / range) + toMin).toDouble();
  }

  /// Same as [normalized] but clamps the result to `[toMin, toMax]`.
  double normalizedClamped(
    num fromMin,
    num fromMax, [
    num toMin = 0.0,
    num toMax = 1.0,
  ]) => normalized(
    fromMin,
    fromMax,
    toMin,
    toMax,
  ).clamp(toMin.toDouble(), toMax.toDouble());

  // ── Predicates ──────────────────────────────────────────────────────────

  /// Rounds to [places] decimal places.
  /// ```dart
  /// 3.14159.roundTo(2); // 3.14
  /// ```
  double roundTo(int places) {
    final factor = pow(10, places).toDouble();
    return (this * factor).round() / factor;
  }

  /// Rounds to the nearest [multiple].
  /// ```dart
  /// 27.roundToMultiple(5); // 25
  /// 28.roundToMultiple(5); // 30
  /// ```
  num roundToMultiple(num multiple) => (this / multiple).round() * multiple;

  // ── Misc ────────────────────────────────────────────────────────────────

  /// Like [normalized] but returns [fallback] instead of throwing when
  /// source range is zero. Useful in reactive/UI code where division by
  /// zero is a transient state rather than a programmer error.
  double safeNormalized(
    num fromMin,
    num fromMax, {
    num toMin = 0.0,
    num toMax = 1.0,
    double fallback = 0.0,
  }) {
    final range = fromMax - fromMin;
    if (range == 0) return fallback;
    return ((toMax - toMin) * ((this - fromMin) / range) + toMin).toDouble();
  }
}
