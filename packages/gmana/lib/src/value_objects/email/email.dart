import '../../../functional.dart';
import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import '../../validation/email/email_validation_config.dart';
import '../../validation/email/email_validation_issue.dart';
import '../../validation/email/email_validator.dart';

/// A value object representing a validated email address.
///
/// An [Email] is always valid: its [value] is trimmed and lowercased and has
/// passed the configured [EmailValidationConfig]. Use [Email.tryParse] for
/// untrusted input and the [Email] constructor for trusted literals.
final class Email extends ValueObject<String> {
  /// The validated, normalized email address.
  @override
  final String value;

  const Email._(this.value);

  /// Validates [input], throwing [ValueObjectException] when it is invalid.
  ///
  /// Prefer [tryParse] for user input; use this constructor for trusted
  /// literals where an invalid value is a programming error.
  factory Email(
    String input, {
    EmailValidationConfig config = const EmailValidationConfig(),
  }) {
    return tryParse(
      input,
      config: config,
    ).getOrElse((error) => throw ValueObjectException(error));
  }

  /// Validates [input] and returns the [Email] or an [EmailValidationIssue].
  ///
  /// An optional [config] customizes the validation rules.
  static Either<EmailValidationIssue, Email> tryParse(
    String input, {
    EmailValidationConfig config = const EmailValidationConfig(),
  }) {
    return EmailValidator(config).validate(input).map(Email._);
  }
}
