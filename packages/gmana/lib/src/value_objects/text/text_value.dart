import '../../../functional.dart';
import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import '../../validation/text/text_validation_config.dart';
import '../../validation/text/text_validation_issue.dart';
import '../../validation/text/text_validator.dart';

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

  /// Rules used when no config is passed: required, trimmed, and not
  /// whitespace-only, with blacklisted words matched anywhere in the text.
  static const TextValidationConfig defaultConfig = TextValidationConfig(
    allowEmpty: false,
    allowOnlyWhitespace: false,
    trimWhitespace: true,
    wholeWordBlacklist: false,
  );

  /// Validates [input], throwing [ValueObjectException] when it is invalid.
  ///
  /// Prefer [tryParse] for user input.
  factory TextValue(
    String input, {
    TextValidationConfig config = TextValue.defaultConfig,
  }) {
    return tryParse(
      input,
      config: config,
    ).getOrElse((error) => throw ValueObjectException(error));
  }

  /// Validates [input] and returns the [TextValue] or a [TextValidationIssue].
  static Either<TextValidationIssue, TextValue> tryParse(
    String input, {
    TextValidationConfig config = TextValue.defaultConfig,
  }) {
    return TextValidator(config).validate(input).map(TextValue._);
  }
}
