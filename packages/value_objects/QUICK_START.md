# Value Objects - Quick Start Guide

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  fpdart: ^1.2.0
  meta: ^1.9.1
```

## Core Files You Need

### 1. Core Base Classes

**lib/src/core/validation_error.dart**

```dart
import 'package:meta/meta.dart';

@immutable
abstract class ValidationError {
  const ValidationError();
}
```

**lib/src/core/value_object.dart**

```dart
import 'package:fpdart/fpdart.dart';
import 'validation_error.dart';

abstract class ValueObject<T> {
  Either<ValidationError, T> get value;

  bool get isValid => value.isRight();
  bool get isInvalid => value.isLeft();

  T? get valueOrNull => value.fold((_) => null, (r) => r);
  ValidationError? get errorOrNull => value.fold((l) => l, (_) => null);

  bool get isSensitive => false;
}
```

### 2. Email Implementation

**lib/src/email/email_errors.dart**

```dart
import '../core/validation_error.dart';

sealed class EmailError extends ValidationError {
  const EmailError();
}

final class EmailEmpty extends EmailError {
  const EmailEmpty();
}

final class EmailInvalidFormat extends EmailError {
  const EmailInvalidFormat();
}

final class EmailTooLong extends EmailError {
  final int currentLength;
  final int maxLength;

  const EmailTooLong({
    required this.currentLength,
    required this.maxLength,
  });
}
```

**lib/src/email/email_validation_config.dart**

```dart
import 'package:meta/meta.dart';

@immutable
final class EmailValidationConfig {
  final int maxLength;
  final Set<String> blockedDomains;

  const EmailValidationConfig({
    this.maxLength = 254,
    this.blockedDomains = const {},
  });
}
```

**lib/src/email/email_validator.dart**

```dart
import 'package:fpdart/fpdart.dart';
import 'email_errors.dart';
import 'email_validation_config.dart';

final class EmailValidator {
  final EmailValidationConfig config;

  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );

  const EmailValidator([
    this.config = const EmailValidationConfig(),
  ]);

  Either<EmailError, String> validate(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Left(EmailEmpty());
    }

    if (trimmed.length > config.maxLength) {
      return Left(EmailTooLong(
        currentLength: trimmed.length,
        maxLength: config.maxLength,
      ));
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return const Left(EmailInvalidFormat());
    }

    return Right(trimmed.toLowerCase());
  }
}
```

**lib/src/email/email.dart**

```dart
import 'package:fpdart/fpdart.dart';
import '../core/value_object.dart';
import 'email_errors.dart';
import 'email_validation_config.dart';
import 'email_validator.dart';

final class Email extends ValueObject<String> {
  @override
  final Either<EmailError, String> value;

  factory Email(
    String input, {
    EmailValidationConfig config = const EmailValidationConfig(),
  }) {
    final validator = EmailValidator(config);
    return Email._(validator.validate(input));
  }

  const Email._(this.value);

  @override
  String toString() => 'Email(${valueOrNull ?? 'invalid'})';
}
```

### 3. Password Implementation

**lib/src/password/password_errors.dart**

```dart
import '../core/validation_error.dart';

sealed class PasswordError extends ValidationError {
  const PasswordError();
}

final class PasswordEmpty extends PasswordError {
  const PasswordEmpty();
}

final class PasswordTooShort extends PasswordError {
  final int currentLength;
  final int minLength;

  const PasswordTooShort({
    required this.currentLength,
    required this.minLength,
  });
}

final class PasswordComplexityRequired extends PasswordError {
  final int currentScore;
  final int requiredScore;

  const PasswordComplexityRequired({
    required this.currentScore,
    required this.requiredScore,
  });
}
```

**lib/src/password/password_validation_config.dart**

```dart
import 'package:meta/meta.dart';

@immutable
final class PasswordValidationConfig {
  final int minLength;
  final int maxLength;
  final int minComplexityScore;

  const PasswordValidationConfig({
    this.minLength = 8,
    this.maxLength = 128,
    this.minComplexityScore = 3,
  });

