import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import 'password_errors.dart';
import 'password_validation_config.dart';

/// A class responsible for validating string inputs as passwords according to a [PasswordValidationConfig].
final class PasswordValidator {
  /// The configuration rules to apply during validation.
  final PasswordValidationConfig config;

  /// Creates a new [PasswordValidator].
  const PasswordValidator([this.config = const PasswordValidationConfig()]);

  /// Validates the given [input] string as a password.
  Either<PasswordError, String> validate(String input) {
    if (input.isEmpty) {
      return const Left(PasswordEmpty());
    }

    if (input.length < config.minLength) {
      return Left(
        PasswordTooShort(
          currentLength: input.length,
          minLength: config.minLength,
        ),
      );
    }

    if (input.length > config.maxLength) {
      return Left(
        PasswordTooLong(
          currentLength: input.length,
          maxLength: config.maxLength,
        ),
      );
    }

    if (!_isAsciiOnly(input)) {
      return const Left(PasswordNonAscii());
    }

    final lowered = input.toLowerCase();

    if (_hasCommonPasswordPrefix(lowered)) {
      return const Left(PasswordTooCommon());
    }

    if (v.PasswordValidator.hasOnlyRepeatedCharacters(input)) {
      return const Left(PasswordTooWeak());
    }

    final maxAllowedRun = (input.length * config.sequentialRunFactor)
        .floor()
        .clamp(3, 7);
    if (v.PasswordValidator.hasSequentialRun(lowered, minRun: maxAllowedRun)) {
      return const Left(PasswordTooPredictable());
    }

    final score = _classScore(input);
    if (score < config.minComplexityScore) {
      return Left(
        PasswordComplexityRequired(
          currentScore: score,
          requiredScore: config.minComplexityScore,
        ),
      );
    }

    return Right(input);
  }

  bool _isAsciiOnly(String s) {
    return s.codeUnits.every(
      (c) => c >= config.minAsciiCode && c <= config.maxAsciiCode,
    );
  }

  bool _hasCommonPasswordPrefix(String lowered) {
    if (config.commonPasswords.contains(lowered)) return true;

    return config.commonPrefixes.any(
      (prefix) =>
          lowered.startsWith(prefix) && lowered.length <= prefix.length + 4,
    );
  }

  int _classScore(String s) {
    return (v.PasswordValidator.hasLowercase(s) ? 1 : 0) +
        (v.PasswordValidator.hasUppercase(s) ? 1 : 0) +
        (v.PasswordValidator.hasDigit(s) ? 1 : 0) +
        (v.PasswordValidator.hasSpecialCharacter(s) ? 1 : 0);
  }
}
