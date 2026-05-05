import 'package:gmana/gmana.dart' show Either;
import '../core/value_object.dart';
import 'email_errors.dart';
import 'email_validation_config.dart';
import 'email_validator.dart';

/// A value object representing a validated email address.
///
/// Holds either an [EmailError] if validation fails, or the raw [String] if it succeeds.
final class Email extends ValueObject<String> {
  /// The underlying value, which is either an [EmailError] or a valid [String].
  @override
  final Either<EmailError, String> value;

  /// Creates a new [Email] instance by validating the given [input].
  ///
  /// An optional [config] can be provided to customize the validation rules.
  factory Email(
    String input, {
    EmailValidationConfig config = const EmailValidationConfig(),
  }) {
    final validator = EmailValidator(config);
    return Email._(validator.validate(input));
  }

  /// Creates a new [Email] instance directly from a validated [Either].
  factory Email.validated(Either<EmailError, String> validated) {
    return Email._(validated);
  }

  /// Internal constructor for [Email].
  const Email._(this.value);

  /// Returns a string representation of the [Email].
  @override
  String toString() => 'Email(${valueOrNull ?? 'invalid'})';
}
