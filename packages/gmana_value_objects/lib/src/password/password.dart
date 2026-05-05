import 'package:gmana/gmana.dart' show Either;
import '../core/value_object.dart';
import 'password_errors.dart';
import 'password_validation_config.dart';
import 'password_validator.dart';

/// A value object representing a validated password.
///
/// Holds either a [PasswordError] if validation fails, or the successful [String] value.
final class Password extends ValueObject<String> {
  /// The underlying value, which is either a [PasswordError] or a valid [String].
  @override
  final Either<PasswordError, String> value;

  /// Creates a new [Password] instance by validating the given [input].
  ///
  /// The [config] allows customizable validation rules.
  factory Password(
    String input, {
    PasswordValidationConfig config = const PasswordValidationConfig(),
  }) {
    final validator = PasswordValidator(config);
    return Password._(validator.validate(input));
  }

  /// Creates a new [Password] instance directly from a validated [Either].
  factory Password.validated(Either<PasswordError, String> validated) {
    return Password._(validated);
  }

  /// Internal constructor for [Password].
  const Password._(this.value);

  /// Indicates that [Password] data is sensitive and should be handled with care.
  @override
  bool get isSensitive => true;

  /// A string representation of this password object, masking the actual value.
  @override
  String toString() => 'Password(${isValid ? 'valid' : 'invalid'})';
}
