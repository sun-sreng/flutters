import '../../../functional.dart';
import 'currency.dart';
import 'money.dart';
import 'money_validation_issue.dart';
import 'money_validation_config.dart';

/// A class responsible for validating monetary inputs according to a [MoneyValidationConfig].
final class MoneyValidator {
  static const MoneyOutOfRangeIssue _outOfRange = MoneyOutOfRangeIssue(
    maxMinorUnits: Money.maxMinorUnits,
  );

  static final BigInt _maxMinorUnits = BigInt.from(Money.maxMinorUnits);

  /// The configuration rules to apply during validation.
  final MoneyValidationConfig config;

  /// Creates a new [MoneyValidator].
  const MoneyValidator([this.config = const MoneyValidationConfig()]);

  /// Validates the given [input] string as a money amount.
  ///
  /// Returns a `Right` containing the parsed [Money] if valid.
  /// Otherwise, returns a `Left` containing the specific [MoneyValidationIssue].
  Either<MoneyValidationIssue, Money> validate(
    String input, {
    String? currency,
  }) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(MoneyEmptyIssue());
    }

    final normalizedCurrency = _normalizeCurrency(
      currency ?? config.defaultCurrency,
    );
    final currencyError = _validateCurrency(normalizedCurrency);
    if (currencyError != null) {
      return Left(currencyError);
    }
    final parsedCurrency = Currency.fromCode(normalizedCurrency)!;

    if (!_isDecimal(trimmed)) {
      return const Left(MoneyInvalidFormatIssue());
    }

    final normalizedInput = _normalizeAmountInput(trimmed);
    final decimalDigits = parsedCurrency.decimalPlaces;
    final decimalPlaces = _countDecimalPlaces(normalizedInput);
    if (decimalPlaces > decimalDigits) {
      return Left(
        MoneyDecimalPlacesExceededIssue(
          currentPlaces: decimalPlaces,
          maxPlaces: decimalDigits,
        ),
      );
    }

    final minorUnits = _toMinorUnits(normalizedInput, decimalDigits);
    if (minorUnits == null) {
      return const Left(_outOfRange);
    }

    if (minorUnits < 0) {
      return Left(MoneyNegativeNotAllowedIssue(minorUnits));
    }

    if (config.minMinorUnits != null && minorUnits < config.minMinorUnits!) {
      return Left(
        MoneyTooSmallIssue(
          currentMinorUnits: minorUnits,
          minMinorUnits: config.minMinorUnits!,
        ),
      );
    }

    if (config.maxMinorUnits != null && minorUnits > config.maxMinorUnits!) {
      return Left(
        MoneyTooLargeIssue(
          currentMinorUnits: minorUnits,
          maxMinorUnits: config.maxMinorUnits!,
        ),
      );
    }

    return Right(Money(minorUnits: minorUnits, currency: parsedCurrency));
  }

  /// Validates an already numeric amount as money.
  Either<MoneyValidationIssue, Money> validateNum(
    num input, {
    String? currency,
  }) {
    return validate(input.toString(), currency: currency);
  }

  /// Validates an exact minor-unit amount as money.
  Either<MoneyValidationIssue, Money> validateMinorUnits(
    int minorUnits, {
    String? currency,
  }) {
    final normalizedCurrency = _normalizeCurrency(
      currency ?? config.defaultCurrency,
    );
    final currencyError = _validateCurrency(normalizedCurrency);
    if (currencyError != null) {
      return Left(currencyError);
    }
    final parsedCurrency = Currency.fromCode(normalizedCurrency)!;

    if (minorUnits < 0) {
      return Left(MoneyNegativeNotAllowedIssue(minorUnits));
    }

    if (minorUnits > Money.maxMinorUnits) {
      return const Left(_outOfRange);
    }

    if (config.minMinorUnits != null && minorUnits < config.minMinorUnits!) {
      return Left(
        MoneyTooSmallIssue(
          currentMinorUnits: minorUnits,
          minMinorUnits: config.minMinorUnits!,
        ),
      );
    }

    if (config.maxMinorUnits != null && minorUnits > config.maxMinorUnits!) {
      return Left(
        MoneyTooLargeIssue(
          currentMinorUnits: minorUnits,
          maxMinorUnits: config.maxMinorUnits!,
        ),
      );
    }

    return Right(Money(minorUnits: minorUnits, currency: parsedCurrency));
  }

  bool _isDecimal(String input) {
    if (RegExp(r'^[+-]?\d+(\.\d+)?$').hasMatch(input)) {
      return true;
    }

    if (!config.allowThousandsSeparators) {
      return false;
    }

    return RegExp(r'^[+-]?\d{1,3}(,\d{3})+(\.\d+)?$').hasMatch(input);
  }

  String _normalizeAmountInput(String input) {
    return config.allowThousandsSeparators ? input.replaceAll(',', '') : input;
  }

  int _countDecimalPlaces(String input) {
    final decimalIndex = input.indexOf('.');
    if (decimalIndex == -1) return 0;
    return input.length - decimalIndex - 1;
  }

  /// Converts [input] to signed minor units, or `null` when its magnitude is
  /// above [Money.maxMinorUnits].
  ///
  /// The caller has already checked the format and that the fraction has at
  /// most [decimalDigits] digits, so the whole and padded fraction digits
  /// together spell the minor-unit count. [BigInt] keeps that exact however
  /// many digits the input has.
  int? _toMinorUnits(String input, int decimalDigits) {
    final isNegative = input.startsWith('-');
    final unsigned =
        input.startsWith('-') || input.startsWith('+')
            ? input.substring(1)
            : input;
    final parts = unsigned.split('.');
    final fraction = parts.length == 1 ? '' : parts.last;
    final units = BigInt.parse(
      parts.first + fraction.padRight(decimalDigits, '0'),
    );
    if (units > _maxMinorUnits) return null;

    final value = units.toInt();
    return isNegative ? -value : value;
  }

  String _normalizeCurrency(String currency) {
    return currency.trim().toUpperCase();
  }

  MoneyValidationIssue? _validateCurrency(String currency) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency) ||
        Currency.fromCode(currency) == null) {
      return MoneyInvalidCurrencyIssue(currency);
    }

    final allowedCurrencies = config.allowedCurrencies;
    if (allowedCurrencies == null) {
      return null;
    }

    final normalizedAllowed =
        allowedCurrencies
            .map((currency) => currency.trim().toUpperCase())
            .toSet();
    if (!normalizedAllowed.contains(currency)) {
      return MoneyUnsupportedCurrencyIssue(
        currency: currency,
        allowedCurrencies: normalizedAllowed,
      );
    }

    return null;
  }
}
