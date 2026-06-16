# gmana_value_objects API Guide

Import the package:

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';
```

Value objects are **always valid**. Validation happens at construction, and a
constructed value object always holds a valid value — there is no invalid state
to guard against.

```dart
// Untrusted input → Either<EmailError, Email>.
Email.tryParse('user@example.com').fold(
  (error) => print(error.code),
  (email) => print(email.value),
);

// Trusted literal → throws ValueObjectException if invalid.
final email = Email('user@example.com');
print(email.value);
```

## Core Types

| API                                                | Use it for                                                                   |
| -------------------------------------------------- | ---------------------------------------------------------------------------- |
| `ValueObject<T>`                                   | Base class for single-value typed values with structural equality.           |
| `T.tryParse(input)`                                | Validate untrusted input, returning `Either<Error, T>`.                      |
| `T(input)`                                         | Build from a trusted literal; throws `ValueObjectException` if invalid.      |
| `value`                                            | The validated underlying value of type `T`.                                  |
| `isSensitive`                                      | `true` for sensitive values (for example `Password`), which mask `toString`. |
| `==` / `hashCode`                                  | Structural equality by concrete type and `value`.                            |
| `ValueObjectException`                             | Thrown by throwing constructors; wraps the `ValidationError`.                |
| `ValidationError.code`                             | Stable machine-readable error code.                                          |
| `DefaultValidationErrorMessages.getMessage(error)` | Convert known errors to English display messages.                            |
| Re-exported `Either`, `Left`, `Right`              | Compose value-object validation with `gmana_functional` APIs.                |

## Choosing a constructor

- Use `tryParse` for any value that comes from outside your code — form fields,
  query parameters, API responses, files. You get the error back as a value and
  decide how to handle it.
- Use the throwing constructor for literals you control, where an invalid value
  is a bug, not a user error.

`Money` is a composite value object (amount + currency). It exposes throwing
constructors for trusted amounts (`Money(...)`, `Money.ofMajor(...)`,
`Money.fromDecimalString(...)`) and a `MoneyValidator` that returns
`Either<MoneyError, Money>` for untrusted input.
