# Displaying Errors

```dart
final messages = DefaultValidationErrorMessages();

final errorText = Email.tryParse('bad').fold(
  (error) => messages.getMessage(error),
  (email) => null,
);
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
