import 'package:gmana/gmana.dart' show Either;
import '../core/value_object.dart';
import 'text_errors.dart';
import 'text_validation_config.dart';
import 'text_validator.dart';

/// A value object representing a validated text string.
///
/// Holds either a [TextError] if validation fails, or the raw [String] if it succeeds.
final class TextValue extends ValueObject<String> {
  /// The underlying value, which is either a [TextError] or a valid [String].
  @override
  final Either<TextError, String> value;

  /// Creates a new [TextValue] instance by validating the given [input].
  ///
  /// An optional [config] can be provided to customize the validation constraints.
  factory TextValue(
    String input, {
    TextValidationConfig config = const TextValidationConfig(),
  }) {
    final validator = TextValidator(config);
    return TextValue._(validator.validate(input));
  }

  /// Creates a new [TextValue] instance directly from a validated [Either].
  factory TextValue.validated(Either<TextError, String> validated) {
    return TextValue._(validated);
  }

  /// Internal constructor for [TextValue].
  const TextValue._(this.value);

  /// Returns a string representation of the [TextValue].
  @override
  String toString() => 'TextValue(${valueOrNull ?? 'invalid'})';
}
