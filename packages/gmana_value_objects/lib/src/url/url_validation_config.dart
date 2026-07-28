import 'package:meta/meta.dart';

/// Configuration rules for URL validation.
@immutable
final class UrlValidationConfig {
  /// Allowed schemes (e.g. `http`, `https`, `ftp`).
  final Set<String> allowedSchemes;

  /// Whether a host address is required.
  final bool requireHost;

  /// Creates a URL validation config.
  const UrlValidationConfig({
    this.allowedSchemes = const {'http', 'https'},
    this.requireHost = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlValidationConfig &&
          runtimeType == other.runtimeType &&
          requireHost == other.requireHost &&
          _setEquals(allowedSchemes, other.allowedSchemes);

  @override
  int get hashCode => Object.hash(requireHost, Object.hashAll(allowedSchemes));

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
