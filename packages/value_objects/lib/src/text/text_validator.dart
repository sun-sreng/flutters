import 'package:fpdart/fpdart.dart';
import 'text_errors.dart';
import 'text_validation_config.dart';

final class TextValidator {
  final TextValidationConfig config;

  const TextValidator([this.config = const TextValidationConfig()]);

  Either<TextError, String> validate(String input) {
    String value = config.trimWhitespace ? input.trim() : input;

    if (value.isEmpty && !config.allowEmpty) {
      return const Left(TextEmpty());
    }

    if (!config.allowOnlyWhitespace && value.trim().isEmpty && value.isNotEmpty) {
      return const Left(TextOnlyWhitespace());
    }

    if (config.minLength != null && value.length < config.minLength!) {
      return Left(TextTooShort(currentLength: value.length, minLength: config.minLength!));
    }

    if (config.maxLength != null && value.length > config.maxLength!) {
      return Left(TextTooLong(currentLength: value.length, maxLength: config.maxLength!));
    }

    if (config.pattern != null) {
      final regex = RegExp(config.pattern!);
      if (!regex.hasMatch(value)) {
        return Left(TextInvalidPattern(config.pattern!));
      }
    }

    if (config.allowedCharacters != null) {
      final allowedRegex = RegExp('[^${RegExp.escape(config.allowedCharacters!)}]');
      final match = allowedRegex.firstMatch(value);
      if (match != null) {
        final invalidChars = value.split('').where((c) => !config.allowedCharacters!.contains(c)).toSet().join('');
        return Left(TextInvalidCharacters(invalidChars));
      }
    }

    if (config.blacklistedWords.isNotEmpty) {
      final lowered = value.toLowerCase();
      final foundWords = config.blacklistedWords.where((word) => lowered.contains(word.toLowerCase())).toList();

      if (foundWords.isNotEmpty) {
        return Left(TextContainsBlacklisted(foundWords));
      }
    }

    return Right(value);
  }
}
