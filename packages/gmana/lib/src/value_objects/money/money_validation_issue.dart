import '../../validation/core/validation_issue.dart';

/// Default English messages for money validation issues.
String resolveMoneyValidationIssue(MoneyValidationIssue issue) {
  return switch (issue) {
    MoneyEmptyIssue() => 'Money amount cannot be empty',
    MoneyInvalidFormatIssue() => 'Invalid money amount format',
    MoneyNegativeNotAllowedIssue(:final minorUnits) =>
      'Negative money amounts are not allowed (minor units: $minorUnits)',
    MoneyDecimalPlacesExceededIssue(:final currentPlaces, :final maxPlaces) =>
      'Too many money decimal places (max: $maxPlaces, current: $currentPlaces)',
    MoneyInvalidCurrencyIssue(:final currency) =>
      'Invalid currency code ($currency)',
    MoneyUnsupportedCurrencyIssue(:final currency, :final allowedCurrencies) =>
      'Unsupported currency $currency (allowed: ${allowedCurrencies.join(', ')})',
    MoneyTooSmallIssue(:final currentMinorUnits, :final minMinorUnits) =>
      'Money amount is too small (min minor units: $minMinorUnits, current: $currentMinorUnits)',
    MoneyTooLargeIssue(:final currentMinorUnits, :final maxMinorUnits) =>
      'Money amount is too large (max minor units: $maxMinorUnits, current: $currentMinorUnits)',
  };
}

/// Base type for money validation failures.
sealed class MoneyValidationIssue extends ValidationIssue {
  /// Creates a money validation issue.
  const MoneyValidationIssue();
}

/// The amount input is empty.
final class MoneyEmptyIssue extends MoneyValidationIssue {
  /// Creates a money-empty issue.
  const MoneyEmptyIssue();

  @override
  String get code => 'money.empty';
}

/// The amount input is not a valid decimal number.
final class MoneyInvalidFormatIssue extends MoneyValidationIssue {
  /// Creates an invalid-format issue.
  const MoneyInvalidFormatIssue();

  @override
  String get code => 'money.invalidFormat';
}

/// The amount is negative and negatives are not allowed.
final class MoneyNegativeNotAllowedIssue extends MoneyValidationIssue {
  /// Creates a negative-not-allowed issue for [minorUnits].
  const MoneyNegativeNotAllowedIssue(this.minorUnits);

  /// The rejected amount in minor units.
  final int minorUnits;

  @override
  String get code => 'money.negativeNotAllowed';
}

/// The amount has more decimal places than the currency allows.
final class MoneyDecimalPlacesExceededIssue extends MoneyValidationIssue {
  /// Creates a decimal-places-exceeded issue.
  const MoneyDecimalPlacesExceededIssue({
    required this.currentPlaces,
    required this.maxPlaces,
  });

  /// Decimal places in the input.
  final int currentPlaces;

  /// Decimal places the currency allows.
  final int maxPlaces;

  @override
  String get code => 'money.decimalPlacesExceeded';
}

/// The currency code is not a valid ISO 4217 code.
final class MoneyInvalidCurrencyIssue extends MoneyValidationIssue {
  /// Creates an invalid-currency issue for [currency].
  const MoneyInvalidCurrencyIssue(this.currency);

  /// The rejected currency code.
  final String currency;

  @override
  String get code => 'money.invalidCurrency';
}

/// The currency is valid but not in the allowed set.
final class MoneyUnsupportedCurrencyIssue extends MoneyValidationIssue {
  /// Creates an unsupported-currency issue.
  const MoneyUnsupportedCurrencyIssue({
    required this.currency,
    required this.allowedCurrencies,
  });

  /// The rejected currency code.
  final String currency;

  /// The currency codes that are allowed.
  final Set<String> allowedCurrencies;

  @override
  String get code => 'money.unsupportedCurrency';
}

/// The amount is below the configured minimum.
final class MoneyTooSmallIssue extends MoneyValidationIssue {
  /// Creates a too-small issue.
  const MoneyTooSmallIssue({
    required this.currentMinorUnits,
    required this.minMinorUnits,
  });

  /// The amount in minor units.
  final int currentMinorUnits;

  /// The minimum allowed amount in minor units.
  final int minMinorUnits;

  @override
  String get code => 'money.tooSmall';
}

/// The amount is above the configured maximum.
final class MoneyTooLargeIssue extends MoneyValidationIssue {
  /// Creates a too-large issue.
  const MoneyTooLargeIssue({
    required this.currentMinorUnits,
    required this.maxMinorUnits,
  });

  /// The amount in minor units.
  final int currentMinorUnits;

  /// The maximum allowed amount in minor units.
  final int maxMinorUnits;

  @override
  String get code => 'money.tooLarge';
}
