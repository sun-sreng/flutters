import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../extensions/validation_adapter_extensions.dart';
import 'text_errors.dart';
import 'text_validation_config.dart';

/// A class responsible for validating generic text inputs according to a [TextValidationConfig].
final class TextValidator {
  /// The configuration rules to apply during validation.
  final TextValidationConfig config;

  /// Creates a new [TextValidator].
  const TextValidator([this.config = const TextValidationConfig()]);

  /// Validates the given [input] string as text according to the [config].
  Either<TextError, String> validate(String input) {
    final vConfig = v.TextValidationConfig(
      allowEmpty: config.allowEmpty,
      allowOnlyWhitespace: config.allowOnlyWhitespace,
      trimWhitespace: config.trimWhitespace,
      minLength: config.minLength,
      maxLength: config.maxLength,
      pattern: config.pattern != null ? RegExp(config.pattern!) : null,
      allowedCharacters: config.allowedCharacters,
      blacklistedWords: config.blacklistedWords,
      wholeWordBlacklist: config.wholeWordBlacklist,
    );

    return v.TextValidator(vConfig)
        .validate(input)
        .fold(
          (issue) => Left(
            issue is v.TextInvalidPatternIssue
                ? TextInvalidPattern(config.pattern ?? '')
                : issue.toTextError(),
          ),
          Right.new,
        );
  }
}
