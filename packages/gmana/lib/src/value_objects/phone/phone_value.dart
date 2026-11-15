import '../../../functional.dart';
import 'package:meta/meta.dart';

import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import '../../validation/phone/phone_validation_config.dart';
import '../../validation/phone/phone_validation_issue.dart';
import '../../validation/phone/phone_validator.dart';

/// Immutable domain value object representing a validated phone number string.
@immutable
final class PhoneValue extends ValueObject<String> {
  @override
  final String value;

  const PhoneValue._(this.value);

  /// Constructs a [PhoneValue] from a trusted input string.
  /// Throws [ValueObjectException] if input is invalid.
  factory PhoneValue(
    String input, [
    PhoneValidationConfig config = const PhoneValidationConfig(),
  ]) {
    return tryParse(
      input,
      config,
    ).fold((error) => throw ValueObjectException(error), (phone) => phone);
  }

  /// Attempts to parse [input] into a [PhoneValue].
  /// Returns `Either<PhoneValidationIssue, PhoneValue>`.
  static Either<PhoneValidationIssue, PhoneValue> tryParse(
    String input, [
    PhoneValidationConfig config = const PhoneValidationConfig(),
  ]) {
    return PhoneValidator(config).validate(input).map(PhoneValue._);
  }
}
