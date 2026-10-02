import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../extensions/validation_adapter_extensions.dart';
import 'email_errors.dart';
import 'email_validation_config.dart';

/// A validator class for email addresses that conforms to an [EmailValidationConfig].
final class EmailValidator {
  /// The configuration rules to apply during validation.
  final EmailValidationConfig config;

  /// Creates a new [EmailValidator].
  const EmailValidator([this.config = const EmailValidationConfig()]);

  /// Validates the given [input] string as an email address.
  Either<EmailError, String> validate(String input) {
    final vConfig = v.EmailValidationConfig(
      maxLength: config.maxLength,
      maxLocalPartLength: config.maxLocalPartLength,
      maxDomainLength: config.maxDomainLength,
      disposableDomains: config.disposableDomains,
      blockedDomains: config.blockedDomains,
      rejectDisposable: config.rejectDisposable,
      matchSubdomains: config.matchSubdomains,
    );
    return v.EmailValidator(
      vConfig,
    ).validate(input).fold((issue) => Left(issue.toEmailError()), Right.new);
  }
}
