import '../core/validation_issue.dart';
import '../date/date_validation_config.dart';
import '../date/date_validation_issue.dart';
import '../date/date_validator.dart';
import '../email/email_validation_config.dart';
import '../email/email_validation_issue.dart';
import '../email/email_validator.dart';
import '../identifier/identifier_validation_config.dart';
import '../identifier/identifier_validation_issue.dart';
import '../identifier/identifier_validator.dart';
import '../network/network_validation_config.dart';
import '../network/network_validation_issue.dart';
import '../network/network_validator.dart';
import '../number/number_validator.dart';
import '../password/password_validator.dart';
import '../phone/phone_validation_config.dart';
import '../phone/phone_validation_issue.dart';
import '../phone/phone_validator.dart';
import '../text/text_validation_config.dart';
import '../text/text_validation_issue.dart';
import '../text/text_validator.dart';
import '../url/url_validation_config.dart';
import '../url/url_validation_issue.dart';
import '../url/url_validator.dart';

/// Typed validation shortcuts on [String].
///
/// Each method delegates to the corresponding validator and accepts the same
/// configuration object, preserving its normalization and failure semantics.
extension GmanaValidationStringX on String {
  /// Validates this string as a date or time using [config].
  ///
  /// A successful time-only or allowed-empty validation contains `null`;
  /// inspect [ValidationResult] with `isValid` when that distinction matters.
  ValidationResult<DateValidationIssue, DateTime?> validateDate([
    DateValidationConfig config = const DateValidationConfig(),
  ]) => DateValidator(config).validate(this);

  /// Validates and normalizes this string as an email using [config].
  ValidationResult<EmailValidationIssue, String> validateEmail([
    EmailValidationConfig config = const EmailValidationConfig(),
  ]) => EmailValidator(config).validate(this);

  /// Validates this string as an identifier using [config].
  ///
  /// The default configuration accepts any non-empty identifier. Set
  /// [IdentifierValidationConfig.requiredType] to require a specific format.
  ValidationResult<IdentifierValidationIssue, String> validateIdentifier([
    IdentifierValidationConfig config = const IdentifierValidationConfig(),
  ]) => IdentifierValidator(config).validate(this);

  /// Validates this string as a network value using [config].
  ///
  /// The default configuration accepts any non-empty value. Set
  /// [NetworkValidationConfig.requiredType] to require a specific format.
  ValidationResult<NetworkValidationIssue, String> validateNetwork([
    NetworkValidationConfig config = const NetworkValidationConfig(),
  ]) => NetworkValidator(config).validate(this);

  /// Validates and parses this string as a number using [config].
  ValidationResult<NumberValidationIssue, num> validateNumber([
    NumberValidationConfig config = const NumberValidationConfig(),
  ]) => NumberValidator(config).validate(this);

  /// Validates this string as a password using [config].
  ValidationResult<PasswordValidationIssue, String> validatePassword([
    PasswordValidationConfig config = const PasswordValidationConfig(),
  ]) => PasswordValidator(config).validate(this);

  /// Validates and normalizes this string as a phone number using [config].
  ValidationResult<PhoneValidationIssue, String> validatePhone([
    PhoneValidationConfig config = const PhoneValidationConfig(),
  ]) => PhoneValidator(config).validate(this);

  /// Validates and optionally normalizes this string as text using [config].
  ValidationResult<TextValidationIssue, String> validateText([
    TextValidationConfig config = const TextValidationConfig(),
  ]) => TextValidator(config).validate(this);

  /// Validates and parses this string as a URL using [config].
  ValidationResult<UrlValidationIssue, Uri> validateUrl([
    UrlValidationConfig config = const UrlValidationConfig(),
  ]) => UrlValidator(config).validate(this);
}
