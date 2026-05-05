# Password

```dart
final password = Password(
  'Str0ng-passphrase!',
  config: PasswordValidationConfig.strict(),
);

final custom = PasswordValidationConfig(
  minLength: 12,
  minComplexityScore: 4,
  commonPasswords: {'company123'},
);
```

| API                                         | Use it for                                                              |
| ------------------------------------------- | ----------------------------------------------------------------------- |
| `Password(input, config: ...)`              | Create a typed password value object.                                   |
| `PasswordValidationConfig()`                | Configure length, ASCII handling, complexity, and predictability rules. |
| `PasswordValidationConfig.lenient()`        | Use relaxed password rules.                                             |
| `PasswordValidationConfig.strict()`         | Use stricter password rules.                                            |
| `PasswordValidator(config).validate(input)` | Validate a password without constructing `Password` directly.           |
| `PasswordEmpty`                             | Password is empty.                                                      |
| `PasswordTooShort`, `PasswordTooLong`       | Password length is outside configured bounds.                           |
| `PasswordNonAscii`                          | Non-ASCII characters are not allowed by config.                         |
| `PasswordTooCommon`                         | Password appears in configured common-password set.                     |
| `PasswordTooWeak`                           | Password does not reach the configured complexity score.                |
| `PasswordTooPredictable`                    | Password has repeated or sequential patterns.                           |
| `PasswordComplexityRequired`                | A required character class is missing.                                  |
