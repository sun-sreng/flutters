import 'package:meta/meta.dart';

import '../../core/collection_equality.dart';

/// Configuration for text validation.
@immutable
final class TextValidationConfig {
  /// Creates text validation rules.
  const TextValidationConfig({
    this.allowEmpty = true,
    this.allowOnlyWhitespace = true,
    this.trimWhitespace = false,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.allowedCharacters,
    this.blacklistedWords = const {},
    this.wholeWordBlacklist = true,
  }) : assert(
         !(allowEmpty && !allowOnlyWhitespace),
         'allowEmpty=true with allowOnlyWhitespace=false is contradictory',
       );

  /// Whether empty input is accepted.
  final bool allowEmpty;

  /// Whether whitespace-only input is accepted.
  final bool allowOnlyWhitespace;

  /// Whether input is trimmed before validation and returned trimmed.
  final bool trimWhitespace;

  /// Minimum allowed input length after optional trimming.
  final int? minLength;

  /// Maximum allowed input length after optional trimming.
  final int? maxLength;

  /// Optional pattern that the whole value must match.
  final RegExp? pattern;

  /// Allowed characters. Null means all characters are allowed.
  final String? allowedCharacters;

  /// Words that are not allowed in the input.
  final Set<String> blacklistedWords;

  /// Whether blacklisted words must match whole words only.
  final bool wholeWordBlacklist;

  /// Preset for required text fields.
  factory TextValidationConfig.required({
    int? minLength,
    int? maxLength,
    RegExp? pattern,
    String? allowedCharacters,
    Set<String> blacklistedWords = const {},
    bool wholeWordBlacklist = true,
    bool trimWhitespace = true,
  }) {
    return TextValidationConfig(
      allowEmpty: false,
      allowOnlyWhitespace: false,
      trimWhitespace: trimWhitespace,
      minLength: minLength,
      maxLength: maxLength,
      pattern: pattern,
      allowedCharacters: allowedCharacters,
      blacklistedWords: blacklistedWords,
      wholeWordBlacklist: wholeWordBlacklist,
    );
  }

  /// Required username: 3–20 letters, digits, `_` or `-`.
  factory TextValidationConfig.username() => TextValidationConfig.required(
    minLength: 3,
    maxLength: 20,
    pattern: RegExp(r'^[a-zA-Z0-9_-]+$'),
  );

  /// Required personal name: 1–50 letters, spaces, `'` or `-`.
  factory TextValidationConfig.name() => TextValidationConfig.required(
    minLength: 1,
    maxLength: 50,
    pattern: RegExp(r"^[a-zA-Z\s'-]+$"),
  );

  /// Required text of at most 100 characters.
  factory TextValidationConfig.shortText() =>
      TextValidationConfig.required(minLength: 1, maxLength: 100);

  /// Required text of at most 500 characters.
  factory TextValidationConfig.mediumText() =>
      TextValidationConfig.required(minLength: 1, maxLength: 500);

  /// Required text of at most 5000 characters.
  factory TextValidationConfig.longText() =>
      TextValidationConfig.required(minLength: 1, maxLength: 5000);

  /// Required text of ASCII letters and digits only.
  factory TextValidationConfig.alphanumeric() =>
      TextValidationConfig.required(pattern: RegExp(r'^[a-zA-Z0-9]+$'));

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Pass `null` explicitly to clear [minLength], [maxLength], [pattern] or
  /// [allowedCharacters]; omitted fields keep their current values.
  TextValidationConfig copyWith({
    bool? allowEmpty,
    bool? allowOnlyWhitespace,
    bool? trimWhitespace,
    Object? minLength = unsetConfigValue,
    Object? maxLength = unsetConfigValue,
    Object? pattern = unsetConfigValue,
    Object? allowedCharacters = unsetConfigValue,
    Set<String>? blacklistedWords,
    bool? wholeWordBlacklist,
  }) {
    return TextValidationConfig(
      allowEmpty: allowEmpty ?? this.allowEmpty,
      allowOnlyWhitespace: allowOnlyWhitespace ?? this.allowOnlyWhitespace,
      trimWhitespace: trimWhitespace ?? this.trimWhitespace,
      minLength:
          identical(minLength, unsetConfigValue)
              ? this.minLength
              : minLength as int?,
      maxLength:
          identical(maxLength, unsetConfigValue)
              ? this.maxLength
              : maxLength as int?,
      pattern:
          identical(pattern, unsetConfigValue)
              ? this.pattern
              : pattern as RegExp?,
      allowedCharacters:
          identical(allowedCharacters, unsetConfigValue)
              ? this.allowedCharacters
              : allowedCharacters as String?,
      blacklistedWords: blacklistedWords ?? this.blacklistedWords,
      wholeWordBlacklist: wholeWordBlacklist ?? this.wholeWordBlacklist,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextValidationConfig &&
          other.allowEmpty == allowEmpty &&
          other.allowOnlyWhitespace == allowOnlyWhitespace &&
          other.trimWhitespace == trimWhitespace &&
          other.minLength == minLength &&
          other.maxLength == maxLength &&
          other.pattern?.pattern == pattern?.pattern &&
          other.pattern?.isCaseSensitive == pattern?.isCaseSensitive &&
          other.pattern?.isMultiLine == pattern?.isMultiLine &&
          other.pattern?.isUnicode == pattern?.isUnicode &&
          other.pattern?.isDotAll == pattern?.isDotAll &&
          other.allowedCharacters == allowedCharacters &&
          other.wholeWordBlacklist == wholeWordBlacklist &&
          setEquals(other.blacklistedWords, blacklistedWords);

  @override
  int get hashCode => Object.hash(
    allowEmpty,
    allowOnlyWhitespace,
    trimWhitespace,
    minLength,
    maxLength,
    pattern?.pattern,
    allowedCharacters,
    wholeWordBlacklist,
    Object.hashAllUnordered(blacklistedWords),
  );
}
