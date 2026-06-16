import 'package:meta/meta.dart';

import '../core/collection_equality.dart';

/// Configuration options for email validation.
///
/// This class holds various limits and rules used by `EmailValidator`.
@immutable
final class EmailValidationConfig {
  /// The maximum allowed length for the entire email string.
  final int maxLength;

  /// The maximum allowed length for the local part (before the '@').
  final int maxLocalPartLength;

  /// The maximum allowed length for the domain part (after the '@').
  final int maxDomainLength;

  /// A collection of known disposable email domains to look out for.
  final Set<String> disposableDomains;

  /// A collection of specific domains that are explicitly blocked.
  final Set<String> blockedDomains;

  /// Whether disposable email domains are permitted.
  final bool allowDisposable;

  /// Creates a new [EmailValidationConfig] with optional overrides.
  const EmailValidationConfig({
    this.maxLength = 254,
    this.maxLocalPartLength = 64,
    this.maxDomainLength = 253,
    this.disposableDomains = _defaultDisposableDomains,
    this.blockedDomains = const {},
    this.allowDisposable = true,
  });

  /// Creates a strict [EmailValidationConfig] that disallows disposable emails.
  factory EmailValidationConfig.strict() {
    return const EmailValidationConfig(allowDisposable: false);
  }

  /// Returns a copy of this config with the given fields replaced.
  EmailValidationConfig copyWith({
    int? maxLength,
    int? maxLocalPartLength,
    int? maxDomainLength,
    Set<String>? disposableDomains,
    Set<String>? blockedDomains,
    bool? allowDisposable,
  }) {
    return EmailValidationConfig(
      maxLength: maxLength ?? this.maxLength,
      maxLocalPartLength: maxLocalPartLength ?? this.maxLocalPartLength,
      maxDomainLength: maxDomainLength ?? this.maxDomainLength,
      disposableDomains: disposableDomains ?? this.disposableDomains,
      blockedDomains: blockedDomains ?? this.blockedDomains,
      allowDisposable: allowDisposable ?? this.allowDisposable,
    );
  }

  static const Set<String> _defaultDisposableDomains = {
    'tempmail.com',
    'guerrillamail.com',
    'mailinator.com',
    '10minutemail.com',
    'throwaway.email',
    'temp-mail.org',
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailValidationConfig &&
          other.maxLength == maxLength &&
          other.maxLocalPartLength == maxLocalPartLength &&
          other.maxDomainLength == maxDomainLength &&
          other.allowDisposable == allowDisposable &&
          setEquals(other.disposableDomains, disposableDomains) &&
          setEquals(other.blockedDomains, blockedDomains);

  @override
  int get hashCode => Object.hash(
    maxLength,
    maxLocalPartLength,
    maxDomainLength,
    allowDisposable,
    Object.hashAllUnordered(disposableDomains),
    Object.hashAllUnordered(blockedDomains),
  );
}
