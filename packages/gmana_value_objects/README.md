# gmana_value_objects

Production-ready domain value objects with configurable validation for Email,
Password, Text, Number, and Money types, built on top of `gmana`.

`gmana_value_objects` is pure Dart and framework independent. Use it in CLI
apps, Dart servers, Flutter apps, or shared domain packages when you want typed
values, `Either`-based validation, and rich error models.

Use `gmana` for low-level rules and field validators. Use
`gmana_value_objects` when input should become a typed domain value before it
moves deeper into your application.

For complete API examples, see [doc/api.md](doc/api.md). For ecommerce money
modeling, see [doc/money.md](doc/money.md).

## Installation

```yaml
dependencies:
  gmana_value_objects: ^0.1.0
```

Or install it from the command line:

```bash
dart pub add gmana_value_objects
```

## Features

- Typed value objects for `Email`, `Password`, `TextValue`, `NumberValue`, and
  `Money`.
- Pure validators for each type when you want `Either<ValidationError, T>`
  without constructing a value object.
- Sealed error hierarchies for exhaustive `switch` handling.
- Stable `ValidationError.code` values for logs, APIs, analytics, and UI keys.
- Configurable validation presets for common application constraints.
- Default English validation messages with a small interface for i18n.
- Currency-aware money stored as exact integer minor units.

## Always valid by construction

Value objects in this package are **always valid**: if you are holding an
`Email`, it has already passed validation. This makes illegal states
unrepresentable — a function that takes an `Email` can never receive an invalid
one. There is no "invalid value object" to guard against.

Construct values one of two ways:

- `T.tryParse(input)` — validates untrusted input and returns
  `Either<Error, T>`. Use this for user input, API payloads, and forms.
- `T(input)` — builds from a trusted literal and **throws**
  `ValueObjectException` if the input is invalid. Use this for hard-coded,
  known-good values.

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';

// Untrusted input → Either<EmailError, Email>.
Email.tryParse('user@example.com').fold(
  (error) => print('Invalid: ${error.code}'),
  (email) => print(email.value), // user@example.com
);

// Trusted literal → throws if invalid.
final email = Email('user@example.com');
print(email.value); // user@example.com
```

Every value object exposes:

| API               | Meaning                                                      |
| ----------------- | ------------------------------------------------------------ |
| `T.tryParse(...)` | Validate untrusted input, returning `Either<Error, T>`.      |
| `T(input)`        | Build from a trusted literal; throws `ValueObjectException`. |
| `value`           | The validated underlying value (always present).             |
| `isSensitive`     | `true` for sensitive objects such as `Password`.             |
| `==` / `hashCode` | Structural equality by concrete type and `value`.            |

## Email

```dart
Email.tryParse('USER@Example.COM').fold(
  (error) => print(error.code),
  (email) => print(email.value), // user@example.com
);

Email.tryParse(
  'user@tempmail.com',
  config: EmailValidationConfig.strict(),
).fold(
  (error) => switch (error) {
    EmailDisposableDomain(:final domain) => print('Disposable domain: $domain'),
    _ => print('Invalid email: ${error.code}'),
  },
  (email) => print('Valid email: ${email.value}'),
);
```

Email validation supports format checks, max lengths, disposable domains, and
custom blocked domains.

## Password

```dart
final password = Password(
  'MyP@ssw0rd!2026',
  config: PasswordValidationConfig.strict(),
);

print(password.isSensitive); // true
print(password.toString()); // Password(***) — value is masked
print(password.value); // MyP@ssw0rd!2026
```

Password validation supports min/max length, ASCII-only rules, common password
checks, predictable sequence checks, and complexity scoring.

## Text

```dart
final username = TextValue(
  'john_doe',
  config: TextValidationConfig.username(),
);

final title = TextValue(
  'Hello World',
  config: TextValidationConfig(
    minLength: 5,
    maxLength: 50,
    pattern: r'^[a-zA-Z\s]+$',
    blacklistedWords: {'spam', 'banned'},
  ),
);
```

Text validation supports trimming, empty/whitespace rules, length bounds,
regular expressions, allowed characters, blacklisted words, and common presets.

## Number

```dart
final age = NumberValue('25', config: NumberValidationConfig.age());
final price = NumberValue('19.99', config: NumberValidationConfig.price());
final quantity = NumberValue.fromNum(
  10,
  config: NumberValidationConfig.positiveInteger(),
);
```

Number validation supports min/max bounds, integer-only mode, negative controls,
decimal-place limits, finite number checks, and presets for age, rating,
percentage, prices, and integer values.

## Money

`Money` stores exact integer minor units with currency metadata, so arithmetic
does not depend on floating-point decimal storage.

```dart
final unitPrice = Money.fromDecimalString('19.99', Currency.usd);
final shipping = Money.fromDecimalString('5.00', Currency.usd);
final total = unitPrice * 2 + shipping;
final discounted = total.applyDiscountPercent(10);

print(unitPrice.minorUnits); // 1999
print(discounted.formatted); // $40.48
```

Money supports:

- exact minor-unit storage, such as cents for USD
- zero, exact minor-unit, major/minor, decimal-string, and numeric constructors
- same-currency arithmetic and comparison
- half-up rounding for multiplication and percentages
- proportional allocation without losing remainders
- deterministic display strings and API decimal strings
- `MoneyValidator` for `Either`-based form and pipeline validation

```dart
final result = MoneyValidator(MoneyValidationConfig.ecommerce())
    .validate('1,234.56', currency: 'USD');

result.fold(
  (error) => print(DefaultValidationErrorMessages().getMessage(error)),
  (amount) => print(amount.formattedWithCode), // USD 1234.56
);
```

## Default Messages

```dart
final messages = DefaultValidationErrorMessages();

Email.tryParse('invalid').fold(
  (error) => print(messages.getMessage(error)), // Invalid email format
  (email) => print(email.value),
);
```

For app-specific localization, switch on `ValidationError` subclasses directly:

```dart
String localize(ValidationError error) {
  return switch (error) {
    EmailEmpty() => 'Email is required',
    EmailInvalidFormat() => 'Enter a valid email',
    PasswordTooShort(:final minLength) =>
      'Use at least $minLength characters',
    _ => DefaultValidationErrorMessages().getMessage(error),
  };
}
```

## Composing With gmana

This package re-exports `Either`, `Left`, and `Right` from `gmana`, so value
object validation can compose with your own domain failures.

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart' as vo;

sealed class Failure {}

final class ValidationFailure extends Failure {
  ValidationFailure(this.error);

  final vo.ValidationError error;
}

final class AppEmail {
  const AppEmail._(this.email);

  final vo.Email email;

  /// Maps the value-object error into your own domain failure type.
  static vo.Either<Failure, AppEmail> tryParse(String input) {
    return vo.Email.tryParse(input).bimap(ValidationFailure.new, AppEmail._);
  }
}
```

## Documentation

- [API guide](doc/api.md)
- [Email](doc/email.md)
- [Password](doc/password.md)
- [Text](doc/text.md)
- [Number](doc/number.md)
- [Money](doc/money.md)
- [Default validation messages](doc/default_validation_error_messages.md)
