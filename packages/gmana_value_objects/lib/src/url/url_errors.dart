import '../core/validation_error.dart';

/// Sealed hierarchy of URL validation errors.
sealed class UrlError extends ValidationError {
  /// Creates a URL validation error.
  const UrlError();
}

/// URL input is empty.
final class UrlEmpty extends UrlError {
  /// Creates a URL-empty error.
  const UrlEmpty();

  @override
  String get code => 'url.empty';
}

/// URL format is invalid or cannot be parsed.
final class UrlInvalidFormat extends UrlError {
  /// Creates a URL-invalid-format error.
  const UrlInvalidFormat();

  @override
  String get code => 'url.invalidFormat';
}

/// URL scheme is not allowed by configuration.
final class UrlDisallowedScheme extends UrlError {
  /// The provided scheme.
  final String scheme;

  /// Creates a URL-disallowed-scheme error.
  const UrlDisallowedScheme(this.scheme);

  @override
  String get code => 'url.disallowedScheme';
}

/// URL is missing a host address.
final class UrlMissingHost extends UrlError {
  /// Creates a URL-missing-host error.
  const UrlMissingHost();

  @override
  String get code => 'url.missingHost';
}
