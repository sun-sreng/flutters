/// Configuration rules for URL validation.
final class UrlValidationConfig {
  /// Allowed schemes (e.g. `http`, `https`, `ftp`). Defaults to `{'http', 'https'}`.
  final Set<String> allowedSchemes;

  /// Whether to require a top-level domain or valid host name.
  final bool requireHost;

  /// Creates a URL validation config.
  const UrlValidationConfig({
    this.allowedSchemes = const {'http', 'https'},
    this.requireHost = true,
  });
}
