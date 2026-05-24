import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart';

/// Configuration for confirm-password validation.
final class ConfirmPasswordValidationConfig {
  /// Whether an empty confirmation is allowed.
  final bool requireConfirmation;

  /// Whether both values should be trimmed before comparison.
  final bool trimWhitespace;

  /// Creates a confirm-password validation config.
  const ConfirmPasswordValidationConfig({
    this.requireConfirmation = true,
    this.trimWhitespace = false,
  });
}

/// Base type for confirm-password validation failures.
sealed class ConfirmPasswordValidationIssue extends ValidationIssue {
  const ConfirmPasswordValidationIssue();
}

/// Confirmation input is empty.
final class ConfirmPasswordEmptyIssue extends ConfirmPasswordValidationIssue {
  /// Creates the issue.
  const ConfirmPasswordEmptyIssue();

  @override
  String get code => 'confirmPassword.empty';
}

/// Confirmation input does not match the original password.
final class ConfirmPasswordMismatchIssue
    extends ConfirmPasswordValidationIssue {
  /// Creates the issue.
  const ConfirmPasswordMismatchIssue();

  @override
  String get code => 'confirmPassword.mismatch';
}

/// Default English messages for confirm-password validation issues.
String resolveConfirmPasswordValidationIssue(
  ConfirmPasswordValidationIssue issue,
) {
  return switch (issue) {
    ConfirmPasswordEmptyIssue() => 'Please confirm your password',
    ConfirmPasswordMismatchIssue() => 'Passwords do not match',
  };
}

/// Validator for confirm-password values.
final class ConfirmPasswordValidator {
  /// Rules used during validation.
  final ConfirmPasswordValidationConfig config;

  /// Creates a confirm-password validator.
  const ConfirmPasswordValidator([
    this.config = const ConfirmPasswordValidationConfig(),
  ]);

  /// Validates a password/confirmation pair.
  ValidationResult<ConfirmPasswordValidationIssue, String> validate({
    required String password,
    required String confirmation,
  }) {
    final normalizedPassword =
        config.trimWhitespace ? password.trim() : password;
    final normalizedConfirmation =
        config.trimWhitespace ? confirmation.trim() : confirmation;

    if (config.requireConfirmation && normalizedConfirmation.isEmpty) {
      return const Left(ConfirmPasswordEmptyIssue());
    }

    if (!config.requireConfirmation && normalizedConfirmation.isEmpty) {
      return Right(normalizedConfirmation);
    }

    if (normalizedConfirmation != normalizedPassword) {
      return const Left(ConfirmPasswordMismatchIssue());
    }

    return Right(normalizedConfirmation);
  }
}
