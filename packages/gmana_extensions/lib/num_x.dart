import 'dart:math';

/// Shared mathematical, formatting, and conversion extensions on [num].
extension NumX on num {
  /// Converts Celsius to Fahrenheit.
  double get celsiusToFahrenheit => toDouble() * 9 / 5 + 32;

  /// Converts Celsius to Kelvin.
  double get celsiusToKelvin => toDouble() + 273.15;

  /// Converts Fahrenheit to Celsius.
  double get fahrenheitToCelsius => (toDouble() - 32) * 5 / 9;

  /// Converts Fahrenheit to Kelvin.
  double get fahrenheitToKelvin => fahrenheitToCelsius.celsiusToKelvin;

  /// Converts Kelvin to Celsius.
  double get kelvinToCelsius => toDouble() - 273.15;

  /// Converts Kelvin to Fahrenheit.
  double get kelvinToFahrenheit => kelvinToCelsius.celsiusToFahrenheit;

  /// Checks if the number is a whole number (has no fractional part).
  bool get isWholeNumber => this % 1 == 0;

  /// Returns true if this value is zero.
  bool get isZero => this == 0;

  /// Returns true if this value is not zero.
  bool get isNotZero => this != 0;

  /// Returns this value multiplied by itself.
  num get squared => this * this;

  /// Returns this value multiplied by itself twice.
  num get cubed => this * this * this;

  /// Returns `1 / this`.
  double get reciprocal {
    if (this == 0) {
      throw ArgumentError.value(this, 'this', 'must not be zero');
    }
    return 1 / toDouble();
  }

  /// Checks if the number is between [min] and [max] inclusively.
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Checks if the number is within [tolerance] of [other].
  bool isCloseTo(num other, {num tolerance = 1e-10}) {
    if (tolerance < 0) {
      throw ArgumentError.value(tolerance, 'tolerance', 'must not be negative');
    }
    return (this - other).abs() <= tolerance;
  }

  /// Linear interpolation between [a] and [b] where `this` is `t in [0, 1]`.
  /// ```dart
  /// 0.25.lerp(0, 100); // 25.0
  /// ```
  double lerp(num a, num b) => (a + (b - a) * toDouble()).toDouble();

  /// Returns this value as a percentage of [total].
  double percentageOf(num total) {
    if (total == 0) {
      throw ArgumentError.value(total, 'total', 'must not be zero');
    }
    return (toDouble() / total) * 100;
  }

  /// Returns this value as a percentage of [total], or [fallback] if [total] is zero.
  double safePercentageOf(num total, {double fallback = 0.0}) =>
      total == 0 ? fallback : percentageOf(total);

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
    return ((toMax - toMin) * ((toDouble() - fromMin) / range) + toMin)
        .toDouble();
  }

  /// Same as [normalized] but clamps the result to `[toMin, toMax]`.
  double normalizedClamped(
    num fromMin,
    num fromMax, [
    num toMin = 0.0,
    num toMax = 1.0,
  ]) {
    final low = min(toMin, toMax).toDouble();
    final high = max(toMin, toMax).toDouble();
    return normalized(fromMin, fromMax, toMin, toMax).clamp(low, high);
  }

  /// Returns this value constrained to the inclusive range [[min], [max]].
  num clampNum(num min, num max) {
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

  /// Safe normalization that falls back to [fallback] if the source range is zero.
  double safeNormalized(
    num fromMin,
    num fromMax, {
    num toMin = 0.0,
    num toMax = 1.0,
    double fallback = 0.0,
  }) {
    final range = fromMax - fromMin;
    if (range == 0) return fallback;
    return ((toMax - toMin) * ((toDouble() - fromMin) / range) + toMin)
        .toDouble();
  }

  // --- Rounding and Multiples ---

  /// Rounds to [places] decimal places.
  /// ```dart
  /// 3.14159.roundTo(2); // 3.14
  /// ```
  double roundTo(int places) {
    if (places < 0) {
      throw ArgumentError.value(places, 'places', 'must not be negative');
    }
    final factor = pow(10, places);
    return (toDouble() * factor).round() / factor;
  }

  /// Ceil to the nearest [multiple].
  num ceilToMultiple(num multiple) {
    _checkNonZeroMultiple(multiple);
    return (this / multiple).ceil() * multiple;
  }

  /// Floor to the nearest [multiple].
  num floorToMultiple(num multiple) {
    _checkNonZeroMultiple(multiple);
    return (this / multiple).floor() * multiple;
  }

  /// Rounds to the nearest [multiple].
  num roundToMultiple(num multiple) {
    _checkNonZeroMultiple(multiple);
    return (this / multiple).round() * multiple;
  }
}

/// Internal safety check for multiple-based calculations.
void _checkNonZeroMultiple(num multiple) {
  if (multiple == 0) {
    throw ArgumentError.value(multiple, 'multiple', 'must not be zero');
  }
}
