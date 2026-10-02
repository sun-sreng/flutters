import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../extensions/validation_adapter_extensions.dart';
import 'identifier_errors.dart';
import 'identifier_validation_config.dart';

/// A class responsible for validating string inputs as identifiers.
final class IdentifierValidator {
  /// The configuration rules to apply during validation.
  final IdentifierValidationConfig config;

  /// Creates a new [IdentifierValidator].
  const IdentifierValidator([this.config = const IdentifierValidationConfig()]);

  /// Validates the given [input] string as an identifier.
  Either<IdentifierError, String> validate(String input) {
    return v.IdentifierValidator(config)
        .validate(input)
        .fold((issue) => Left(issue.toIdentifierError()), Right.new);
  }
}
