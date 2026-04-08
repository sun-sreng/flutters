import 'package:fpdart/fpdart.dart';
import '../core/value_object.dart';
import 'password_errors.dart';
import 'password_validation_config.dart';
import 'password_validator.dart';

final class Password extends ValueObject<String> {
  @override
  final Either<PasswordError, String> value;

  factory Password(String input, {PasswordValidationConfig config = const PasswordValidationConfig()}) {
    final validator = PasswordValidator(config);
    return Password._(validator.validate(input));
  }

  factory Password.validated(Either<PasswordError, String> validated) {
    return Password._(validated);
  }

  const Password._(this.value);

  @override
  bool get isSensitive => true;

  @override
  String toString() => 'Password(${isValid ? 'valid' : 'invalid'})';
}
