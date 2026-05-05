import 'package:meta/meta.dart';

/// Configuration rules for valid money values.
///
/// Amount limits are expressed in minor units so they stay exact.
/// Currency precision is defined by [Currency] metadata.
@immutable
final class MoneyValidationConfig {
  /// The currency to use when no currency is passed to the validator.
  final String defaultCurrency;

  /// Optional set of supported currency codes.
  final Set<String>? allowedCurrencies;

  /// Optional minimum amount in minor units.
  final int? minMinorUnits;

  /// Optional maximum amount in minor units.
  final int? maxMinorUnits;

  /// Whether comma thousands separators are accepted in text input.
  final bool allowThousandsSeparators;

  /// Creates a [MoneyValidationConfig] with customizable constraints.
  const MoneyValidationConfig({
    this.defaultCurrency = 'USD',
    this.allowedCurrencies,
    this.minMinorUnits,
    this.maxMinorUnits,
    this.allowThousandsSeparators = true,
  });

  /// Non-negative USD money with two decimal places.
  factory MoneyValidationConfig.usd() {
    return const MoneyValidationConfig(
      defaultCurrency: 'USD',
      allowedCurrencies: {'USD'},
    );
  }

  /// Non-negative KHR money with no decimal places.
  factory MoneyValidationConfig.khr() {
    return const MoneyValidationConfig(
      defaultCurrency: 'KHR',
      allowedCurrencies: {'KHR'},
    );
  }

  /// Non-negative USD, EUR, and KHR money.
  factory MoneyValidationConfig.commonCurrencies() {
    return const MoneyValidationConfig(
      allowedCurrencies: {'USD', 'EUR', 'KHR'},
    );
  }

  /// Common ecommerce currencies, including zero-decimal Asian currencies.
  factory MoneyValidationConfig.ecommerce() {
    return const MoneyValidationConfig(
      allowedCurrencies: {
        'USD',
        'EUR',
        'GBP',
        'AUD',
        'CAD',
        'CNY',
        'SGD',
        'THB',
        'KHR',
        'JPY',
        'KRW',
        'VND',
      },
    );
  }
}
