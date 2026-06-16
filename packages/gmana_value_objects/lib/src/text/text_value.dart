import 'package:gmana_functional/gmana_functional.dart';
import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import 'text_errors.dart';
import 'text_validation_config.dart';
import 'text_validator.dart';

/// A value object representing a validated text string.
///
/// A [TextValue] is always valid: its [value] has passed the configured
/// [TextValidationConfig] (and is trimmed when the config requests it). Use
/// [TextValue.tryParse] for untrusted input and the [TextValue] constructor for
/// trusted literals.
final class TextValue extends ValueObject<String> {
  /// The validated text.
  @override
  final String value;

  const TextValue._(this.value);

  /// Validates [input], throwing [ValueObjectException] when it is invalid.
  ///
  /// Prefer [tryParse] for user input.
  factory TextValue(
    String input, {
    TextValidationConfig config = const TextValidationConfig(),
  }) {
    return tryParse(
      input,
      config: config,
    ).getOrElse((error) => throw ValueObjectException(error));
  }

  /// Validates [input] and returns the [TextValue] or a [TextError].
  static Either<TextError, TextValue> tryParse(
    String input, {
    TextValidationConfig config = const TextValidationConfig(),
  }) {
    return TextValidator(config).validate(input).map(TextValue._);
  }
}
