# Value Objects

Production-ready value objects with configurable validation for Email, Password, Text, and Number types.

## Features

- ✅ **Type-safe validation** - Sealed error hierarchies with pattern matching
- ✅ **Highly configurable** - Every validation rule can be customized
- ✅ **Framework agnostic** - Core package has no Flutter dependencies
- ✅ **i18n ready** - Bring your own localization
- ✅ **Production tested** - Battle-tested patterns from real apps
- ✅ **Clean Architecture** - Proper separation of domain and presentation

## Installation

```yaml
dependencies:
  value_objects: ^1.0.0
  dartz: ^0.10.1
```

## Quick Start

### Email

```dart
import 'package:value_objects/value_objects.dart';

// Basic usage
final email = Email('user@example.com');
if (email.isValid) {
  print('Email is valid: ${email.valueOrNull}');
} else {
  print('Error: ${email.errorOrNull}');
}

// With custom config
final strictEmail = Email(
  'user@tempmail.com',
  config: EmailValidationConfig.strict(), // Blocks disposable domains
);
```

### Password

```dart
// Basic usage
final password = Password('SecureP@ss123');

// Presets
final lenientPassword = Password(
  'test',
  config: PasswordValidationConfig.lenient(), // min 4 chars, score 1
);

final strictPassword = Password(
  'MyP@ssw0rd!2024',
  config: PasswordValidationConfig.strict(), // min 12 chars, score 4
);

// Custom config
final customPassword = Password(
  'mypassword',
  config: PasswordValidationConfig(
    minLength: 10,
    minComplexityScore: 3,
    commonPasswords: {
      'mypassword',
      'companyname123',
    },
  ),
);
```

### Text

```dart
// Presets for common use cases
final username = TextValue(
  'john_doe',
  config: TextValidationConfig.username(), // 3-20 chars, alphanumeric + _ -
);

final firstName = TextValue(
  'John',
  config: TextValidationConfig.name(), // Letters, spaces, hyphens, apostrophes
);

final title = TextValue(
  'My Article Title',
  config: TextValidationConfig.shortText(), // 1-100 chars
);

final description = TextValue(
  'A longer description...',
  config: TextValidationConfig.mediumText(), // 1-500 chars
);

// Custom validation
final customText = TextValue(
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

### Number

```dart
// Presets
final age = NumberValue(
  '25',
  config: NumberValidationConfig.age(), // 0-150, integer only
);

final price = NumberValue(
  '19.99',
  config: NumberValidationConfig.price(), // Non-negative, 2 decimal places
);

final rating = NumberValue(
  '4',
  config: NumberValidationConfig.rating(), // 1-5, integer
);

final percentage = NumberValue(
  '85.5',
  config: NumberValidationConfig.percentage(), // 0-100
);

// From num type
final quantity = NumberValue.fromNum(
  10,
  config: NumberValidationConfig.positiveInteger(),
);

// Custom validation
final custom = NumberValue(
  '42.5',
  config: NumberValidationConfig(
    min: 0,
    max: 100,
    maxDecimalPlaces: 1,
  ),
);
```

## Flutter Integration

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:value_objects/value_objects.dart';

class SignUpForm extends StatefulWidget {
  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  Email? _email;
  Password? _password;
  
  final _messages = DefaultValidationErrorMessages();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: _email?.errorOrNull?.let((error) {
              return _messages.getMessage(error);
            }),
          ),
          onChanged: (value) {
            setState(() {
              _email = Email(value);
            });
          },
        ),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: _password?.errorOrNull?.let((error) {
              return _messages.getMessage(error);
            }),
          ),
          onChanged: (value) {
            setState(() {
              _password = Password(value);
            });
          },
        ),
      ],
    );
  }
}

extension LetExtension<T> on T? {
  R? let<R>(R Function(T) transform) {
    final value = this;
    return value != null ? transform(value) : null;
  }
}
```

### With Flutter Localization

```dart
// lib/l10n/app_en.arb
{
  "errorEmailEmpty": "Email cannot be empty",
  "errorEmailInvalid": "Invalid email format",
  "errorPasswordTooShort": "Password must be at least {minLength} characters",
  "@errorPasswordTooShort": {
    "placeholders": {
      "minLength": {"type": "int"}
    }
  }
}

// lib/presentation/extensions/validation_error_l10n.dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:value_objects/value_objects.dart';

extension ValidationErrorL10n on ValidationError {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      // Email
      EmailEmpty() => l10n.errorEmailEmpty,
      EmailInvalidFormat() => l10n.errorEmailInvalid,
      
      // Password
      PasswordEmpty() => l10n.errorPasswordEmpty,
      PasswordTooShort(:final minLength) => 
        l10n.errorPasswordTooShort(minLength),
      
      // Add more as needed...
      
      _ => DefaultValidationErrorMessages().getMessage(this),
    };
  }
}

// Usage in widget
TextFormField(
  decoration: InputDecoration(
    errorText: email?.errorOrNull?.localize(context.l10n),
  ),
)
```

### With Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:value_objects/value_objects.dart';

part 'sign_up_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default(null) Email? email,
    @Default(null) Password? password,
    @Default(null) TextValue? username,
    @Default(false) bool isSubmitting,
  }) = _SignUpState;
}

extension SignUpStateX on SignUpState {
  bool get canSubmit => 
    email?.isValid == true &&
    password?.isValid == true &&
    username?.isValid == true;
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier() : super(const SignUpState());
  
  void onEmailChanged(String value) {
    state = state.copyWith(
      email: Email(value),
    );
  }
  
