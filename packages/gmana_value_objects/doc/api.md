# gmana_value_objects API Guide

Import the package:

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';
```

Value objects validate at construction time and expose an `Either` result,
nullable accessors, and a boolean validity check.

```dart
final email = Email('user@example.com');

if (email.isValid) {
  print(email.valueOrNull);
} else {
  print(email.errorOrNull);
}
```

## Core Types

| API                                                | Use it for                                                          |
| -------------------------------------------------- | ------------------------------------------------------------------- |
| `ValueObject<T>`                                   | Base class for typed values backed by `Either<ValidationError, T>`. |
| `value`                                            | Full validation result as `Either<ValidationError, T>`.             |
| `isValid`                                          | Whether validation succeeded.                                       |
| `valueOrNull`                                      | Valid value or `null`.                                              |
| `errorOrNull`                                      | Validation error or `null`.                                         |
| `ValidationError.code`                             | Stable machine-readable error code.                                 |
| `DefaultValidationErrorMessages.getMessage(error)` | Convert known errors to English display messages.                   |
| Re-exported `Either`, `Left`, `Right`              | Compose value-object validation with `gmana` functional APIs.       |

## Email

```dart
final email = Email(
  'user@example.com',
  config: EmailValidationConfig.strict(),
);

final result = EmailValidator(
  EmailValidationConfig(blockedDomains: {'example.org'}),
).validate('user@example.com');
```

| API                                      | Use it for                                                                                               |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `Email(input, config: ...)`              | Create a typed email value object.                                                                       |
| `EmailValidationConfig()`                | Configure required flag, max length, local/domain limits, disposable-domain checks, and blocked domains. |
| `EmailValidationConfig.strict()`         | Use stricter defaults, including disposable-domain rejection.                                            |
| `EmailValidator(config).validate(input)` | Validate an email without constructing `Email` directly.                                                 |
| `EmailEmpty`                             | Input is empty when required.                                                                            |
| `EmailInvalidFormat`                     | Input does not match email format.                                                                       |
| `EmailTooLong`                           | Full email exceeds allowed length.                                                                       |
| `EmailLocalPartTooLong`                  | Local part before `@` is too long.                                                                       |
| `EmailDomainTooLong`                     | Domain part is too long.                                                                                 |
| `EmailDisposableDomain`                  | Domain is disposable under strict config.                                                                |
| `EmailBlockedDomain`                     | Domain appears in the blocked-domain set.                                                                |

## Password

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

## Text

```dart
final username = TextValue(
  'john_doe',
  config: TextValidationConfig.username(),
);

final displayName = TextValue(
  'John',
  config: TextValidationConfig.name(),
);
```

| API                                                              | Use it for                                                                                 |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `TextValue(input, config: ...)`                                  | Create a typed text value object.                                                          |
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

## Number

```dart
final age = NumberValue('25', config: NumberValidationConfig.age());
final quantity = NumberValue.fromNum(
  10,
  config: NumberValidationConfig.positiveInteger(),
);
```

| API                                        | Use it for                                                          |
| ------------------------------------------ | ------------------------------------------------------------------- |
| `NumberValue(input, config: ...)`          | Parse and validate numeric text.                                    |
| `NumberValue.fromNum(value, config: ...)`  | Validate an existing `num`.                                         |
| `NumberValidationConfig()`                 | Configure bounds, integer-only mode, negatives, and decimal places. |
| `NumberValidationConfig.age()`             | Human age preset.                                                   |
| `NumberValidationConfig.price()`           | Price preset.                                                       |
| `NumberValidationConfig.rating()`          | Rating preset.                                                      |
| `NumberValidationConfig.percentage()`      | Percentage preset.                                                  |
| `NumberValidationConfig.positiveInteger()` | Positive integer preset.                                            |
| `NumberValidator(config).validate(input)`  | Validate number text without constructing `NumberValue` directly.   |
| `NumberEmpty`                              | Required number input is empty.                                     |
| `NumberInvalidFormat`                      | Input is not numeric.                                               |
| `NumberTooSmall`, `NumberTooLarge`         | Number is outside min/max bounds.                                   |
| `NumberNotInteger`                         | Integer-only config received a decimal.                             |
| `NumberNegativeNotAllowed`                 | Negative value is disallowed.                                       |
| `NumberNotInRange`                         | Number is outside a named range.                                    |
| `NumberDecimalPlacesExceeded`              | Decimal places exceed config.                                       |

## Displaying Errors

```dart
final messages = DefaultValidationErrorMessages();
final email = Email('bad');

final errorText = email.errorOrNull == null
    ? null
    : messages.getMessage(email.errorOrNull!);
```

For localization, switch on the sealed error hierarchy:

```dart
String localize(ValidationError error) {
  return switch (error) {
    EmailEmpty() => 'Email is required',
    PasswordTooShort(:final minLength) => 'Use at least $minLength characters',
    _ => DefaultValidationErrorMessages().getMessage(error),
  };
}
```
