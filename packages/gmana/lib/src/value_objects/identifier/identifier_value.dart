import '../../../functional.dart';
import 'package:meta/meta.dart';

import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import '../../validation/identifier/identifier_validation_config.dart';
import '../../validation/identifier/identifier_validation_issue.dart';
import '../../validation/identifier/identifier_validator.dart';

/// Immutable domain value object representing a validated identifier.
@immutable
final class IdentifierValue extends ValueObject<String> {
  @override
  final String value;

  const IdentifierValue._(this.value);

  /// Constructs an [IdentifierValue] from a trusted string.
  /// Throws [ValueObjectException] if input is invalid.
  factory IdentifierValue(
    String input, {
    IdentifierValidationConfig config = const IdentifierValidationConfig(),
  }) {
    return tryParse(
      input,
      config: config,
    ).fold((error) => throw ValueObjectException(error), (val) => val);
  }

  /// Attempts to parse [input] into an [IdentifierValue].
  /// Returns `Either<IdentifierValidationIssue, IdentifierValue>`.
  static Either<IdentifierValidationIssue, IdentifierValue> tryParse(
    String input, {
    IdentifierValidationConfig config = const IdentifierValidationConfig(),
  }) {
    return IdentifierValidator(config).validate(input).map(IdentifierValue._);
  }
}
