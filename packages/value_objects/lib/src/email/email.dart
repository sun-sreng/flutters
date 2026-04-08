import 'package:fpdart/fpdart.dart';
import '../core/value_object.dart';
import 'email_errors.dart';
import 'email_validation_config.dart';
import 'email_validator.dart';

final class Email extends ValueObject<String> {
  @override
  final Either<EmailError, String> value;

  factory Email(String input, {EmailValidationConfig config = const EmailValidationConfig()}) {
    final validator = EmailValidator(config);
    return Email._(validator.validate(input));
  }

  factory Email.validated(Either<EmailError, String> validated) {
    return Email._(validated);
  }

  const Email._(this.value);

  @override
  String toString() => 'Email(${valueOrNull ?? 'invalid'})';
}
