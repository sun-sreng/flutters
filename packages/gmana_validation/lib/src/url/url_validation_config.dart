import 'package:meta/meta.dart';

import '../core/set_equality.dart';

/// Configuration rules for URL validation.
@immutable
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

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Omitted fields retain their current values.
  UrlValidationConfig copyWith({
    Set<String>? allowedSchemes,
    bool? requireHost,
  }) {
    return UrlValidationConfig(
      allowedSchemes: allowedSchemes ?? this.allowedSchemes,
      requireHost: requireHost ?? this.requireHost,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlValidationConfig &&
          other.requireHost == requireHost &&
          setEquals(other.allowedSchemes, allowedSchemes);

  @override
  int get hashCode =>
      Object.hash(requireHost, Object.hashAllUnordered(allowedSchemes));
}
