import 'package:gmana_functional/gmana_functional.dart';

import 'url_errors.dart';
import 'url_validation_config.dart';

/// Validator for URL strings returning [Either<UrlError, Uri>].
final class UrlValidator {
  /// Rules used during validation.
  final UrlValidationConfig config;

  /// Creates a URL validator.
  const UrlValidator([this.config = const UrlValidationConfig()]);

  /// Validates [input] and returns parsed [Uri] on success.
  Either<UrlError, Uri> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) return const Left(UrlEmpty());

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      return const Left(UrlInvalidFormat());
    }

    final scheme = uri.scheme.toLowerCase();
    if (config.allowedSchemes.isNotEmpty &&
        !config.allowedSchemes.contains(scheme)) {
      return Left(UrlDisallowedScheme(scheme));
    }

    if (config.requireHost && uri.host.isEmpty) {
      return const Left(UrlMissingHost());
    }

    return Right(uri);
  }
}
