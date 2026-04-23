# gmana

Core Dart utilities for production apps: functional result types, focused
extensions, validation primitives, ID generation, debounce/throttle helpers,
and small design-system constants.

`gmana` is pure Dart, so it works in CLI tools, server apps, packages, and
Flutter apps.

For a function-by-function guide with examples, see [doc/api.md](doc/api.md).

## Installation

```bash
dart pub add gmana
```

For Flutter projects:

```bash
flutter pub add gmana
```

Manual `pubspec.yaml` setup:

```yaml
dependencies:
  gmana: ^0.1.5
```

## Imports

Use the umbrella import when you want the curated public API:

```dart
import 'package:gmana/gmana.dart';
```

Or import only the area you need:

```dart
import 'package:gmana/extensions.dart';
import 'package:gmana/functional.dart';
import 'package:gmana/utilities.dart';
import 'package:gmana/validation.dart';
```

## What You Can Use

| Area                           | APIs                                                                        |
| ------------------------------ | --------------------------------------------------------------------------- |
| Functional results             | `Either`, `Left`, `Right`, `Failure`, `Unit`, `UseCase`, `FutureEither`     |
| String extensions              | casing, parsing, blank handling, slugs, duration parsing, truncation        |
| Number and duration extensions | `5.seconds`, `2.hours`, rounding, normalization, time formatting            |
| Iterable and list extensions   | `sum`, `average`, `median`, `chunked`, `groupBy`, `flatten`, `whereNotNull` |
| Stream extensions              | `debounce`, `throttle`, `scan`, `pairwise`, `whereNotNull`, `onErrorReturn` |
| Validation                     | email, password, number, text validators and form-validator adapters        |
| Utilities                      | `IdGenerator`, `Debouncer`, `Throttler`, `GSpacing`, `waveVerticalOffset`   |

## Functional Results

Use `Either<L, R>` when a function can fail and you want explicit success and
failure handling instead of exceptions.

```dart
import 'package:gmana/functional.dart';

Either<String, int> divide(int a, int b) {
  if (b == 0) return const Left('Cannot divide by zero');
  return Right(a ~/ b);
}

void main() {
  final result = divide(10, 2);

  final message = result.fold(
    (error) => 'Error: $error',
    (value) => 'Result: $value',
  );

  print(message); // Result: 5
}
```

Common helpers:

```dart
final result = Right<String, int>(10);

final doubled = result.map((value) => value * 2);
final value = doubled.getOrElse((error) => 0);
final isSuccess = doubled.isRight();
final nullable = doubled.rightOrNull();
```

## Use Cases

`UseCase` gives clean-architecture style boundaries for asynchronous operations
that may fail.

```dart
import 'package:gmana/functional.dart';

class LoginParams {
  const LoginParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class LoginUseCase implements UseCase<String, LoginParams> {
  @override
  FutureEither<String> call(LoginParams params) async {
    if (params.email.trim().isEmpty) {
      return const Left(Failure('Email is required'));
    }

    return const Right('auth-token');
  }
}
```

For operations with no meaningful success value, return `unit`:

```dart
FutureEitherUnit saveSettings() async {
  return const Right(unit);
}
```

## String Extensions

```dart
import 'package:gmana/extensions.dart';

void main() {
  print('hello world'.toTitleCase); // Hello World
  print('hello world'.toSentenceCase); // Hello world
  print('helloWorld'.toSnakeCase); // hello_world
  print('Hello World! 2026'.toSlug); // hello-world-2026

  print('42'.toIntOrNull); // 42
  print('bad'.toIntOrZero); // 0
  print('12.5'.toDoubleOrNull); // 12.5

  print('01:30'.toDuration()); // 0:01:30.000000
  print('A long article body'.readingTimeMinutes); // 1
  print('Hello World'.truncate(8)); // Hello...
}
```

Nullable string helpers:

```dart
String? name;

final safe = name.orEmpty; // ''
final normalized = '   '.blankToNull; // null
final displayName = name.mapNotBlank((value) => value.toTitleCase);
```

## Number And Duration Extensions

```dart
import 'package:gmana/extensions.dart';

final retryDelay = 500.ms;
final timeout = 30.seconds;
final cacheTtl = 2.hours;

await retryDelay.delay;

print(25.celsiusToFahrenheit); // 77.0
print(260.normalized(0, 300).roundTo(2)); // 0.87
print(27.roundToMultiple(5)); // 25
print(3.to(6).toList()); // [3, 4, 5, 6]
```

Duration formatting:

