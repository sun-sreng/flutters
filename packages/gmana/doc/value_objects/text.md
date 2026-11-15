# Text

```dart
// Untrusted input → Either<TextError, TextValue>.
final username = TextValue.tryParse(
  'john_doe',
  config: TextValidationConfig.username(),
);

// Trusted literal → throws ValueObjectException if invalid.
final displayName = TextValue('John', config: TextValidationConfig.name());
```

| API                                                              | Use it for                                                                                 |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `TextValue.tryParse(input, config: ...)`                         | Validate untrusted input, returning `Either<TextError, TextValue>`.                        |
| `TextValue(input, config: ...)`                                  | Create a typed text value from a trusted literal; throws if invalid.                       |
| `TextValidationConfig()`                                         | Configure required flag, trimming, length, pattern, allowed characters, and blocked words. |
| `TextValidationConfig.username()`                                | Username-oriented preset.                                                                  |
| `TextValidationConfig.name()`                                    | Human-name preset.                                                                         |
| `TextValidationConfig.shortText()`, `mediumText()`, `longText()` | Text-length presets.                                                                       |
| `TextValidator(config).validate(input)`                          | Validate text without constructing `TextValue` directly.                                   |
| `TextEmpty`                                                      | Required text is empty.                                                                    |
| `TextOnlyWhitespace`                                             | Whitespace-only text is not allowed.                                                       |
| `TextTooShort`, `TextTooLong`                                    | Text length is outside configured bounds.                                                  |
| `TextInvalidPattern`                                             | Text does not match the configured pattern.                                                |
| `TextInvalidCharacters`                                          | Text contains characters outside the allowed set.                                          |
| `TextContainsBlacklisted`                                        | Text contains a blocked word.                                                              |
