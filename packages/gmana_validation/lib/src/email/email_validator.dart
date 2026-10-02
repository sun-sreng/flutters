import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_predicates/gmana_predicates.dart' show isEmail;

import '../core/validation_issue.dart';
import 'email_validation_config.dart';
import 'email_validation_issue.dart';

/// Validates and normalizes email addresses.
final class EmailValidator {
  /// Rules used during validation.
  final EmailValidationConfig config;

  /// Creates an email validator.
  const EmailValidator([this.config = const EmailValidationConfig()]);

  /// Validates [input] and returns the normalized email on success.
  ValidationResult<EmailValidationIssue, String> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) return const Left(EmailEmptyIssue());

    // Format check first; length errors on garbage input are misleading.
    if (!isEmail(trimmed)) {
      return const Left(EmailInvalidFormatIssue());
    }

    // isEmail guarantees exactly one '@', but explicit extraction keeps the
    // subsequent policy checks clear.
    final atIndex = trimmed.indexOf('@');
    final localPart = trimmed.substring(0, atIndex);
    final domain = trimmed.substring(atIndex + 1);

    if (!_hasValidLocalPartDots(localPart)) {
      return const Left(EmailInvalidFormatIssue());
    }

    if (trimmed.length > config.maxLength) {
      return Left(
        EmailTooLongIssue(
          currentLength: trimmed.length,
          maxLength: config.maxLength,
        ),
      );
    }

    if (localPart.length > config.maxLocalPartLength) {
      return Left(
        EmailLocalPartTooLongIssue(
          currentLength: localPart.length,
          maxLength: config.maxLocalPartLength,
        ),
      );
    }

    if (domain.length > config.maxDomainLength) {
      return Left(
        EmailDomainTooLongIssue(
          currentLength: domain.length,
          maxLength: config.maxDomainLength,
        ),
      );
    }

    final normalizedDomain = config.normalizeDomain(domain);

    if (config.isBlockedDomain(normalizedDomain)) {
      return Left(EmailBlockedDomainIssue(normalizedDomain));
    }

    if (config.isDisposableDomain(normalizedDomain)) {
      return Left(EmailDisposableDomainIssue(normalizedDomain));
    }

    // RFC 5321: local part is technically case-sensitive, but virtually all
    // providers normalize to lowercase. We do the same for storage consistency.
    return Right('${localPart.toLowerCase()}@$normalizedDomain');
  }

  static bool _hasValidLocalPartDots(String localPart) {
    return !localPart.startsWith('.') &&
        !localPart.endsWith('.') &&
        !localPart.contains('..');
  }
}
