import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../extensions/validation_adapter_extensions.dart';
import 'number_errors.dart';
import 'number_validation_config.dart';

/// A class responsible for validating string inputs as numbers according to a [NumberValidationConfig].
final class NumberValidator {
  /// The configuration rules to apply during validation.
  final NumberValidationConfig config;

  /// Creates a new [NumberValidator].
  const NumberValidator([this.config = const NumberValidationConfig()]);

  /// Validates the given [input] string as a number.
  Either<NumberError, num> validate(String input) {
    return v.NumberValidator(
      config,
    ).validate(input).fold((issue) => Left(issue.toNumberError()), Right.new);
  }
}
