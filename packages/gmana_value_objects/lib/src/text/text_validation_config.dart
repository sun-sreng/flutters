import 'package:meta/meta.dart';

import '../core/collection_equality.dart';

/// Configuration rules for valid text strings.
///
/// Provides constraints such as length limit, regular expression patterns,
/// and blacklisted words.
@immutable
final class TextValidationConfig {
  /// Optional minimum allowable length.
  final int? minLength;

  /// Optional maximum allowable length.
  final int? maxLength;

  /// Whether empty text (or whitespace-only if not trimmed) is permitted.
  final bool allowEmpty;

  /// Whether text consisting solely of whitespace characters is permitted.
  final bool allowOnlyWhitespace;

  /// Whether the text should be trimmed (removing leading/trailing whitespace).
  final bool trimWhitespace;

  /// A regular expression pattern that the text must match.
  final String? pattern;

  /// A set of words that are not permitted to appear in the text.
  final Set<String> blacklistedWords;

  /// Additional specification of characters that are allowed, often paired with `pattern`.
  final String? allowedCharacters;

  /// Creates a new [TextValidationConfig] with customizable rules.
  ///
  /// By default, trims whitespace and does not allow empty text.
  const TextValidationConfig({
    this.minLength,
    this.maxLength,
    this.allowEmpty = false,
    this.allowOnlyWhitespace = false,
    this.trimWhitespace = true,
    this.pattern,
    this.blacklistedWords = const {},
    this.allowedCharacters,
  });

  /// Username validation
  factory TextValidationConfig.username() {
    return const TextValidationConfig(
      minLength: 3,
      maxLength: 20,
      pattern: r'^[a-zA-Z0-9_-]+$',
      trimWhitespace: true,
    );
  }

  /// Name validation (first name, last name)
  factory TextValidationConfig.name() {
    return const TextValidationConfig(
      minLength: 1,
      maxLength: 50,
      pattern: r"^[a-zA-Z\s'-]+$",
      trimWhitespace: true,
    );
  }

  /// Short text (titles, labels)
  factory TextValidationConfig.shortText() {
    return const TextValidationConfig(
      minLength: 1,
      maxLength: 100,
      trimWhitespace: true,
    );
  }

  /// Medium text (descriptions, comments)
  factory TextValidationConfig.mediumText() {
    return const TextValidationConfig(
      minLength: 1,
      maxLength: 500,
      trimWhitespace: true,
    );
  }

  /// Long text (articles, posts)
  factory TextValidationConfig.longText() {
    return const TextValidationConfig(
      minLength: 1,
      maxLength: 5000,
      trimWhitespace: true,
    );
  }

  /// Alphanumeric only
  factory TextValidationConfig.alphanumeric() {
    return const TextValidationConfig(
      pattern: r'^[a-zA-Z0-9]+$',
      trimWhitespace: true,
    );
  }

  /// Returns a copy of this config with the given fields replaced.
  ///
  /// Nullable fields ([minLength], [maxLength], [pattern], [allowedCharacters])
  /// can be cleared by passing `null` explicitly; omitting a parameter keeps the
  /// current value.
  TextValidationConfig copyWith({
    Object? minLength = _unset,
    Object? maxLength = _unset,
    bool? allowEmpty,
    bool? allowOnlyWhitespace,
    bool? trimWhitespace,
    Object? pattern = _unset,
    Set<String>? blacklistedWords,
    Object? allowedCharacters = _unset,
  }) {
    return TextValidationConfig(
      minLength: identical(minLength, _unset) ? this.minLength : minLength as int?,
      maxLength: identical(maxLength, _unset) ? this.maxLength : maxLength as int?,
      allowEmpty: allowEmpty ?? this.allowEmpty,
      allowOnlyWhitespace: allowOnlyWhitespace ?? this.allowOnlyWhitespace,
      trimWhitespace: trimWhitespace ?? this.trimWhitespace,
      pattern: identical(pattern, _unset) ? this.pattern : pattern as String?,
      blacklistedWords: blacklistedWords ?? this.blacklistedWords,
      allowedCharacters: identical(allowedCharacters, _unset)
          ? this.allowedCharacters
          : allowedCharacters as String?,
    );
  }

  static const Object _unset = Object();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextValidationConfig &&
          other.minLength == minLength &&
          other.maxLength == maxLength &&
          other.allowEmpty == allowEmpty &&
          other.allowOnlyWhitespace == allowOnlyWhitespace &&
          other.trimWhitespace == trimWhitespace &&
          other.pattern == pattern &&
          other.allowedCharacters == allowedCharacters &&
          setEquals(other.blacklistedWords, blacklistedWords);

  @override
  int get hashCode => Object.hash(
    minLength,
    maxLength,
    allowEmpty,
    allowOnlyWhitespace,
    trimWhitespace,
    pattern,
    allowedCharacters,
    Object.hashAllUnordered(blacklistedWords),
  );
}
