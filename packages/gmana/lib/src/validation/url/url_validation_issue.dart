import '../core/validation_issue.dart';

/// Default English messages for URL validation issues.
String resolveUrlValidationIssue(UrlValidationIssue issue) {
  return switch (issue) {
    UrlEmptyIssue() => 'Please enter a URL',
    UrlInvalidFormatIssue() => 'Please enter a valid URL',
    UrlDisallowedSchemeIssue(:final scheme) =>
      'Scheme "$scheme" is not allowed',
    UrlMissingHostIssue() => 'URL must include a host address',
  };
}

/// Base type for URL validation failures.
sealed class UrlValidationIssue extends ValidationIssue {
  /// Creates a URL validation issue.
  const UrlValidationIssue();
}

/// URL input is empty.
final class UrlEmptyIssue extends UrlValidationIssue {
  /// Creates a URL-empty issue.
  const UrlEmptyIssue();

  @override
  String get code => 'url.empty';
}

/// URL string is malformed or cannot be parsed.
final class UrlInvalidFormatIssue extends UrlValidationIssue {
  /// Creates a URL-invalid-format issue.
  const UrlInvalidFormatIssue();

  @override
  String get code => 'url.invalidFormat';
}

/// URL scheme is not allowed by configuration.
final class UrlDisallowedSchemeIssue extends UrlValidationIssue {
  /// The provided scheme.
  final String scheme;

  /// Creates a URL-disallowed-scheme issue.
  const UrlDisallowedSchemeIssue(this.scheme);

  @override
  String get code => 'url.disallowedScheme';
}

/// URL is missing a host address.
final class UrlMissingHostIssue extends UrlValidationIssue {
  /// Creates a URL-missing-host issue.
  const UrlMissingHostIssue();

  @override
  String get code => 'url.missingHost';
}
