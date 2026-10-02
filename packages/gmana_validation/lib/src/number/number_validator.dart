import 'package:gmana_functional/gmana_functional.dart';
import 'package:meta/meta.dart';

import '../core/set_equality.dart';
import '../core/validation_issue.dart';

/// Default English messages for number validation issues.
String resolveNumberValidationIssue(NumberValidationIssue issue) {
  return switch (issue) {
    NumberEmptyIssue() => 'Please enter a number',
    NumberInvalidFormatIssue() => 'Please enter a valid number',
    NumberNegativeNotAllowedIssue() => 'Negative numbers are not allowed',
    NumberNotIntegerIssue() => 'Please enter a whole number',
    NumberTooSmallIssue(:final minValue) => 'Number must be at least $minValue',
    NumberTooLargeIssue(:final maxValue) => 'Number must be at most $maxValue',
    NumberDecimalPlacesExceededIssue(:final maxPlaces) =>
      'Number must have at most $maxPlaces decimal places',
  };
}

/// Base type for number validation failures.
sealed class NumberValidationIssue extends ValidationIssue {
  /// Creates a number validation issue.
  const NumberValidationIssue();
}

/// Number input is empty.
final class NumberEmptyIssue extends NumberValidationIssue {
  /// Creates a number-empty issue.
  const NumberEmptyIssue();

  @override
  String get code => 'number.empty';
}

/// Number input is malformed.
final class NumberInvalidFormatIssue extends NumberValidationIssue {
  /// Creates a number-invalid-format issue.
  const NumberInvalidFormatIssue();

  @override
  String get code => 'number.invalidFormat';
}

/// Negative values are not allowed.
final class NumberNegativeNotAllowedIssue extends NumberValidationIssue {
  /// The provided negative value.
  final num currentValue;

  /// Creates a negative-not-allowed issue.
  const NumberNegativeNotAllowedIssue(this.currentValue);

  @override
  String get code => 'number.negativeNotAllowed';
}

/// A whole number is required.
final class NumberNotIntegerIssue extends NumberValidationIssue {
  /// The provided non-integer value.
  final num currentValue;

  /// Creates a not-integer issue.
  const NumberNotIntegerIssue(this.currentValue);

  @override
  String get code => 'number.notInteger';
}

/// Number is smaller than the allowed minimum.
final class NumberTooSmallIssue extends NumberValidationIssue {
  /// The provided value.
  final num currentValue;

  /// The configured minimum value.
  final num minValue;

  /// Creates a too-small issue.
  const NumberTooSmallIssue({
    required this.currentValue,
    required this.minValue,
  });

  @override
  String get code => 'number.tooSmall';
}

/// Number is larger than the allowed maximum.
final class NumberTooLargeIssue extends NumberValidationIssue {
  /// The provided value.
  final num currentValue;

  /// The configured maximum value.
  final num maxValue;

  /// Creates a too-large issue.
  const NumberTooLargeIssue({
    required this.currentValue,
    required this.maxValue,
  });

  @override
  String get code => 'number.tooLarge';
}

/// Number has too many decimal places.
final class NumberDecimalPlacesExceededIssue extends NumberValidationIssue {
  /// The provided decimal-place count.
  final int currentPlaces;

  /// The configured maximum decimal-place count.
  final int maxPlaces;

  /// Creates a decimal-places-exceeded issue.
  const NumberDecimalPlacesExceededIssue({
    required this.currentPlaces,
    required this.maxPlaces,
  });

  @override
  String get code => 'number.decimalPlacesExceeded';
}

/// Configuration for number validation.
@immutable
final class NumberValidationConfig {
  /// Minimum allowed value.
  final num? min;

  /// Maximum allowed value.
  final num? max;

  /// Whether negative values are allowed.
  final bool allowNegative;

  /// Whether only whole numbers are allowed.
  final bool integerOnly;

  /// Maximum allowed decimal places.
  final int? maxDecimalPlaces;

