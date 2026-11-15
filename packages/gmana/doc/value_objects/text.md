# Text

```dart
// Untrusted input → Either<TextValidationIssue, TextValue>.
final username = TextValue.tryParse(
  'john_doe',
  config: TextValidationConfig.username(),
);

// Trusted literal → throws ValueObjectException if invalid.
final displayName = TextValue('John', config: TextValidationConfig.name());
```

| API                                                              | Use it for                                                                                 |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `TextValue.tryParse(input, config: ...)`                         | Validate untrusted input, returning `Either<TextValidationIssue, TextValue>`.                        |
| `TextValue(input, config: ...)`                                  | Create a typed text value from a trusted literal; throws if invalid.                       |
| `TextValidationConfig()`                                         | Configure required flag, trimming, length, pattern, allowed characters, and blocked words. |
| `TextValidationConfig.username()`                                | Username-oriented preset.                                                                  |
| `TextValidationConfig.name()`                                    | Human-name preset.                                                                         |
| `TextValidationConfig.shortText()`, `mediumText()`, `longText()` | Text-length presets.                                                                       |
| `TextValidator(config).validate(input)`                          | Validate text without constructing `TextValue` directly.                                   |
| `TextEmptyIssue`                                                      | Required text is empty.                                                                    |
| `TextOnlyWhitespaceIssue`                                             | Whitespace-only text is not allowed.                                                       |
| `TextTooShortIssue`, `TextTooLongIssue`                                    | Text length is outside configured bounds.                                                  |
| `TextInvalidPatternIssue`                                             | Text does not match the configured pattern.                                                |
| `TextInvalidCharactersIssue`                                          | Text contains characters outside the allowed set.                                          |
| `TextContainsBlacklistedIssue`                                        | Text contains a blocked word.                                                              |
