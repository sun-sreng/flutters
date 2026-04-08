# Value Objects Package - Complete Structure

## Package Overview

A production-ready, generic Flutter/Dart package for Email, Password, Text, and Number validation with:

- ✅ Zero coupling to your architecture
- ✅ Fully configurable validation rules
- ✅ Type-safe sealed error hierarchies
- ✅ Framework agnostic (works in backend Dart too)
- ✅ i18n ready
- ✅ Production battle-tested patterns

## File Structure

```text
value_objects/
├── lib/
│   ├── value_objects.dart                                    # Main export
│   ├── src/
│   │   ├── core/
│   │   │   ├── validation_error.dart                         # Base error class
│   │   │   └── value_object.dart                             # Base ValueObject<T>
│   │   ├── email/
│   │   │   ├── email.dart                                    # Email VO
│   │   │   ├── email_errors.dart                             # Sealed error types
│   │   │   ├── email_validation_config.dart                  # Config with presets
│   │   │   └── email_validator.dart                          # Pure validator
│   │   ├── password/
│   │   │   ├── password.dart                                 # Password VO
│   │   │   ├── password_errors.dart                          # Sealed error types
│   │   │   ├── password_validation_config.dart               # Config with presets
│   │   │   └── password_validator.dart                       # Pure validator
│   │   ├── text/
│   │   │   ├── text_value.dart                               # Text VO
│   │   │   ├── text_errors.dart                              # Sealed error types
│   │   │   ├── text_validation_config.dart                   # Config with presets
│   │   │   └── text_validator.dart                           # Pure validator
│   │   ├── number/
│   │   │   ├── number_value.dart                             # Number VO
│   │   │   ├── number_errors.dart                            # Sealed error types
│   │   │   ├── number_validation_config.dart                 # Config with presets
│   │   │   └── number_validator.dart                         # Pure validator
│   │   └── presentation/
│   │       └── validation_error_messages.dart                # Default English messages
├── example/
│   └── lib/
│       ├── main.dart                                          # Basic example
│       └── riverpod_example.dart                              # Riverpod integration
├── pubspec.yaml
├── README.md
└── CHANGELOG.md
```

## Usage Patterns

### 1. Direct Usage (No Wrapper)

```dart
final email = Email('user@example.com');
if (email.isValid) {
  print(email.valueOrNull);
}
```

### 2. Wrapped in Your Architecture

```dart
// Your domain layer
final class Email extends ValueObject<String> {
  factory Email(String input) {
    final result = vo.Email(input);
    return Email._(
      result.value.leftMap((error) => ValidationFailure(error)),
    );
  }
}
```

### 3. With Custom Config

```dart
final email = Email(
  'user@example.com',
  config: EmailValidationConfig(
    blockedDomains: {'competitor.com'},
    allowDisposable: false,
  ),
);
```

### 4. With Flutter Localization

```dart
extension ValidationErrorL10n on ValidationError {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      EmailEmpty() => l10n.errorEmailEmpty,
      PasswordTooShort(:final minLength) => l10n.errorPasswordTooShort(minLength),
      // ...
    };
  }
}
```

## Key Features by Type

### Email

- RFC 5322 compliant
- Disposable domain detection
- Custom blocked domains
- Length limits (total, local part, domain)

### Password

- Min/max length
- Complexity scoring (4 character classes)
- Common password detection
- Sequential pattern detection
- Presets: lenient(), strict()

### Text

- Min/max length
- Pattern matching (regex)
- Blacklisted words
- Allowed characters
- Whitespace handling
- Presets: username(), name(), shortText(), mediumText(), longText(), alphanumeric()

### Number

- Min/max range
- Integer enforcement
- Negative control
- Decimal places limit
- Presets: positiveInteger(), naturalNumber(), percentage(), price(), age(), rating()

## Integration Examples

### With Riverpod

```dart
@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default(null) Email? email,
    @Default(null) Password? password,
  }) = _SignUpState;
}

extension SignUpStateX on SignUpState {
  bool get canSubmit => email?.isValid == true && password?.isValid == true;
}
```

### With FormField

```dart
TextFormField(
  decoration: InputDecoration(
    errorText: email?.errorOrNull?.let((error) {
      return messages.getMessage(error);
    }),
  ),
)
```

## Testing

All validators are pure functions - easy to test:

```dart
test('rejects invalid email', () {
  final email = Email('not-an-email');
  expect(email.isInvalid, true);
  expect(email.errorOrNull, isA<EmailInvalidFormat>());
});
```

## Why This Solves Your Problem

1. **Generic & Reusable** - Works in any Flutter project
2. **No Coupling** - Core package has no Flutter dependencies
3. **Type Safe** - Sealed classes + pattern matching
4. **Configurable** - Every rule can be customized
5. **Production Ready** - Real patterns from real apps
6. **Clean Architecture** - Domain separated from presentation
7. **Testable** - Pure validators with no side effects

## Publishing

To publish this package:

```bash
cd value_objects_package
dart pub publish --dry-run
dart pub publish
```

## Migration from Your Current Code

Before:

```dart
// Domain layer coupled to l10n
extension PasswordErrorL10n on PasswordError {
  String localize(AppLocalizations l10n) { ... }
}
```

After:

```dart
// Package: domain layer (no l10n dependency)
final class Password extends ValueObject<String> { ... }

// Your app: presentation layer (has l10n)
extension ValidationErrorL10n on ValidationError {
  String localize(AppLocalizations l10n) { ... }
}
```
