import '../core/validation_error.dart';

/// Base class for all money validation errors.
sealed class MoneyError extends ValidationError {
  /// Internal constructor for [MoneyError].
  const MoneyError();
}

/// Error indicating that the money amount is empty.
final class MoneyEmpty extends MoneyError {
  /// Creates a new [MoneyEmpty] error.
  const MoneyEmpty();
}

/// Error indicating that the money amount is not a valid decimal format.
final class MoneyInvalidFormat extends MoneyError {
  /// Creates a new [MoneyInvalidFormat] error.
  const MoneyInvalidFormat();
}

/// Error indicating that a negative money amount is disallowed.
final class MoneyNegativeNotAllowed extends MoneyError {
  /// The evaluated minor-unit value that was negatively signed.
  final int minorUnits;

  /// Creates a new [MoneyNegativeNotAllowed] error.
  const MoneyNegativeNotAllowed(this.minorUnits);
}

/// Error indicating that the amount has too many fractional digits.
final class MoneyDecimalPlacesExceeded extends MoneyError {
  /// The count of decimal places provided.
  final int currentPlaces;

  /// The maximum allowed decimal places.
  final int maxPlaces;

  /// Creates a new [MoneyDecimalPlacesExceeded] error.
  const MoneyDecimalPlacesExceeded({
    required this.currentPlaces,
    required this.maxPlaces,
  });
}

/// Error indicating that the currency code is empty or malformed.
final class MoneyInvalidCurrency extends MoneyError {
  /// The currency value that failed validation.
  final String currency;

  /// Creates a new [MoneyInvalidCurrency] error.
  const MoneyInvalidCurrency(this.currency);
}

/// Error indicating that the currency is not in the allowed currency set.
final class MoneyUnsupportedCurrency extends MoneyError {
  /// The normalized currency code.
  final String currency;

  /// The configured allowed currencies.
  final Set<String> allowedCurrencies;

  /// Creates a new [MoneyUnsupportedCurrency] error.
  const MoneyUnsupportedCurrency({
    required this.currency,
    required this.allowedCurrencies,
  });
}

/// Error indicating that the money amount is smaller than the minimum allowed value.
final class MoneyTooSmall extends MoneyError {
  /// The evaluated minor-unit value.
  final int currentMinorUnits;

  /// The minimum allowed minor-unit value.
  final int minMinorUnits;

  /// Creates a new [MoneyTooSmall] error.
  const MoneyTooSmall({
    required this.currentMinorUnits,
    required this.minMinorUnits,
  });
}

/// Error indicating that the money amount is larger than the maximum allowed value.
final class MoneyTooLarge extends MoneyError {
  /// The evaluated minor-unit value.
  final int currentMinorUnits;

  /// The maximum allowed minor-unit value.
  final int maxMinorUnits;

  /// Creates a new [MoneyTooLarge] error.
  const MoneyTooLarge({
    required this.currentMinorUnits,
    required this.maxMinorUnits,
  });
}
