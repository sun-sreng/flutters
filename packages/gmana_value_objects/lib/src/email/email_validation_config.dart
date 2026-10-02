import 'package:gmana_validation/gmana_validation.dart'
    show kDefaultDisposableDomains;
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

  /// Domains treated as disposable when [rejectDisposable] is enabled.
  ///
  /// Defaults to [kDefaultDisposableDomains], the list `gmana_validation`
  /// uses.
  final Set<String> disposableDomains;

  /// A collection of specific domains that are explicitly blocked.
  final Set<String> blockedDomains;

  /// When true, emails from [disposableDomains] are rejected.
  final bool rejectDisposable;

  /// When true, configured domains also match their subdomains.
  ///
  /// For example, `example.com` also matches `mail.example.com`.
  final bool matchSubdomains;

  /// Creates a new [EmailValidationConfig] with optional overrides.
  ///
  /// [allowDisposable] is the former, inverted spelling of [rejectDisposable]
  /// and is ignored when [rejectDisposable] is given.
  const EmailValidationConfig({
    this.maxLength = 254,
    this.maxLocalPartLength = 64,
    this.maxDomainLength = 253,
    this.disposableDomains = kDefaultDisposableDomains,
    this.blockedDomains = const {},
    bool? rejectDisposable,
    this.matchSubdomains = true,
    @Deprecated(
      'Use rejectDisposable (inverted) instead. '
      'This parameter will be removed before 1.0.',
    )
    bool? allowDisposable,
  }) : rejectDisposable = rejectDisposable ?? !(allowDisposable ?? true);

  /// Creates a strict [EmailValidationConfig] that disallows disposable emails.
  factory EmailValidationConfig.strict() {
    return const EmailValidationConfig(rejectDisposable: true);
  }

  /// Whether disposable email domains are permitted.
  @Deprecated(
    'Use rejectDisposable (inverted) instead. '
    'This getter will be removed before 1.0.',
  )
  bool get allowDisposable => !rejectDisposable;

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// [allowDisposable] is the former, inverted spelling of [rejectDisposable]
  /// and is ignored when [rejectDisposable] is given.
  EmailValidationConfig copyWith({
    int? maxLength,
    int? maxLocalPartLength,
    int? maxDomainLength,
    Set<String>? disposableDomains,
    Set<String>? blockedDomains,
    bool? rejectDisposable,
    bool? matchSubdomains,
    @Deprecated(
      'Use rejectDisposable (inverted) instead. '
      'This parameter will be removed before 1.0.',
    )
    bool? allowDisposable,
  }) {
    return EmailValidationConfig(
      maxLength: maxLength ?? this.maxLength,
      maxLocalPartLength: maxLocalPartLength ?? this.maxLocalPartLength,
      maxDomainLength: maxDomainLength ?? this.maxDomainLength,
      disposableDomains: disposableDomains ?? this.disposableDomains,
      blockedDomains: blockedDomains ?? this.blockedDomains,
      rejectDisposable:
          rejectDisposable ??
          (allowDisposable == null ? this.rejectDisposable : !allowDisposable),
      matchSubdomains: matchSubdomains ?? this.matchSubdomains,
    );
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