```dart
final duration = Duration(hours: 1, minutes: 2, seconds: 34);

print(duration.toHumanizedString()); // 1:02:34
print(duration.toPaddedString()); // 01:02:34
print(duration.toVerboseString()); // 1h 2m 34s
print(duration.toWordString()); // 1 hour, 2 minutes, 34 seconds
print(Duration(minutes: -5).toRelativeString()); // 5 minutes ago
```

## Iterable, List, And Stream Extensions

```dart
import 'package:gmana/extensions.dart';

final scores = [10, 20, 30, 40];

print(scores.sum()); // 100
print(scores.average); // 25.0
print(scores.median); // 25.0
print(scores.top(2)); // [40, 30]
print(scores.runningSum().toList()); // [10, 30, 60, 100]

print([1, 2, 3, 4, 5].chunked(2).toList()); // [[1, 2], [3, 4], [5]]
print(['a', 'bb', 'c'].groupBy((value) => value.length)); // {1: [a, c], 2: [bb]}
print([[1, 2], [3, 4]].flattenToList()); // [1, 2, 3, 4]
print([1, null, 2].whereNotNull.toList()); // [1, 2]
```

Stream helpers:

```dart
final values = Stream.fromIterable([1, 1, 2, 3]);

values
    .distinctUntilChanged()
    .scan(0, (total, value) => total + value)
    .listen(print); // 1, 3, 6
```

List-emitting streams:

```dart
Stream.value([1, 2, 3, 4])
    .filter((value) => value.isEven)
    .listen(print); // [2, 4]
```

## Validation

The canonical validators return `Either<Issue, Value>`. A `Right` contains the
normalized value. A `Left` contains a typed validation issue.

```dart
import 'package:gmana/validation.dart';

final emailResult = const EmailValidator().validate(' User@Example.com ');

emailResult.fold(
  (issue) => print(resolveEmailValidationIssue(issue)),
  (email) => print(email), // user@example.com
);
```

Strict email validation can reject disposable domains:

```dart
final validator = EmailValidator(EmailValidationConfig.strict());
final result = validator.validate('person@mailinator.com');
print(result.leftOrNull()?.code); // email.disposableDomain
```

Password validation:

```dart
final password = const PasswordValidator().validate('StrongP@ssw0rd');
final message = password.fold(resolvePasswordValidationIssue, (_) => null);
print(message); // null

final lenient = PasswordValidator(PasswordValidationConfig.lenient());
print(lenient.validate('abcd').isRight()); // true
```

Number and text validation:

```dart
final number = const NumberValidator(
  NumberValidationConfig(allowNegative: false, integerOnly: true),
).validate('42');

final text = const TextValidator(
  TextValidationConfig(trimWhitespace: true, minLength: 3),
).validate('  abc  ');

print(number.rightOrNull()); // 42
print(text.rightOrNull()); // abc
```

Flutter form adapters:

```dart
final emailFormValidator = asFormValidator(
  validate: const EmailValidator().validate,
  resolve: resolveEmailValidationIssue,
);

print(emailFormValidator('invalid-email')); // Please enter a valid email address
print(emailFormValidator('user@example.com')); // null
```

## Instant String Validation

Use `validation.dart` for format checks and regex helpers:

```dart
import 'package:gmana/validation.dart';

print('test@example.com'.isValidEmail); // true
print('Jane Doe'.isValidName); // true
print('550e8400-e29b-41d4-a716-446655440000'.isValidUuid); // true
print('#F57224'.isValidHexColor); // true
```

You can also call the lower-level functions directly:

```dart
print(isEmail('test@example.com')); // true
print(isInt('42')); // true
print(isBase64('YWJjZA==')); // true
print(isHexColor('#F57224')); // true
print(isLength('hello', 2, 10)); // true
```

## Utilities

Generate IDs and encoded values:

```dart
import 'package:gmana/utilities.dart';

final uuid = IdGenerator.uuidV1();
final nanoid = IdGenerator.nanoid(size: 10);
final timestampId = IdGenerator.timestampId();
final random = IdGenerator.randomString(length: 12);
final encoded = IdGenerator.encodeToBase64(['user', 123]);
```

Debounce and throttle repeated work:

```dart
final debouncer = Debouncer(milliseconds: 300);

debouncer.run(() {
  print('Runs after the user stops triggering events');
});

final throttler = Throttler(milliseconds: 1000);

throttler.run(() {
  print('Runs at most once per interval');
});
```

## Package Relationship

- Use `gmana` for pure Dart extensions, validation, functional results, and
  utilities.
- Use [`gmana_flutter`](https://pub.dev/packages/gmana_flutter) for Flutter
  widgets, form fields, theme helpers, color helpers, and UI convenience APIs.
- Use `gmana_value_objects` for typed domain values when that package is part
  of your project.
