import '../../../functional.dart';

import '../core/validation_issue.dart';
import 'text_validation_config.dart';
import 'text_validation_issue.dart';

/// Canonical validator for text inputs.
final class TextValidator {
  /// Rules used during validation.
  final TextValidationConfig config;

  final RegExp? _disallowedPattern;

  /// Creates a text validator.
  TextValidator([this.config = const TextValidationConfig()])
    : _disallowedPattern =
          config.allowedCharacters != null
              ? RegExp('[^${RegExp.escape(config.allowedCharacters!)}]')
              : null;

  /// Validates and normalizes [input].
  ValidationResult<TextValidationIssue, String> validate(String input) {
    final value = config.trimWhitespace ? input.trim() : input;

    if (value.isEmpty) {
      return config.allowEmpty ? Right(value) : const Left(TextEmptyIssue());
    }

    // Only reachable when trimWhitespace=false, otherwise empty catch above fires
    if (!config.allowOnlyWhitespace && value.trim().isEmpty) {
      return const Left(TextOnlyWhitespaceIssue());
    }

    final length = value.length;

    if (config.minLength case final min? when length < min) {
      return Left(TextTooShortIssue(currentLength: length, minLength: min));
    }

    if (config.maxLength case final max? when length > max) {
      return Left(TextTooLongIssue(currentLength: length, maxLength: max));
    }

    if (config.pattern case final re? when !re.hasMatch(value)) {
      return const Left(TextInvalidPatternIssue());
    }

    if (_disallowedPattern case final re?) {
      final invalid =
          re.allMatches(value).map((m) => m.group(0)!).toSet().join();
      if (invalid.isNotEmpty) {
        return Left(TextInvalidCharactersIssue(invalid));
      }
    }

    if (config.blacklistedWords.isNotEmpty) {
      final lowered = value.toLowerCase();
      final found =
          config.blacklistedWords.where((word) {
            final w = word.toLowerCase();
            if (!config.wholeWordBlacklist) return lowered.contains(w);
            final idx = lowered.indexOf(w);
            if (idx == -1) return false;
            final before = idx == 0 || !_isWordChar(lowered[idx - 1]);
            final after =
                idx + w.length == lowered.length ||
                !_isWordChar(lowered[idx + w.length]);
            return before && after;
          }).toList();

      if (found.isNotEmpty) return Left(TextContainsBlacklistedIssue(found));
    }

    return Right(value);
  }

  static bool _isWordChar(String char) {
    final c = char.codeUnitAt(0);
    return (c >= 65 && c <= 90) ||
        (c >= 97 && c <= 122) ||
        (c >= 48 && c <= 57) ||
        c == 95;
  }
}
