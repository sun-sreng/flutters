import 'package:gmana/gmana.dart' show Either, Left, Right;
import 'number_errors.dart';
import 'number_validation_config.dart';

/// A class responsible for validating string inputs as numbers according to a [NumberValidationConfig].
final class NumberValidator {
  /// The configuration rules to apply during validation.
  final NumberValidationConfig config;

  /// Creates a new [NumberValidator].
  ///
  /// If [config] is not provided, the default [NumberValidationConfig] will be used.
  const NumberValidator([this.config = const NumberValidationConfig()]);

  /// Validates the given [input] string as a number.
  ///
  /// Returns a `Right` containing the parsed `num` if valid.
  /// Otherwise, returns a `Left` containing the specific [NumberError].
  Either<NumberError, num> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(NumberEmpty());
    }

    final parsed = num.tryParse(trimmed);
    if (parsed == null || !parsed.isFinite) {
      return const Left(NumberInvalidFormat());
    }

    if (!config.allowNegative && parsed < 0) {
      return Left(NumberNegativeNotAllowed(parsed));
    }

    if (config.integerOnly && parsed != parsed.toInt()) {
      return Left(NumberNotInteger(parsed));
    }

    if (config.min != null && parsed < config.min!) {
      return Left(NumberTooSmall(currentValue: parsed, minValue: config.min!));
    }

    if (config.max != null && parsed > config.max!) {
      return Left(NumberTooLarge(currentValue: parsed, maxValue: config.max!));
    }

    if (config.maxDecimalPlaces != null) {
      final decimalPlaces = _countDecimalPlaces(trimmed, parsed);
      if (decimalPlaces > config.maxDecimalPlaces!) {
        return Left(
          NumberDecimalPlacesExceeded(
            currentPlaces: decimalPlaces,
            maxPlaces: config.maxDecimalPlaces!,
          ),
        );
      }
    }

    return Right(parsed);
  }

  int _countDecimalPlaces(String input, num parsed) {
    final normalized = input.toLowerCase();
    final str = normalized.contains('e') ? parsed.toString() : normalized;
    if (!str.contains('.')) return 0;
    return str.split('.')[1].length;
  }
}
