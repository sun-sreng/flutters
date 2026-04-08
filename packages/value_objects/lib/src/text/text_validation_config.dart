import 'package:meta/meta.dart';

@immutable
final class TextValidationConfig {
  final int? minLength;
  final int? maxLength;
  final bool allowEmpty;
  final bool allowOnlyWhitespace;
  final bool trimWhitespace;
  final String? pattern;
  final Set<String> blacklistedWords;
  final String? allowedCharacters;
  
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
}
