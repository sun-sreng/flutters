import '../../../functional.dart';

import '../core/validation_issue.dart';
import 'text_validation_config.dart';
import 'text_validation_issue.dart';

/// Canonical validator for text inputs.
final class TextValidator {
  /// Rules used during validation.
  final TextValidationConfig config;

  /// The allowed characters as Unicode code points, or `null` for any.
  ///
  /// A set rather than a regex character class, so every character in
  /// [TextValidationConfig.allowedCharacters] is literal: `-` is a hyphen,
  /// not a range, and an emoji is one character.
  final Set<int>? _allowedRunes;

  /// Creates a text validator.
  TextValidator([this.config = const TextValidationConfig()])
    : _allowedRunes = config.allowedCharacters?.runes.toSet();

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

    if (_allowedRunes case final allowed?) {
      final invalid = {
        for (final rune in value.runes)
          if (!allowed.contains(rune)) rune,
      };
      if (invalid.isNotEmpty) {
        return Left(TextInvalidCharactersIssue(String.fromCharCodes(invalid)));
      }
    }

    if (config.blacklistedWords.isNotEmpty) {
      final lowered = value.toLowerCase();
      final found =
          config.blacklistedWords.where((word) {
            final w = word.toLowerCase();
            if (!config.wholeWordBlacklist) return lowered.contains(w);
            return _containsWholeWord(lowered, w);
          }).toList();

      if (found.isNotEmpty) return Left(TextContainsBlacklistedIssue(found));
    }

    return Right(value);
  }

  /// Whether [word] occurs in [text] with no word character on either side.
  ///
  /// Every occurrence is checked, so a match inside a longer word (`class`)
  /// does not hide a later whole-word match (`class ass`).
  static bool _containsWholeWord(String text, String word) {
    if (word.isEmpty) return false;
    for (
      var index = text.indexOf(word);
      index != -1;
      index = text.indexOf(word, index + 1)
    ) {
      final end = index + word.length;
      final before = index == 0 || !_isWordChar(text[index - 1]);
      final after = end == text.length || !_isWordChar(text[end]);
      if (before && after) return true;
    }
    return false;
  }

  static bool _isWordChar(String char) {
    final c = char.codeUnitAt(0);
    return (c >= 65 && c <= 90) ||
        (c >= 97 && c <= 122) ||
        (c >= 48 && c <= 57) ||
        c == 95;
  }
}
