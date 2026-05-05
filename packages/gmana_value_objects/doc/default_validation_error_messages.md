# Displaying Errors

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
