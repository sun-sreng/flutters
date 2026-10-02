import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../extensions/validation_adapter_extensions.dart';
import 'phone_errors.dart';
import 'phone_validation_config.dart';

/// A class responsible for validating string inputs as phone numbers according to a [PhoneValidationConfig].
final class PhoneValidator {
  /// The configuration rules to apply during validation.
  final PhoneValidationConfig config;

  /// Creates a new [PhoneValidator].
  const PhoneValidator([this.config = const PhoneValidationConfig()]);

  /// Validates the given [input] string as a phone number.
  Either<PhoneError, String> validate(String input) {
    return v.PhoneValidator(
      config,
    ).validate(input).fold((issue) => Left(issue.toPhoneError()), Right.new);
  }
}