  /// Creates a number validation config.
  const NumberValidationConfig({
    this.min,
    this.max,
    this.allowNegative = true,
    this.integerOnly = false,
    this.maxDecimalPlaces,
  });

  /// Preset for non-negative integers (0, 1, 2, ...).
  factory NumberValidationConfig.positiveInteger({num? min = 0, num? max}) {
    return NumberValidationConfig(
      min: min,
      max: max,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Preset for natural numbers (1, 2, 3, ...).
  factory NumberValidationConfig.naturalNumber() {
    return const NumberValidationConfig(
      min: 1,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Preset for a percentage (0-100).
  factory NumberValidationConfig.percentage() {
    return const NumberValidationConfig(min: 0, max: 100, allowNegative: false);
  }

  /// Preset for a price: non-negative with at most two decimal places.
  factory NumberValidationConfig.price() {
    return const NumberValidationConfig(
      min: 0,
      allowNegative: false,
      maxDecimalPlaces: 2,
    );
  }

  /// Preset for an age in whole years (0-150).
  factory NumberValidationConfig.age() {
    return const NumberValidationConfig(
      min: 0,
      max: 150,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Preset for a whole-number rating (1-5).
  factory NumberValidationConfig.rating() {
    return const NumberValidationConfig(
      min: 1,
      max: 5,
      allowNegative: false,
      integerOnly: true,
    );
  }

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Pass `null` explicitly to clear [min], [max], or [maxDecimalPlaces].
  /// Omitted fields retain their current values.
  NumberValidationConfig copyWith({
    Object? min = unsetConfigValue,
    Object? max = unsetConfigValue,
    bool? allowNegative,
    bool? integerOnly,
    Object? maxDecimalPlaces = unsetConfigValue,
  }) {
    return NumberValidationConfig(
      min: identical(min, unsetConfigValue) ? this.min : min as num?,
      max: identical(max, unsetConfigValue) ? this.max : max as num?,
      allowNegative: allowNegative ?? this.allowNegative,
      integerOnly: integerOnly ?? this.integerOnly,
      maxDecimalPlaces:
          identical(maxDecimalPlaces, unsetConfigValue)
              ? this.maxDecimalPlaces
              : maxDecimalPlaces as int?,
    );
  }

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

/// Canonical validator for number inputs.
final class NumberValidator {
  /// Rules used during validation.
  final NumberValidationConfig config;

  /// Creates a number validator.
  const NumberValidator([this.config = const NumberValidationConfig()]);

  /// Validates and parses a number.
  ValidationResult<NumberValidationIssue, num> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(NumberEmptyIssue());
    }

    final parsed = num.tryParse(trimmed);
    if (parsed == null || !parsed.isFinite) {
      return const Left(NumberInvalidFormatIssue());
    }

    if (!config.allowNegative && parsed < 0) {
      return Left(NumberNegativeNotAllowedIssue(parsed));
    }

    if (config.integerOnly && parsed != parsed.toInt()) {
      return Left(NumberNotIntegerIssue(parsed));
    }

    if (config.min != null && parsed < config.min!) {
      return Left(
        NumberTooSmallIssue(currentValue: parsed, minValue: config.min!),
      );
    }

    if (config.max != null && parsed > config.max!) {
      return Left(
        NumberTooLargeIssue(currentValue: parsed, maxValue: config.max!),
      );
    }

    if (config.maxDecimalPlaces != null) {
      final decimalPlaces = _countDecimalPlaces(trimmed);
      if (decimalPlaces > config.maxDecimalPlaces!) {
        return Left(
          NumberDecimalPlacesExceededIssue(
            currentPlaces: decimalPlaces,
            maxPlaces: config.maxDecimalPlaces!,
          ),
        );
      }
    }

    return Right(parsed);
  }

  int _countDecimalPlaces(String value) {
    final decimalIndex = value.indexOf('.');
    if (decimalIndex == -1) return 0;
    return value.length - decimalIndex - 1;
  }
}
