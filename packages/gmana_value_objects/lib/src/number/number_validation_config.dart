import 'package:meta/meta.dart';

/// Configuration rules for valid numbers.
///
/// Constraints include limits on value, integer checking, and decimal places.
@immutable
final class NumberValidationConfig {
  /// The optional minimum value.
  final num? min;

  /// The optional maximum value.
  final num? max;

  /// Whether negative numbers are permitted.
  final bool allowNegative;

  /// Whether the number must be an integer (no fractional parts).
  final bool integerOnly;

  /// Optional limit on the number of digits following the decimal point.
  final int? maxDecimalPlaces;

  /// Creates a [NumberValidationConfig] with customizable constraints.
  const NumberValidationConfig({
    this.min,
    this.max,
    this.allowNegative = true,
    this.integerOnly = false,
    this.maxDecimalPlaces,
  });

  /// Positive integers only (0, 1, 2, ...)
  factory NumberValidationConfig.positiveInteger() {
    return const NumberValidationConfig(
      min: 0,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Natural numbers (1, 2, 3, ...)
  factory NumberValidationConfig.naturalNumber() {
    return const NumberValidationConfig(
      min: 1,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Percentage (0-100)
  factory NumberValidationConfig.percentage() {
    return const NumberValidationConfig(min: 0, max: 100, allowNegative: false);
  }

  /// Price/Money (non-negative with 2 decimal places)
  factory NumberValidationConfig.price() {
    return const NumberValidationConfig(
      min: 0,
      allowNegative: false,
      maxDecimalPlaces: 2,
    );
  }

  /// Age validation
  factory NumberValidationConfig.age() {
    return const NumberValidationConfig(
      min: 0,
      max: 150,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Rating (1-5)
  factory NumberValidationConfig.rating() {
    return const NumberValidationConfig(
      min: 1,
      max: 5,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// Nullable fields ([min], [max], [maxDecimalPlaces]) can be cleared by
  /// passing `null` explicitly; omitting a parameter keeps the current value.
  NumberValidationConfig copyWith({
    Object? min = _unset,
    Object? max = _unset,
    bool? allowNegative,
    bool? integerOnly,
    Object? maxDecimalPlaces = _unset,
  }) {
    return NumberValidationConfig(
      min: identical(min, _unset) ? this.min : min as num?,
      max: identical(max, _unset) ? this.max : max as num?,
      allowNegative: allowNegative ?? this.allowNegative,
      integerOnly: integerOnly ?? this.integerOnly,
      maxDecimalPlaces:
          identical(maxDecimalPlaces, _unset)
              ? this.maxDecimalPlaces
              : maxDecimalPlaces as int?,
    );
  }

  static const Object _unset = Object();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberValidationConfig &&
          other.min == min &&
          other.max == max &&
          other.allowNegative == allowNegative &&
          other.integerOnly == integerOnly &&
          other.maxDecimalPlaces == maxDecimalPlaces;

  @override
  int get hashCode =>
      Object.hash(min, max, allowNegative, integerOnly, maxDecimalPlaces);
}
