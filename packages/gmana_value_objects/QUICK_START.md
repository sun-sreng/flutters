# gmana_value_objects — Quick Start

## Install

```yaml
dependencies:
  gmana_value_objects: ^0.1.0
```

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';
```

## The core idea: always valid

A value object is **always valid**. If you hold an `Email`, it has already
passed validation — there is no invalid state to check for. Construct values one
of two ways:

- `T.tryParse(input)` → `Either<Error, T>` for untrusted input (forms, APIs).
- `T(input)` → builds from a trusted literal; throws `ValueObjectException` if
  invalid.

```dart
// Untrusted input.
Email.tryParse('user@example.com').fold(
  (error) => print('Invalid: ${error.code}'),
  (email) => print(email.value), // user@example.com
);

// Trusted literal.
final email = Email('user@example.com');
print(email.value); // user@example.com
```

## Each type

```dart
// Email — trimmed and lowercased on success.
Email.tryParse('USER@Example.com');

// Password — value is masked in toString(); isSensitive is true.
Password.tryParse('StrongP@ssw0rd!', config: PasswordValidationConfig.strict());

// Text — supports trimming, length, pattern, allowed chars, blocked words.
TextValue.tryParse('john_doe', config: TextValidationConfig.username());

// Number — finite num with bounds, integer-only, decimal-place limits.
NumberValue.tryParse('25', config: NumberValidationConfig.age());
NumberValue.tryParseNum(10, config: NumberValidationConfig.positiveInteger());

// Money — exact integer minor units + Currency. Validate untrusted text:
MoneyValidator(MoneyValidationConfig.usd()).validate('19.99', currency: 'USD');
// ...or build trusted amounts directly:
final price = Money.fromDecimalString('19.99', Currency.usd);
```

## Validators without value objects

Every type ships a pure validator returning `Either<Error, primitive>`:

```dart
const EmailValidator().validate('user@example.com'); // Either<EmailError, String>
```

## Displaying errors

```dart
const messages = DefaultValidationErrorMessages();

Email.tryParse('bad').fold(
  (error) => print(messages.getMessage(error)), // Invalid email format
  (email) => print(email.value),
);
```

For localization, switch on the sealed error hierarchy directly:

```dart
String localize(ValidationError error) => switch (error) {
  EmailEmpty() => 'Email is required',
  PasswordTooShort(:final minLength) => 'Use at least $minLength characters',
  _ => const DefaultValidationErrorMessages().getMessage(error),
};
```

## Composing with your own failure type

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart' as vo;

vo.Either<MyFailure, vo.Email> parseEmail(String input) {
  return vo.Email.tryParse(input).mapLeft(MyFailure.validation);
}
```

See [README.md](README.md) and the [doc/](doc) folder for the full API.
