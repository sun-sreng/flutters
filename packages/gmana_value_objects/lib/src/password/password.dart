import 'package:gmana_functional/gmana_functional.dart';
import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import 'password_errors.dart';
import 'password_validation_config.dart';
import 'password_validator.dart';

/// A value object representing a validated password.
///
/// A [Password] is always valid: its [value] has passed the configured
/// [PasswordValidationConfig]. The value is [isSensitive], so it is masked in
/// [toString] output. Use [Password.tryParse] for untrusted input and the
/// [Password] constructor for trusted literals.
final class Password extends ValueObject<String> {
  /// The validated password.
  @override
  final String value;

  const Password._(this.value);

  /// Validates [input], throwing [ValueObjectException] when it is invalid.
  ///
  /// Prefer [tryParse] for user input.
  factory Password(
    String input, {
    PasswordValidationConfig config = const PasswordValidationConfig(),
  }) {
    return tryParse(
      input,
      config: config,
    ).getOrElse((error) => throw ValueObjectException(error));
  }

  /// Validates [input] and returns the [Password] or a [PasswordError].
  static Either<PasswordError, Password> tryParse(
    String input, {
    PasswordValidationConfig config = const PasswordValidationConfig(),
  }) {
    return PasswordValidator(config).validate(input).map(Password._);
  }

  /// Passwords are sensitive, so [value] is masked in [toString].
  @override
  bool get isSensitive => true;
}
