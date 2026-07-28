import 'package:gmana_functional/gmana_functional.dart';

import '../core/validation_issue.dart';
import 'url_validation_config.dart';
import 'url_validation_issue.dart';

/// Validates and parses URL strings into [Uri].
final class UrlValidator {
  /// Rules used during validation.
  final UrlValidationConfig config;

  /// Creates a URL validator.
  const UrlValidator([this.config = const UrlValidationConfig()]);

  /// Validates [input] and returns parsed [Uri] on success.
  ValidationResult<UrlValidationIssue, Uri> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) return const Left(UrlEmptyIssue());

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      return const Left(UrlInvalidFormatIssue());
    }

    final scheme = uri.scheme.toLowerCase();
    if (config.allowedSchemes.isNotEmpty &&
        !config.allowedSchemes.contains(scheme)) {
      return Left(UrlDisallowedSchemeIssue(scheme));
    }

    if (config.requireHost && uri.host.isEmpty) {
      return const Left(UrlMissingHostIssue());
    }

    return Right(uri);
  }
}
