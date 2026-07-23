import 'package:gmana_functional/gmana_functional.dart';
import 'email_errors.dart';
import 'email_validation_config.dart';

/// A validator class for email addresses that conforms to an [EmailValidationConfig].
final class EmailValidator {
  /// The configuration rules to apply during validation.
  final EmailValidationConfig config;

  // RFC 5322 compliant regex (simplified but robust)
  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  /// Creates a new [EmailValidator].
  ///
  /// If [config] is not provided, the default [EmailValidationConfig] will be used.
  const EmailValidator([this.config = const EmailValidationConfig()]);

  /// Validates the given [input] string as an email address.
  ///
  /// Returns a `Right` containing the sanitized (trimmed and lowercased) email
  /// if it is valid. Otherwise, returns a `Left` containing the specific [EmailError]
  /// detailing why the validation failed.
  Either<EmailError, String> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(EmailEmpty());
    }

    if (trimmed.length > config.maxLength) {
      return Left(
        EmailTooLong(
          currentLength: trimmed.length,
          maxLength: config.maxLength,
        ),
      );
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return const Left(EmailInvalidFormat());
    }

    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return const Left(EmailInvalidFormat());
    }

    final localPart = parts[0];
    final domain = parts[1];

    // RFC 5321: the local part may not start or end with a dot, nor contain
    // consecutive dots. The format regex allows dots anywhere, so reject these
    // explicitly. (Domain dot placement is already enforced by the regex.)
    if (localPart.startsWith('.') ||
        localPart.endsWith('.') ||
        localPart.contains('..')) {
      return const Left(EmailInvalidFormat());
    }

    if (localPart.length > config.maxLocalPartLength) {
      return Left(
        EmailLocalPartTooLong(
          currentLength: localPart.length,
          maxLength: config.maxLocalPartLength,
        ),
      );
    }

    if (domain.length > config.maxDomainLength) {
      return Left(
        EmailDomainTooLong(
          currentLength: domain.length,
          maxLength: config.maxDomainLength,
        ),
      );
    }

    final lowerDomain = domain.toLowerCase();

    if (config.blockedDomains.isNotEmpty) {
      final blockedDomains =
          config.blockedDomains.map(_normalizeDomain).toSet();
      if (blockedDomains.contains(lowerDomain)) {
        return Left(EmailBlockedDomain(lowerDomain));
      }
    }

    // Disposable domains are only normalized and scanned when they are actually
    // enforced, so the default (allowDisposable: true) path does no extra work.
    if (!config.allowDisposable) {
      final disposableDomains =
          config.disposableDomains.map(_normalizeDomain).toSet();
      if (disposableDomains.contains(lowerDomain)) {
        return Left(EmailDisposableDomain(lowerDomain));
      }
    }

    return Right(trimmed.toLowerCase());
  }

  String _normalizeDomain(String domain) {
    return domain.trim().toLowerCase();
  }
}
