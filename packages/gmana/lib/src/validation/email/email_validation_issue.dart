import '../core/validation_issue.dart';

/// Default English messages for email validation issues.
String resolveEmailValidationIssue(EmailValidationIssue issue) {
  return issue.defaultMessage;
}

/// Base type for email validation failures.
sealed class EmailValidationIssue extends ValidationIssue {
  /// Creates an email validation issue.
  const EmailValidationIssue();

  /// Default English message.
  String get defaultMessage;
}

/// Email input is empty after trimming.
final class EmailEmptyIssue extends EmailValidationIssue {
  /// Creates an empty-email issue.
  const EmailEmptyIssue();

  @override
  String get code => 'email.empty';

  @override
  String get defaultMessage => 'Please enter an email address';
}

/// Email input does not match the supported address format.
final class EmailInvalidFormatIssue extends EmailValidationIssue {
  /// Creates an invalid-format issue.
  const EmailInvalidFormatIssue();

  @override
  String get code => 'email.invalidFormat';

  @override
  String get defaultMessage => 'Please enter a valid email address';
}

/// Email address exceeds the configured maximum total length.
final class EmailTooLongIssue extends EmailValidationIssue {
  /// The provided email length.
  final int currentLength;

  /// The configured maximum email length.
  final int maxLength;

  /// Creates an email-too-long issue.
  const EmailTooLongIssue({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  String get code => 'email.tooLong';

  @override
  String get defaultMessage => 'Email must not exceed $maxLength characters';
}

/// Email local part exceeds the configured maximum length.
final class EmailLocalPartTooLongIssue extends EmailValidationIssue {
  /// The provided local-part length.
  final int currentLength;

  /// The configured maximum local-part length.
  final int maxLength;

  /// Creates a local-part-too-long issue.
  const EmailLocalPartTooLongIssue({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  String get code => 'email.localPartTooLong';

  @override
  String get defaultMessage =>
      'Email name must not exceed $maxLength characters';
}

/// Email domain exceeds the configured maximum length.
final class EmailDomainTooLongIssue extends EmailValidationIssue {
  /// The provided domain length.
  final int currentLength;

  /// The configured maximum domain length.
  final int maxLength;

  /// Creates a domain-too-long issue.
  const EmailDomainTooLongIssue({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  String get code => 'email.domainTooLong';

  @override
  String get defaultMessage =>
      'Email domain must not exceed $maxLength characters';
}

/// Email domain appears in the configured block list.
final class EmailBlockedDomainIssue extends EmailValidationIssue {
  /// The rejected domain.
  final String domain;

  /// Creates a blocked-domain issue.
  const EmailBlockedDomainIssue(this.domain);

  @override
  String get code => 'email.blockedDomain';

  @override
  String get defaultMessage => 'Email domain is not allowed';
}

/// Email domain appears in the configured disposable-domain list.
final class EmailDisposableDomainIssue extends EmailValidationIssue {
  /// The rejected domain.
  final String domain;

  /// Creates a disposable-domain issue.
  const EmailDisposableDomainIssue(this.domain);

  @override
  String get code => 'email.disposableDomain';

  @override
  String get defaultMessage => 'Disposable email addresses are not allowed';
}
