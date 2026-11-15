# Password

```dart
// Untrusted input → Either<PasswordValidationIssue, Password>.
final result = Password.tryParse(
  'Str0ng-passphrase!',
  config: PasswordValidationConfig.strong(),
);

final custom = PasswordValidationConfig.balanced.copyWith(
  minLength: 12,
  minCharacterClasses: 4,
  commonPasswords: {'company123'},
);
```

| API                                         | Use it for                                                              |
| ------------------------------------------- | ----------------------------------------------------------------------- |
| `Password.tryParse(input, config: ...)`     | Validate untrusted input, returning `Either<PasswordValidationIssue, Password>`. |
| `Password(input, config: ...)`              | Create a typed password from a trusted literal; throws if invalid.      |
| `PasswordValidationConfig.balanced`         | The `Password` default: 3 of 4 character classes, printable ASCII only, scaled sequence check. |
| `PasswordValidationConfig()`                | Require every character class, plus common, repeated, and sequential checks. |
| `PasswordValidationConfig.lenient()`        | Use relaxed password rules.                                             |
| `PasswordValidationConfig.strong()`         | Use stricter password rules.                                            |
| `PasswordValidator(config).validate(input)` | Validate a password without constructing `Password` directly.           |
| `PasswordEmptyIssue`                        | Password is empty.                                                      |
| `PasswordTooShortIssue`, `PasswordTooLongIssue` | Password length is outside configured bounds.                       |
| `PasswordDisallowedCharacterIssue`          | A character is outside `minCodeUnit`..`maxCodeUnit`.                    |
| `PasswordTooCommonIssue`                    | Password appears in the configured common-password set.                 |
| `PasswordTooFewCharacterClassesIssue`       | Fewer than `minCharacterClasses` classes are present.                   |
| `PasswordMissingUppercaseIssue` and the other `Missing*` issues | A required character class is missing (when `minCharacterClasses` is null). |
| `PasswordRepeatedCharacterIssue`, `PasswordSequentialPatternIssue` | Password has repeated or sequential patterns.         |
