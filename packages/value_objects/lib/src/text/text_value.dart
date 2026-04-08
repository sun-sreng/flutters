import 'package:fpdart/fpdart.dart';
import '../core/value_object.dart';
import 'text_errors.dart';
import 'text_validation_config.dart';
import 'text_validator.dart';

final class TextValue extends ValueObject<String> {
  @override
  final Either<TextError, String> value;

  factory TextValue(String input, {TextValidationConfig config = const TextValidationConfig()}) {
    final validator = TextValidator(config);
    return TextValue._(validator.validate(input));
  }

  factory TextValue.validated(Either<TextError, String> validated) {
    return TextValue._(validated);
  }

  const TextValue._(this.value);

  @override
  String toString() => 'TextValue(${valueOrNull ?? 'invalid'})';
}
