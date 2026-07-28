import 'package:gmana_functional/gmana_functional.dart';

import 'phone_errors.dart';
import 'phone_validation_config.dart';

/// Validator for phone numbers returning [Either<PhoneError, String>].
final class PhoneValidator {
  /// Rules used during validation.
  final PhoneValidationConfig config;

  /// Creates a phone validator.
  const PhoneValidator([this.config = const PhoneValidationConfig()]);

  /// Validates [input] and returns normalized phone string on success.
  Either<PhoneError, String> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) return const Left(PhoneEmpty());

    if (config.requirePlusPrefix && !trimmed.startsWith('+')) {
      return const Left(PhoneMissingPlus());
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) return const Left(PhoneInvalidFormat());

    if (digitsOnly.length < config.minDigits) {
      return Left(
        PhoneTooShort(
          currentDigits: digitsOnly.length,
          minDigits: config.minDigits,
        ),
      );
    }

    if (digitsOnly.length > config.maxDigits) {
      return Left(
        PhoneTooLong(
          currentDigits: digitsOnly.length,
          maxDigits: config.maxDigits,
        ),
      );
    }

    final normalized = trimmed.startsWith('+') ? '+$digitsOnly' : digitsOnly;
    return Right(normalized);
  }
}
