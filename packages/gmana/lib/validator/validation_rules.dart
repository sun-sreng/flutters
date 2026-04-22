import 'validation_rule.dart';
import 'validators.dart';

/// A collection of predefined validation rule sets for common form fields.
///
/// These rules can be used directly in form validators to ensure consistent
/// input validation across your application.
class ValidationRules {
  /// Validation rules for an email field.
  ///
  /// Includes:
  /// - Required field
  /// - Must match email pattern
  static final List<ValidationRule> email = [
    Validators.required(message: 'Email is required'),
    Validators.email(message: 'Please enter a valid email address'),
  ];

  /// Validation rules for a standard password field.
  ///
  /// Enforces a strong password by requiring:
  /// - At least 8 characters
  /// - One uppercase letter
  /// - One lowercase letter
  /// - One number
  /// - One special character
  static final List<ValidationRule> password = [
    Validators.required(message: 'Password is required'),
    Validators.minLength(8, message: 'Minimum 8 characters'),
    Validators.oneUpperCase(message: 'At least one uppercase letter'),
    Validators.oneLowerCase(message: 'At least one lowercase letter'),
    Validators.oneNumber(message: 'At least one number'),
    Validators.oneSpecial(message: 'At least one special character'),
  ];

  /// Validation rules for a username field.
  ///
  /// Enforces:
  /// - Required field
  /// - 3 to 20 characters long
  /// - No `@` symbol allowed
  static final List<ValidationRule> username = [
    Validators.required(message: 'Username is required'),
    Validators.minLength(3, message: 'Minimum 3 characters'),
    Validators.maxLength(20, message: 'Maximum 20 characters'),
    Validators.custom(
      (value) => value?.contains('@') == true ? '' : null,
      message: 'Cannot contain @ symbol',
    ),
  ];

  /// Validation rules for a one-time password (OTP) field.
  ///
  /// Enforces:
  /// - Required field
  /// - Exactly 6 digits
  /// - Only numeric characters
  static final List<ValidationRule> otp = [
    Validators.required(message: 'OTP is required'),
    Validators.minLength(6, message: 'Must be 6 digits'),
    Validators.maxLength(6, message: 'Must be 6 digits'),
    Validators.pattern(r'^\d+$', message: 'Must contain only digits'),
  ];
}
