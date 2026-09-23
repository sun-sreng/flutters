import '../core/validation_error.dart';

/// Base class for all number validation errors.
sealed class NumberError extends ValidationError {
  /// Internal constructor for [NumberError].
  const NumberError();
}

/// Error indicating that the number string is empty.
final class NumberEmpty extends NumberError {
  /// Creates a new [NumberEmpty] error.
  const NumberEmpty();

  @override
  String get code => 'number_empty';
}

/// Error indicating that the number string is not a valid recognized format.
final class NumberInvalidFormat extends NumberError {
  /// Creates a new [NumberInvalidFormat] error.
  const NumberInvalidFormat();

  @override
  String get code => 'number_invalid_format';
}

/// Error indicating that the number is smaller than the minimum allowed value.
final class NumberTooSmall extends NumberError {
  /// The evaluated numeric value.
  final num currentValue;

  /// The minimum allowed value.
  final num minValue;

  /// Creates a new [NumberTooSmall] error.
  const NumberTooSmall({required this.currentValue, required this.minValue});

  @override
  String get code => 'number_too_small';
}

/// Error indicating that the number is larger than the maximum allowed value.
final class NumberTooLarge extends NumberError {
  /// The evaluated numeric value.
  final num currentValue;

  /// The maximum allowed value.
  final num maxValue;

  /// Creates a new [NumberTooLarge] error.
  const NumberTooLarge({required this.currentValue, required this.maxValue});

  @override
  String get code => 'number_too_large';
}

/// Error indicating that the number must be an integer, but has fractional parts.
final class NumberNotInteger extends NumberError {
  /// The evaluated numeric value that failed the integer check.
  final num currentValue;

  /// Creates a new [NumberNotInteger] error.
  const NumberNotInteger(this.currentValue);

  @override
  String get code => 'number_not_integer';
}

/// Error indicating that the number is negative but negative numbers are disallowed.
final class NumberNegativeNotAllowed extends NumberError {
  /// The evaluated numeric value that was negatively signed.
  final num currentValue;

  /// Creates a new [NumberNegativeNotAllowed] error.
  const NumberNegativeNotAllowed(this.currentValue);

  @override
  String get code => 'number_negative_not_allowed';
}

/// Error indicating that the number does not fall within the required inclusive range.
final class NumberNotInRange extends NumberError {
  /// The evaluated numeric value.
  final num currentValue;

  /// The minimum boundary.
  final num minValue;

  /// The maximum boundary.
  final num maxValue;

  /// Creates a new [NumberNotInRange] error.
  const NumberNotInRange({
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  String get code => 'number_not_in_range';
}

/// Error indicating that the number has too many fractional digits after the decimal point.
final class NumberDecimalPlacesExceeded extends NumberError {
  /// The count of decimal places provided.
  final int currentPlaces;

  /// The maximum allowed decimal places.
  final int maxPlaces;

  /// Creates a new [NumberDecimalPlacesExceeded] error.
  const NumberDecimalPlacesExceeded({
    required this.currentPlaces,
    required this.maxPlaces,
  });

  @override
  String get code => 'number_decimal_places_exceeded';
}