  factory PasswordValidationConfig.lenient() {
    return const PasswordValidationConfig(
      minLength: 4,
      minComplexityScore: 1,
    );
  }
}
```

**lib/src/password/password_validator.dart**

```dart
import 'package:fpdart/fpdart.dart';
import 'password_errors.dart';
import 'password_validation_config.dart';

final class PasswordValidator {
  final PasswordValidationConfig config;

  const PasswordValidator([
    this.config = const PasswordValidationConfig(),
  ]);

  Either<PasswordError, String> validate(String input) {
    if (input.isEmpty) {
      return const Left(PasswordEmpty());
    }

    if (input.length < config.minLength) {
      return Left(PasswordTooShort(
        currentLength: input.length,
        minLength: config.minLength,
      ));
    }

    final score = _classScore(input);
    if (score < config.minComplexityScore) {
      return Left(PasswordComplexityRequired(
        currentScore: score,
        requiredScore: config.minComplexityScore,
      ));
    }

    return Right(input);
  }

  int _classScore(String s) {
    final hasLower = s.contains(RegExp(r'[a-z]'));
    final hasUpper = s.contains(RegExp(r'[A-Z]'));
    final hasDigit = s.contains(RegExp(r'\d'));
    final hasSymbol = s.contains(RegExp(r'[^A-Za-z0-9]'));

    return (hasLower ? 1 : 0) +
        (hasUpper ? 1 : 0) +
        (hasDigit ? 1 : 0) +
        (hasSymbol ? 1 : 0);
  }
}
```

**lib/src/password/password.dart**

```dart
import 'package:fpdart/fpdart.dart';
import '../core/value_object.dart';
import 'password_errors.dart';
import 'password_validation_config.dart';
import 'password_validator.dart';

final class Password extends ValueObject<String> {
  @override
  final Either<PasswordError, String> value;

  factory Password(
    String input, {
    PasswordValidationConfig config = const PasswordValidationConfig(),
  }) {
    final validator = PasswordValidator(config);
    return Password._(validator.validate(input));
  }

  const Password._(this.value);

  @override
  bool get isSensitive => true;

  @override
  String toString() => 'Password(${isValid ? 'valid' : 'invalid'})';
}
```

### 4. Main Export

**lib/value_objects.dart**

```dart
library value_objects;

export 'src/core/validation_error.dart';
export 'src/core/value_object.dart';
export 'src/email/email.dart';
export 'src/email/email_errors.dart';
export 'src/email/email_validation_config.dart';
export 'src/email/email_validator.dart';
export 'src/password/password.dart';
export 'src/password/password_errors.dart';
export 'src/password/password_validation_config.dart';
export 'src/password/password_validator.dart';
```

## Usage in Your App

### Basic Usage

```dart
import 'package:value_objects/value_objects.dart';

final email = Email('user@example.com');
if (email.isValid) {
  print('Valid: ${email.valueOrNull}');
} else {
  print('Error: ${email.errorOrNull}');
}

final password = Password('SecureP@ss123');
```

### With Flutter

```dart
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  Email? _email;
  Password? _password;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: _email?.errorOrNull?.let((error) {
              return switch (error) {
                EmailEmpty() => 'Email cannot be empty',
                EmailInvalidFormat() => 'Invalid email format',
                EmailTooLong() => 'Email too long',
              };
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
              return switch (error) {
                PasswordEmpty() => 'Password cannot be empty',
                PasswordTooShort(:final minLength) =>
                  'Password must be at least $minLength characters',
                PasswordComplexityRequired(:final requiredScore) =>
                  'Password must include $requiredScore types of characters',
              };
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

### Integration with Your Existing Architecture

```dart
// If you already have ValueObject and Failure classes:

import 'package:value_objects/value_objects.dart' as vo;

// Wrapper
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
```

## Next Steps

The full package includes:

- Text validation (username, name, etc.)
- Number validation (age, price, rating, etc.)
- More email features (disposable domain detection, blocked domains)
- More password features (common password detection, sequential patterns)
- Default English error messages
- Complete examples with Riverpod

Download the full package from the archive or copy the individual files above to get started.
