import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../extensions/validation_adapter_extensions.dart';
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
    return v.UrlValidator(
      config,
    ).validate(input).fold((issue) => Left(issue.toUrlError()), Right.new);
  }
}
