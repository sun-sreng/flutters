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
