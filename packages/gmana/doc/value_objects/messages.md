# Displaying Issues

```dart
final errorText = Email.tryParse('bad').fold(
  resolveValidationIssue, // Invalid email format
  (email) => null,
);

// Or, with the validation result helpers:
final sameText = Email.tryParse('bad').messageOrNull();
```

For localization, switch on the sealed issue hierarchy:

```dart
String localize(ValidationIssue issue) {
  return switch (issue) {
    EmailEmptyIssue() => 'Email is required',
    EmailInvalidFormatIssue() => 'Enter a valid email',
    PasswordTooShortIssue(:final minLength) =>
      'Use at least $minLength characters',
    _ => resolveValidationIssue(issue),
  };
}
```
