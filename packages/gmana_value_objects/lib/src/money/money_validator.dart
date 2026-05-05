import 'package:gmana/gmana.dart' show Either, Left, Right;
import 'currency.dart';
import 'money_amount.dart';
import 'money_errors.dart';
import 'money_validation_config.dart';

/// A class responsible for validating monetary inputs according to a [MoneyValidationConfig].
final class MoneyValidator {
  /// The configuration rules to apply during validation.
  final MoneyValidationConfig config;

  /// Creates a new [MoneyValidator].
  const MoneyValidator([this.config = const MoneyValidationConfig()]);

  /// Validates the given [input] string as a money amount.
  ///
  /// Returns a `Right` containing the parsed [MoneyAmount] if valid.
  /// Otherwise, returns a `Left` containing the specific [MoneyError].
  Either<MoneyError, MoneyAmount> validate(String input, {String? currency}) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(MoneyEmpty());
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
      return const Left(MoneyInvalidFormat());
    }

    final normalizedInput = _normalizeAmountInput(trimmed);
    final decimalDigits = parsedCurrency.decimalPlaces;
    final decimalPlaces = _countDecimalPlaces(normalizedInput);
    if (decimalPlaces > decimalDigits) {
      return Left(
        MoneyDecimalPlacesExceeded(
          currentPlaces: decimalPlaces,
          maxPlaces: decimalDigits,
        ),
      );
    }

    final minorUnits = _toMinorUnits(normalizedInput, decimalDigits);

    if (minorUnits < 0) {
      return Left(MoneyNegativeNotAllowed(minorUnits));
    }

    if (config.minMinorUnits != null && minorUnits < config.minMinorUnits!) {
      return Left(
        MoneyTooSmall(
          currentMinorUnits: minorUnits,
          minMinorUnits: config.minMinorUnits!,
        ),
      );
    }

    if (config.maxMinorUnits != null && minorUnits > config.maxMinorUnits!) {
      return Left(
        MoneyTooLarge(
          currentMinorUnits: minorUnits,
          maxMinorUnits: config.maxMinorUnits!,
        ),
      );
    }

    return Right(MoneyAmount(minorUnits: minorUnits, currency: parsedCurrency));
  }

  /// Validates an already numeric amount as money.
  Either<MoneyError, MoneyAmount> validateNum(num input, {String? currency}) {
    return validate(input.toString(), currency: currency);
  }

  /// Validates an exact minor-unit amount as money.
  Either<MoneyError, MoneyAmount> validateMinorUnits(
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
      return Left(MoneyNegativeNotAllowed(minorUnits));
    }

    if (config.minMinorUnits != null && minorUnits < config.minMinorUnits!) {
      return Left(
        MoneyTooSmall(
          currentMinorUnits: minorUnits,
          minMinorUnits: config.minMinorUnits!,
        ),
      );
    }

    if (config.maxMinorUnits != null && minorUnits > config.maxMinorUnits!) {
      return Left(
        MoneyTooLarge(
          currentMinorUnits: minorUnits,
          maxMinorUnits: config.maxMinorUnits!,
        ),
      );
    }

    return Right(MoneyAmount(minorUnits: minorUnits, currency: parsedCurrency));
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

  int _toMinorUnits(String input, int decimalDigits) {
    final isNegative = input.startsWith('-');
    final unsigned =
        input.startsWith('-') || input.startsWith('+')
            ? input.substring(1)
            : input;
    final parts = unsigned.split('.');
    final whole = int.parse(parts.first);
    final fraction =
        parts.length == 1 ? '' : parts.last.padRight(decimalDigits, '0');
    final fractionUnits = fraction.isEmpty ? 0 : int.parse(fraction);
    final units = whole * _scale(decimalDigits) + fractionUnits;

    return isNegative ? -units : units;
  }

  String _normalizeCurrency(String currency) {
    return currency.trim().toUpperCase();
  }

  MoneyError? _validateCurrency(String currency) {
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(currency) ||
        Currency.fromCode(currency) == null) {
      return MoneyInvalidCurrency(currency);
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
      return MoneyUnsupportedCurrency(
        currency: currency,
        allowedCurrencies: normalizedAllowed,
      );
    }

    return null;
  }

  int _scale(int decimalDigits) {
    var scale = 1;
    for (var i = 0; i < decimalDigits; i++) {
      scale *= 10;
    }
    return scale;
  }
}
