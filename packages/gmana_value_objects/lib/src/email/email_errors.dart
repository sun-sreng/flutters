import '../core/validation_error.dart';

/// Base class for all email-related validation errors.
sealed class EmailError extends ValidationError {
  /// Internal constructor for [EmailError].
  const EmailError();
}

/// Error indicating that the email string is empty.
final class EmailEmpty extends EmailError {
  /// Creates a new [EmailEmpty] error.
  const EmailEmpty();

  @override
  String get code => 'email_empty';
}

/// Error indicating that the email does not match the valid format.
final class EmailInvalidFormat extends EmailError {
  /// Creates a new [EmailInvalidFormat] error.
  const EmailInvalidFormat();

  @override
  String get code => 'email_invalid_format';
}

/// Error indicating that the entire email exceeds the maximum allowed length.
final class EmailTooLong extends EmailError {
  /// The length of the provided email string.
  final int currentLength;

  /// The maximum allowed length.
  final int maxLength;

  /// Creates a new [EmailTooLong] error.
  const EmailTooLong({required this.currentLength, required this.maxLength});

  @override
  String get code => 'email_too_long';
}

/// Error indicating that the local part of the email exceeds the maximum allowed length.
final class EmailLocalPartTooLong extends EmailError {
  /// The current length of the local part.
  final int currentLength;

  /// The maximum allowed length for the local part.
  final int maxLength;

  /// Creates a new [EmailLocalPartTooLong] error.
  const EmailLocalPartTooLong({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  String get code => 'email_local_part_too_long';
}

/// Error indicating that the domain part of the email exceeds the maximum allowed length.
final class EmailDomainTooLong extends EmailError {
  /// The current length of the domain part.
  final int currentLength;

  /// The maximum allowed length for the domain.
  final int maxLength;

  /// Creates a new [EmailDomainTooLong] error.
  const EmailDomainTooLong({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  String get code => 'email_domain_too_long';
}

/// Error indicating that the email belongs to a disposable domain list.
final class EmailDisposableDomain extends EmailError {
  /// The disposable domain that was rejected.
  final String domain;

  /// Creates a new [EmailDisposableDomain] error.
  const EmailDisposableDomain(this.domain);

  @override
  String get code => 'email_disposable_domain';
}

/// Error indicating that the email belongs to a blocked domain list.
final class EmailBlockedDomain extends EmailError {
  /// The blocked domain that was rejected.
  final String domain;

  /// Creates a new [EmailBlockedDomain] error.
  const EmailBlockedDomain(this.domain);

  @override
  String get code => 'email_blocked_domain';
}
