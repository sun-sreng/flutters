import 'package:fpdart/fpdart.dart';
import 'email_errors.dart';
import 'email_validation_config.dart';

final class EmailValidator {
  final EmailValidationConfig config;

  // RFC 5322 compliant regex (simplified but robust)
  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  const EmailValidator([this.config = const EmailValidationConfig()]);

  Either<EmailError, String> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(EmailEmpty());
    }

    if (trimmed.length > config.maxLength) {
      return Left(EmailTooLong(currentLength: trimmed.length, maxLength: config.maxLength));
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

    if (localPart.length > config.maxLocalPartLength) {
      return Left(EmailLocalPartTooLong(currentLength: localPart.length, maxLength: config.maxLocalPartLength));
    }

    if (domain.length > config.maxDomainLength) {
      return Left(EmailDomainTooLong(currentLength: domain.length, maxLength: config.maxDomainLength));
    }

    final lowerDomain = domain.toLowerCase();

    if (config.blockedDomains.contains(lowerDomain)) {
      return Left(EmailBlockedDomain(lowerDomain));
    }

    if (!config.allowDisposable && config.disposableDomains.contains(lowerDomain)) {
      return Left(EmailDisposableDomain(lowerDomain));
    }

    return Right(trimmed.toLowerCase());
  }
}