  void onPasswordChanged(String value) {
    state = state.copyWith(
      password: Password(value),
    );
  }
  
  void onUsernameChanged(String value) {
    state = state.copyWith(
      username: TextValue(
        value,
        config: TextValidationConfig.username(),
      ),
    );
  }
  
  Future<void> submit() async {
    if (!state.canSubmit) return;
    
    state = state.copyWith(isSubmitting: true);
    
    try {
      // API call with guaranteed valid values
      await _authService.signUp(
        email: state.email!.valueOrNull!,
        password: state.password!.valueOrNull!,
        username: state.username!.valueOrNull!,
      );
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>(
  (ref) => SignUpNotifier(),
);
```

## Integration with Your Architecture

### Wrapping in Your Own Failure Types

```dart
// Your domain layer
import 'package:dartz/dartz.dart';
import 'package:value_objects/value_objects.dart' as vo;

sealed class Failure {
  const Failure();
}

final class ValidationFailure extends Failure {
  final ValidationError error;
  const ValidationFailure(this.error);
}

abstract class ValueObject<T> {
  Either<Failure, T> get value;
  bool get isSensitive => false;
}

// Your email value object
final class Email extends ValueObject<String> {
  @override
  final Either<Failure, String> value;
  
  factory Email(String input) {
    final result = vo.Email(input);
    return Email._(
      result.value.leftMap((error) => ValidationFailure(error)),
    );
  }
  
  const Email._(this.value);
}

// Your password value object
final class Password extends ValueObject<String> {
  @override
  final Either<Failure, String> value;
  
  factory Password(String input) {
    final result = vo.Password(input);
    return Password._(
      result.value.leftMap((error) => ValidationFailure(error)),
    );
  }
  
  const Password._(this.value);
  
  @override
  bool get isSensitive => true;
}
```

### Environment-Specific Configs

```dart
// lib/core/config/validation_config.dart
import 'package:value_objects/value_objects.dart';

class AppValidationConfig {
  static PasswordValidationConfig get password {
    if (const bool.fromEnvironment('PROD')) {
      return PasswordValidationConfig.strict();
    }
    return PasswordValidationConfig.lenient();
  }
  
  static EmailValidationConfig get email {
    return EmailValidationConfig(
      blockedDomains: {
        'competitor.com',
        'spam-domain.com',
      },
      allowDisposable: !const bool.fromEnvironment('PROD'),
    );
  }
  
  static TextValidationConfig get username {
    return const TextValidationConfig(
      minLength: 3,
      maxLength: 20,
      pattern: r'^[a-zA-Z0-9_]+$',
      blacklistedWords: {
        'admin',
        'root',
        'system',
      },
    );
  }
}

// Usage
final email = Email(
  input,
  config: AppValidationConfig.email,
);
```

## Testing

```dart
import 'package:test/test.dart';
import 'package:value_objects/value_objects.dart';

void main() {
  group('Email', () {
    test('accepts valid email', () {
      final email = Email('user@example.com');
      expect(email.isValid, true);
      expect(email.valueOrNull, 'user@example.com');
    });
    
    test('rejects invalid format', () {
      final email = Email('not-an-email');
      expect(email.isInvalid, true);
      expect(email.errorOrNull, isA<EmailInvalidFormat>());
    });
    
    test('blocks disposable domains when configured', () {
      final email = Email(
        'user@tempmail.com',
        config: EmailValidationConfig.strict(),
      );
      expect(email.isInvalid, true);
      expect(email.errorOrNull, isA<EmailDisposableDomain>());
    });
  });
  
  group('Password', () {
    test('enforces minimum length', () {
      final password = Password('short');
      expect(password.isInvalid, true);
      
      final error = password.errorOrNull as PasswordTooShort;
      expect(error.currentLength, 5);
      expect(error.minLength, 8);
    });
    
    test('enforces complexity', () {
      final password = Password('alllowercase');
      expect(password.isInvalid, true);
      expect(password.errorOrNull, isA<PasswordComplexityRequired>());
    });
    
    test('accepts strong password', () {
      final password = Password('SecureP@ss123');
      expect(password.isValid, true);
    });
  });
}
```

## API Reference

### Core Types

- `ValueObject<T>` - Base class for all value objects
- `ValidationError` - Base class for all errors

### Email

- `Email` - Email value object
- `EmailError` - Sealed error hierarchy
- `EmailValidationConfig` - Configuration options
- `EmailValidator` - Pure validation logic

### Password

- `Password` - Password value object  
- `PasswordError` - Sealed error hierarchy
- `PasswordValidationConfig` - Configuration with presets (lenient/strict)
- `PasswordValidator` - Pure validation logic

### Text

- `TextValue` - Text value object
- `TextError` - Sealed error hierarchy
- `TextValidationConfig` - Configuration with presets (username/name/shortText/mediumText/longText/alphanumeric)
- `TextValidator` - Pure validation logic

### Number

- `NumberValue` - Number value object
- `NumberError` - Sealed error hierarchy
- `NumberValidationConfig` - Configuration with presets (positiveInteger/naturalNumber/percentage/price/age/rating)
- `NumberValidator` - Pure validation logic

### Presentation

- `ValidationErrorMessages` - Interface for error messages
- `DefaultValidationErrorMessages` - Default English implementation

## Why This Package?

1. **Type Safety** - Sealed classes + pattern matching = compile-time safety
2. **Testability** - Pure validators with no side effects
3. **Flexibility** - Every rule is configurable
4. **Production Ready** - Used in real apps with real users
5. **Clean Architecture** - Domain logic separated from presentation
6. **Framework Agnostic** - Works anywhere Dart runs

## License

MIT
