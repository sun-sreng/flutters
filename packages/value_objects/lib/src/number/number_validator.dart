import 'package:fpdart/fpdart.dart';
import 'number_errors.dart';
import 'number_validation_config.dart';

final class NumberValidator {
  final NumberValidationConfig config;

  const NumberValidator([this.config = const NumberValidationConfig()]);

  Either<NumberError, num> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(NumberEmpty());
    }

    final parsed = num.tryParse(trimmed);
    if (parsed == null) {
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
      final decimalPlaces = _countDecimalPlaces(parsed);
      if (decimalPlaces > config.maxDecimalPlaces!) {
        return Left(NumberDecimalPlacesExceeded(currentPlaces: decimalPlaces, maxPlaces: config.maxDecimalPlaces!));
      }
    }

    return Right(parsed);
  }

  int _countDecimalPlaces(num value) {
    final str = value.toString();
    if (!str.contains('.')) return 0;
    return str.split('.')[1].length;
  }
}
