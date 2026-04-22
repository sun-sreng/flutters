import 'package:gmana/regex/digit_reg.dart';
import 'package:gmana/regex/email_reg.dart';
import 'package:gmana/regex/lower_case_reg.dart';
import 'package:gmana/regex/phone_reg.dart';
import 'package:gmana/regex/special_char_reg.dart';
import 'package:gmana/regex/upper_case_reg.dart';
import 'package:gmana/regex/url_reg.dart';

import 'validation_rule.dart';

/// A utility class that provides reusable validation rules for form fields.
///
/// This class contains static methods to create [ValidationRule] instances
/// for common validation needs such as checking required fields, email format,
/// password strength, phone number, and more.
class Validators {
  /// Combines multiple [rules] into a single validation rule.
  ///
  /// Returns the provided [message] if any rule fails.
  static ValidationRule combine(List<ValidationRule> rules, {String? message}) {
    return ValidationRule((value) {
      for (final rule in rules) {
        final error = rule(value);
        if (error != null) return '';
      }
      return null;
    }, message ?? 'Validation failed');
  }

  /// Creates a custom validation rule using the provided [func].
  ///
  /// The [func] returns `null` for a valid value or a non-null value for error.
  static ValidationRule custom(
    ValidationFunction func, {
    required String message,
  }) {
    return ValidationRule(func, message);
  }

  /// Returns a rule that validates if a value is a valid email address.
  static ValidationRule email({String message = 'Invalid email format'}) {
    return ValidationRule(
      (value) => emailReg.hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Returns a rule that checks if a value does not exceed [length] characters.
  static ValidationRule maxLength(int length, {String? message}) {
    return ValidationRule(
      (value) => value != null && value.length <= length ? null : '',
      message ?? 'Must not exceed $length characters',
    );
  }

  /// Returns a rule that checks if a value is at least [length] characters.
  static ValidationRule minLength(int length, {String? message}) {
    return ValidationRule(
      (value) => value != null && value.length >= length ? null : '',
      message ?? 'Must be at least $length characters long',
    );
  }

  /// Returns a rule that requires at least one lowercase letter.
  static ValidationRule oneLowerCase({
    String message = 'Must contain at least one lowercase letter',
  }) {
    return ValidationRule(
      (value) => lowerCaseReg.hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Returns a rule that requires at least one numeric digit.
  static ValidationRule oneNumber({
    String message = 'Must contain at least one number',
  }) {
    return ValidationRule(
      (value) => digitReg.hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Returns a rule that requires at least one special character.
  static ValidationRule oneSpecial({
    String message = 'Must contain at least one special character',
  }) {
    return ValidationRule(
      (value) => specialCharReg.hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Returns a rule that requires at least one uppercase letter.
  static ValidationRule oneUpperCase({
    String message = 'Must contain at least one uppercase letter',
  }) {
    return ValidationRule(
      (value) => upperCaseReg.hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Returns a rule that checks if a value matches the given [pattern].
  static ValidationRule pattern(String pattern, {required String message}) {
    return ValidationRule(
      (value) => RegExp(pattern).hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Returns a rule that checks if a value is a valid phone number.
  static ValidationRule phoneNumber({String message = 'Invalid phone number'}) {
    return ValidationRule(
      (value) => phoneReg.hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Returns a rule that ensures the value is not empty.
  static ValidationRule required({String message = 'This field is required'}) {
    return ValidationRule(
      (value) => value?.isNotEmpty == true ? null : '',
      message,
    );
  }

  /// Returns a rule that checks if a value is a valid URL.
  static ValidationRule url({String message = 'Invalid URL'}) {
    return ValidationRule(
      (value) => urlReg.hasMatch(value ?? '') ? null : '',
      message,
    );
  }

  /// Runs a list of [rules] against the given [value].
  ///
  /// Returns the first error message encountered, or `null` if all rules pass.
  static String? validate(String? value, List<ValidationRule> rules) {
    for (final rule in rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  }
}
