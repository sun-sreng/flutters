import 'package:meta/meta.dart';

import '../core/set_equality.dart';
import 'email_disposable.dart';

/// Configuration rules for email validation.
@immutable
final class EmailValidationConfig {
  /// Maximum allowed length for the entire normalized email address.
  final int maxLength;

  /// Maximum allowed length for the local part before `@`.
  final int maxLocalPartLength;

  /// Maximum allowed length for the domain part after `@`.
  final int maxDomainLength;

  /// Domains treated as disposable when [rejectDisposable] is enabled.
  final Set<String> disposableDomains;

  /// Domains that should always be rejected.
  final Set<String> blockedDomains;

  /// When true, emails from [disposableDomains] are rejected.
  final bool rejectDisposable;

  /// When true, configured domains also match their subdomains.
  ///
  /// For example, `example.com` also matches `mail.example.com`.
  final bool matchSubdomains;

  /// Creates email validation configuration.
  const EmailValidationConfig({
    this.maxLength = 254,
    this.maxLocalPartLength = 64,
    this.maxDomainLength = 253,
    this.disposableDomains = kDefaultDisposableDomains,
    this.blockedDomains = const {},
    this.rejectDisposable = false,
    this.matchSubdomains = true,
  }) : assert(maxLength > 0, 'maxLength must be greater than zero'),
       assert(
         maxLocalPartLength > 0,
         'maxLocalPartLength must be greater than zero',
       ),
       assert(maxDomainLength > 0, 'maxDomainLength must be greater than zero');

  /// Rejects disposable domains using the default list.
  factory EmailValidationConfig.strict() {
    return const EmailValidationConfig(rejectDisposable: true);
  }

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Omitted fields retain their current values.
  EmailValidationConfig copyWith({
    int? maxLength,
    int? maxLocalPartLength,
    int? maxDomainLength,
    Set<String>? disposableDomains,
    Set<String>? blockedDomains,
    bool? rejectDisposable,
    bool? matchSubdomains,
  }) {
    return EmailValidationConfig(
      maxLength: maxLength ?? this.maxLength,
      maxLocalPartLength: maxLocalPartLength ?? this.maxLocalPartLength,
      maxDomainLength: maxDomainLength ?? this.maxDomainLength,
      disposableDomains: disposableDomains ?? this.disposableDomains,
      blockedDomains: blockedDomains ?? this.blockedDomains,
      rejectDisposable: rejectDisposable ?? this.rejectDisposable,
      matchSubdomains: matchSubdomains ?? this.matchSubdomains,
    );
  }

  /// Normalizes a domain for policy matching.
  String normalizeDomain(String domain) {
    return domain.trim().toLowerCase();
  }

  /// Returns true when [domain] is blocked by [blockedDomains].
  bool isBlockedDomain(String domain) {
    return _matchesConfiguredDomain(domain, blockedDomains);
  }

  /// Returns true when [domain] is disposable and [rejectDisposable] is enabled.
  bool isDisposableDomain(String domain) {
    return rejectDisposable &&
        _matchesConfiguredDomain(domain, disposableDomains);
  }

  bool _matchesConfiguredDomain(String domain, Set<String> configuredDomains) {
    final normalizedDomain = normalizeDomain(domain);

    for (final configuredDomain in configuredDomains) {
      final normalizedConfiguredDomain = normalizeDomain(configuredDomain);
      if (normalizedConfiguredDomain.isEmpty) continue;
      if (normalizedDomain == normalizedConfiguredDomain) return true;
      if (matchSubdomains &&
          normalizedDomain.endsWith('.$normalizedConfiguredDomain')) {
        return true;
      }
    }

    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailValidationConfig &&
          other.maxLength == maxLength &&
          other.maxLocalPartLength == maxLocalPartLength &&
          other.maxDomainLength == maxDomainLength &&
          other.rejectDisposable == rejectDisposable &&
          other.matchSubdomains == matchSubdomains &&
          setEquals(other.disposableDomains, disposableDomains) &&
          setEquals(other.blockedDomains, blockedDomains);

  @override
  int get hashCode => Object.hash(
    maxLength,
    maxLocalPartLength,
    maxDomainLength,
    rejectDisposable,
    matchSubdomains,
    Object.hashAllUnordered(disposableDomains),
    Object.hashAllUnordered(blockedDomains),
  );
}
