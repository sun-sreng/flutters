import '../core/validation_error.dart';

/// Base class for all password validation errors.
sealed class PasswordError extends ValidationError {
  /// Internal constructor for [PasswordError].
  const PasswordError();
}

/// Error indicating that the password string is empty.
final class PasswordEmpty extends PasswordError {
  /// Creates a new [PasswordEmpty] error.
  const PasswordEmpty();

  @override
  String get code => 'password_empty';
}

/// Error indicating that the password does not meet the minimum length requirement.
final class PasswordTooShort extends PasswordError {
  /// The length of the provided password.
  final int currentLength;

  /// The minimum allowed length.
  final int minLength;

  /// Creates a new [PasswordTooShort] error.
  const PasswordTooShort({
    required this.currentLength,
    required this.minLength,
  });

  @override
  String get code => 'password_too_short';
}

/// Error indicating that the password exceeds the maximum allowed length.
final class PasswordTooLong extends PasswordError {
  /// The length of the provided password.
  final int currentLength;

  /// The maximum allowed length.
  final int maxLength;

  /// Creates a new [PasswordTooLong] error.
  const PasswordTooLong({required this.currentLength, required this.maxLength});

  @override
  String get code => 'password_too_long';
}

/// Error indicating that the password contains non-ASCII characters.
final class PasswordNonAscii extends PasswordError {
  /// Creates a new [PasswordNonAscii] error.
  const PasswordNonAscii();

  @override
  String get code => 'password_non_ascii';
}

/// Error indicating that the password is among the known list of common passwords.
final class PasswordTooCommon extends PasswordError {
  /// Creates a new [PasswordTooCommon] error.
  const PasswordTooCommon();

  @override
  String get code => 'password_too_common';
}

/// Error indicating that the password does not pass basic complexity checks.
final class PasswordTooWeak extends PasswordError {
  /// Creates a new [PasswordTooWeak] error.
  const PasswordTooWeak();

  @override
  String get code => 'password_too_weak';
}

/// Error indicating that the password contains predictable patterns or sequences.
final class PasswordTooPredictable extends PasswordError {
  /// Creates a new [PasswordTooPredictable] error.
  const PasswordTooPredictable();

  @override
  String get code => 'password_too_predictable';
}

/// Error indicating that the password did not meet the required complexity score.
final class PasswordComplexityRequired extends PasswordError {
  /// The complexity score evaluated for the password.
  final int currentScore;

  /// The minimum required complexity score.
  final int requiredScore;

  /// Creates a new [PasswordComplexityRequired] error.
  const PasswordComplexityRequired({
    required this.currentScore,
    required this.requiredScore,
  });

  @override
  String get code => 'password_complexity_required';
}
