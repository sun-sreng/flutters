import 'package:gmana_functional/gmana_functional.dart';

import '../core/validation_issue.dart';
import 'phone_validation_config.dart';
import 'phone_validation_issue.dart';

/// Validates and normalizes phone numbers.
final class PhoneValidator {
  /// Rules used during validation.
  final PhoneValidationConfig config;

  /// Creates a phone validator.
  const PhoneValidator([this.config = const PhoneValidationConfig()]);

  /// Validates [input] and returns normalized phone number on success.
  ValidationResult<PhoneValidationIssue, String> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) return const Left(PhoneEmptyIssue());

    if (config.requirePlusPrefix && !trimmed.startsWith('+')) {
      return const Left(PhoneMissingPlusIssue());
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) return const Left(PhoneInvalidFormatIssue());

    if (digitsOnly.length < config.minDigits) {
      return Left(
        PhoneTooShortIssue(
          currentDigits: digitsOnly.length,
          minDigits: config.minDigits,
        ),
      );
    }

    if (digitsOnly.length > config.maxDigits) {
      return Left(
        PhoneTooLongIssue(
          currentDigits: digitsOnly.length,
          maxDigits: config.maxDigits,
        ),
      );
    }

    final normalized = trimmed.startsWith('+') ? '+$digitsOnly' : digitsOnly;
    return Right(normalized);
  }
}
