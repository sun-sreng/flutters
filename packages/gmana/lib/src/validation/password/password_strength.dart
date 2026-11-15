import 'password_validator.dart';

/// Represents the strength grading of a given password.
class PasswordStrength {
  /// Whether the password meets the minimum length requirement.
  final bool hasMinLength;

  /// Whether the password contains at least one uppercase letter.
  final bool hasUppercase;

  /// Whether the password contains at least one lowercase letter.
  final bool hasLowercase;

  /// Whether the password contains at least one digit.
  final bool hasDigit;

  /// Whether the password contains at least one special character.
  final bool hasSpecial;

  /// Constructs a [PasswordStrength] instance.
  const PasswordStrength({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecial,
  });

  /// Computes password strength against the default [PasswordValidationConfig].
  factory PasswordStrength.of(String password) {
    return PasswordStrength.fromConfig(
      password,
      const PasswordValidationConfig(),
    );
  }

  /// Computes password strength against a custom [config].
  factory PasswordStrength.fromConfig(
    String password,
    PasswordValidationConfig config,
  ) {
    return PasswordStrength(
      hasMinLength: password.length >= config.minLength,
      hasUppercase: PasswordValidator.hasUppercase(password),
      hasLowercase: PasswordValidator.hasLowercase(password),
      hasDigit: PasswordValidator.hasDigit(password),
      hasSpecial: PasswordValidator.hasSpecialCharacter(password),
    );
  }

  /// Returns true if all password strength criteria are satisfied.
  bool get isStrong =>
      hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecial;

  /// 0–5 score, useful for a strength indicator bar.
  int get score =>
      [
        hasMinLength,
        hasUppercase,
        hasLowercase,
        hasDigit,
        hasSpecial,
      ].where((v) => v).length;

  /// Returns a list of strings detailing which requirements have not yet been met.
  List<String> get unmetRequirements => [
    if (!hasMinLength) 'At least 8 characters',
    if (!hasUppercase) 'One uppercase letter',
    if (!hasLowercase) 'One lowercase letter',
    if (!hasDigit) 'One number',
    if (!hasSpecial) 'One special character',
  ];
}
