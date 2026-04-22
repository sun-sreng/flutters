# gmana

<p align="center">
  A core Dart foundation package for functional helpers, extensions, low-level validation primitives, and reusable utility classes.
</p>

---

> **Note:** This package is **pure Dart** and can be used in any Dart or Flutter project.
> For Flutter-specific widgets and UI utilities, please see [gmana_flutter](https://pub.dev/packages/gmana_flutter).

## 🚀 Installation

Add `gmana` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  gmana: ^0.1.5 # Please check pub.dev for the latest version
```

Or install it via CLI:

```bash
dart pub add gmana
# or
flutter pub add gmana
```

---

## 🛠 Features Overview

`gmana` is organized into several modules designed to make everyday Dart development easier.

- [**Functional Programming**](#functional-programming) (`Either`, `UseCase`, `Failure`, `Unit`)
- [**Rich Extensions**](#rich-extensions) (`String`, `num`, `Duration`, `Iterable`, `List`, `Stream`)
- [**Validation Utilities**](#validation-utilities) (String validation, rule builders, and field validators)
- [**Core Utilities**](#core-utilities) (ID Generators, Encoders)

### Focused Entry Points

Use the umbrella import when you want the whole curated surface, or import only the module you need:

```dart
import 'package:gmana/extensions.dart';
import 'package:gmana/functional.dart';
import 'package:gmana/utilities.dart';
import 'package:gmana/validation.dart';
```

---

## 🏗 Functional Programming

### `Either` Pattern

The `Either` type represents a value of one of two possible types (a disjoint union). It is commonly used as a functional alternative to throwing exceptions, handling errors gracefully.

```dart
import 'package:gmana/gmana.dart';

Either<String, int> divide(int a, int b) {
  if (b == 0) return Left('Cannot divide by zero');
  return Right(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  // Use `fold` to handle both cases securely
  result.fold(
    (error) => print('Error: $error'),
    (value) => print('Result: $value'),
  ); // Prints: Result: 5
}
```

### Clean Architecture `UseCase`

`UseCase` provides an interface boundary for your application business logic. Included are `Unit`, `Failure`, `NoParams`, and standard typedefs like `FutureEither<T>`.

```dart
class LoginParams {
  final String email, password;
  LoginParams(this.email, this.password);
}

class LoginUseCase implements UseCase<String, LoginParams> {
  @override
  FutureEither<String> call(LoginParams params) async {
    if (params.email.isEmpty) return Left(Failure('Email is empty'));
    // Do authenticate...
    return Right('AuthToken123');
  }
}
```

---

## ✨ Rich Extensions

### String Extensions

Extensive additions to the core `String` class.

```dart
// Formatting & Casing
print('hello world'.toTitleCase); // "Hello World"
print('hello world'.toSentenceCase); // "Hello world"

// Safe Parsing
print('12.9'.toDoubleOrNull); // 12.9
print('42'.toIntOrZero); // 42
print('invalid'.toDoubleOrZero); // 0.0

// Utilities
print('22:45'.toDuration()); // Duration(minutes: 22, seconds: 45)
print('This is a long article...'.readingTimeMinutes); // Outputs estimated minutes
print(null.orEmpty); // '' on a nullable String?
```

### Numbers & Duration

Syntax sugar for delays, timeouts, and reading times directly on `num` (`int` and `double`).

```dart
// Elegant semantic durations
final timeout = 10.seconds;
final limit = 2.hours;
final delay = 300.ms;

// Temperature and Normalization
print(25.celsiusToFahrenheit); // 77.0
double normalized = 260.normalized(0, 300); // 0.866
```

Readable times through the `Duration` extension:

```dart
final duration = Duration(hours: 1, minutes: 2, seconds: 34);
print(duration.toHumanizedString()); // "1:02:34"
```

### Iterable & List Utilities

Transform and analyze your collections easily.

```dart
final nested = [[1, 2], null, [3, 4]];

// Flatten lists of lists natively
print([[1, 2], [3, 4]].flatten()); // [1, 2, 3, 4]

// Sum operations on numeric Iterables
print([1, 2, 3].sum()); // 6

// compactMap (map and remove nulls seamlessly)
final numbers = [1, 2, null, 3].compactMap((e) => e != null ? e * 2 : null); // [2, 4, 6]
```

### Stream Utils

```dart
final stream = Stream.value([1, 2, 3, 4, 5]);
stream.filter((n) => n.isEven).listen(print); // prints: [2, 4]
```

---

## 🛡 Validation Utilities

### Instant String Validation

Immediate getters on `String` to assert valid formats quickly.

```dart
print('test@example.com'.isValidEmail); // true
print('password123'.isValidPassword); // false (needs special char, upper & lowercase)
print('+01234567890'.isValidPhone); // true
print('Jane Doe'.isValidName); // true
```

> Wait, there's more! Comprehensive match packages for UUIDs, IPv4/IPv6, Base64, hex colors, and ISBNs are baked in via the `is` and `regex` submodules.

### Form Validator Chains

A configurable validation engine built around reusable rules and field adapters.

```dart
final passwordRules = [
  Validators.required(message: 'Password is required'),
  Validators.minLength(8, message: 'Minimum 8 characters'),
  Validators.oneUpperCase(message: 'Add an uppercase letter'),
  Validators.oneSpecial(message: 'Add a special character'),
];

final error = Validators.validate('weakpass', passwordRules);
print(error); // "Add an uppercase letter"

final emailValidator = const EmailFieldValidator();
print(emailValidator.validate('user@example.com')); // null
```

---

## ⚙️ Core Utilities

### ID Generator

A handy wrapper class for generating various unique keys and encodings.

```dart
// Nanoids, UUIDs, and more!
print(IdGenerator.uuidV1()); // 123e4567-e89b...
print(IdGenerator.nanoid(size: 10)); // "KqYTJkLxpZ"
print(IdGenerator.timestampId()); // "G1697051234567-..."
print(IdGenerator.randomString(length: 6)); // "AbCdEf"
print(IdGenerator.encodeToBase64(['my', 'data']));
```
