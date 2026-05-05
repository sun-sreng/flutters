# gmana_value_objects

<p align="center">
  Production-ready domain value objects with configurable validation for Email, Password, Text, Number, and Money types, built on gmana.
</p>

---

> **Note:** This package is **pure Dart** and perfectly framework independent. You can run these validation objects in your CLI APIs, dart servers, or native Flutter applications.
> Use `gmana` for low-level rules and field validators; use `gmana_value_objects` when you want typed domain validation and rich error models.

For a complete API guide with examples for every value object, validator, and
error type, see [doc/api.md](doc/api.md).
For ecommerce money modeling details, see [doc/money.md](doc/money.md).

## 🚀 Installation

Add `gmana_value_objects` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  gmana_value_objects: ^0.0.4 # Please check pub.dev for the latest version
```

Or install it via CLI:

```bash
dart pub add gmana_value_objects
```

---

## 🎨 Features Overview

- ✅ **Type-safe validation:** Extensively uses sealed error hierarchies allowing easy pattern-matching via `switch`.
- ✅ **Configurable Ensembles:** Custom `ValidationConfig`s adapt identically required constraints directly (Strictness rules, pattern-overrides).
- ✅ **Domain Separated:** Prevents 'string-ly typed' architectures by securely validating input the moment it enters the application domain.
- ✅ **i18n ready:** Localize error results via simple switch maps over the `ValidationError` base classes.

---

## 🧩 Usage Models

### Formulating Emails

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';

// Basic Usage
final email = Email('user@example.com');

if (email.isValid) {
  print('Email is safe: ${email.valueOrNull}');
} else {
  print('Rejection Trigger: ${email.errorOrNull}');
}

// Configurable constraints: Automatically block temporary mail structures
final strictEmail = Email(
  'user@tempmail.com',
  config: EmailValidationConfig.strict(),
);
```

### Guarding Passwords

Never roll your own password complexity algorithms! Pre-tested templates assure compliance.

```dart
// Enforce standard enterprise leniency or strictness
final lenientPassword = Password('test', config: PasswordValidationConfig.lenient());
final strictPassword = Password('MyP@ssw0rd!2024', config: PasswordValidationConfig.strict());

// Custom Security Needs
final customPassword = Password(
  'mypassword',
  config: PasswordValidationConfig(
    minLength: 12,
    minComplexityScore: 3,
    commonPasswords: {'mypassword', 'companyname123'},
  ),
);
```

### Contextual Text Parsing

Easily guard text models against dangerous payloads using standard presets or bespoke configurations.

```dart
final username = TextValue('john_doe', config: TextValidationConfig.username());
final firstName = TextValue('John', config: TextValidationConfig.name());
final description = TextValue('A longer description...', config: TextValidationConfig.mediumText());

// Custom Text validation regex and filtering
final filteredText = TextValue(
  'Hello World',
  config: TextValidationConfig(
    minLength: 5,
    maxLength: 50,
    pattern: r'^[a-zA-Z\s]+$',
    blacklistedWords: {'spam', 'banned'},
    trimWhitespace: true,
  ),
);
```

### Controlling Numbers

Preventing negative integers magically without `double.tryParse` headaches.

```dart
final age = NumberValue('25', config: NumberValidationConfig.age());
final price = NumberValue('19.99', config: NumberValidationConfig.price());
final rating = NumberValue('4', config: NumberValidationConfig.rating());
final percentage = NumberValue('85.5', config: NumberValidationConfig.percentage());

// Create securely directly from num instead of parsing strings!
final quantity = NumberValue.fromNum(10, config: NumberValidationConfig.positiveInteger());
```

### Modeling Money

Represent prices and balances with a currency-aware value object backed by exact minor units.

```dart
final usd = Money.fromDecimalString('19.99', Currency.usd);
final khr = Money.fromDecimalString('1200', Currency.khr);
const exact = Money(minorUnits: 1234, currency: Currency.usd); // USD 12.34

print(usd.minorUnits); // 1999
print(usd.currency.code); // USD

// Ecommerce-safe line totals and discounts use exact minor units.
final unitPrice = Money.fromDecimalString('19.99', Currency.usd);
final shipping = Money.fromDecimalString('5.00', Currency.usd);
final total = unitPrice * 2 + shipping;
final discounted = total.applyDiscountPercent(10);

print(discounted.formatted); // $40.48
```

---

## 🎯 Clean Architecture Workflows

### Native Flutter Forms

Take advantage of the natively-bundled `DefaultValidationErrorMessages` for super-fast prototypes!

```dart
import 'package:flutter/material.dart';
import 'package:gmana_value_objects/gmana_value_objects.dart';

class _SignUpFormState extends State<SignUpForm> {
  Email? _email;
  final _messages = DefaultValidationErrorMessages();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _email?.errorOrNull != null
          ? _messages.getMessage(_email!.errorOrNull!)
          : null,
      ),
      onChanged: (val) => setState(() => _email = Email(val)),
    );
  }
}
```

### Tying cleanly to state providers (Riverpod etc.)

Your provider logic should never leak Domain validation details to Presentation. Ensure the entire state holds safe values!

```dart
class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(const SignUpState());

  void onEmailChanged(String value) {
    state = state.copyWith(email: Email(value));
  }

  Future<void> submit() async {
    // Prevent interaction explicitly
    if (state.email?.isValid != true) return;

    // We securely unwrap valueOrNull securely knowing it is completely filtered.
    await _authService.signUp(
      email: state.email!.valueOrNull!,
    );
  }
}
```

### I18N (Localizing your validation exceptions)

Translating validation is extremely intuitive effectively leaning on Dart 3 pattern matching!

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gmana_value_objects/gmana_value_objects.dart';

extension ValidationErrorL10n on ValidationError {
  String localize(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (this) {
      EmailEmpty() => l10n.errorEmailEmpty,
      EmailInvalidFormat() => l10n.errorEmailInvalid,
      PasswordTooShort(:final minLength) => l10n.errorPasswordTooShort(minLength),

      // Fallback
      _ => DefaultValidationErrorMessages().getMessage(this),
    };
  }
}
```

---

## ⛓ Mapping to your Core Architectures (`gmana`)

`gmana_value_objects` uses `gmana`'s `Either<ValidationError, T>` under the hood and re-exports `Either`, `Left`, and `Right`, so the value-object API stays aligned with the rest of the `gmana` package family.

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart' as vo;

sealed class Failure {}
final class ValidationFailure extends Failure {
  final vo.ValidationError error;
  ValidationFailure(this.error);
}

final class AppEmail {
  final vo.Either<Failure, String> value;

  factory AppEmail(String input) {
    return AppEmail._(
      // Safely swap value-object errors for native Domain Failure variants
      vo.Email(input).value.mapLeft((error) => ValidationFailure(error)),
    );
  }

  const AppEmail._(this.value);
}
```
