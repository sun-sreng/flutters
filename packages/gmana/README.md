# gmana

Pure Dart toolkit for production apps: functional types (`Either`, `Option`,
`GResult`), extensions, predicates, typed validators, value objects, and
resilience utilities such as debounce, throttle, retry, and circuit breakers.

`gmana` has no Flutter dependency, so it works in CLI tools, servers, shared
packages, and Flutter apps. For Flutter widgets, form fields, and spinners,
use [`gmana_flutter`](https://pub.dev/packages/gmana_flutter), which depends on
and re-exports `gmana`.

## Installation

```bash
dart pub add gmana
```

## Imports

Use the umbrella import for the whole API:

```dart
import 'package:gmana/gmana.dart';
```

Or import only the area you need:

```dart
import 'package:gmana/extensions.dart';
import 'package:gmana/functional.dart';
import 'package:gmana/predicates.dart';
import 'package:gmana/utilities.dart';
import 'package:gmana/validation.dart';   // also exports predicates.dart
import 'package:gmana/value_objects.dart';
```

> `predicates.dart` exports top-level functions named `equals` and `contains`.
> If a test file imports `package:test` as well, hide them:
> `import 'package:gmana/gmana.dart' hide contains, equals;`

## Guides

| Area | Guide |
| --- | --- |
| Functional types | [doc/functional.md](doc/functional.md) |
| Extensions | [doc/extensions.md](doc/extensions.md) |
| Predicates | [doc/predicates.md](doc/predicates.md) |
| Validation | [doc/validation.md](doc/validation.md) |
| Value objects | [doc/value_objects.md](doc/value_objects.md), with per-type pages in [doc/value_objects/](doc/value_objects/) |
| Utilities | [doc/utilities.md](doc/utilities.md) |
| Function-by-function reference | [doc/api.md](doc/api.md) |

## What You Can Use

| Area                           | APIs                                                                        |
| ------------------------------ | --------------------------------------------------------------------------- |
| Functional results             | `Either`, `Option`, `GResult`, `Result`, `FutureResult`, `Failure`, `Unit`, `UseCase`, `State`, `Try`, `Reader` |
| Value objects                  | `Email`, `Password`, `IdentifierValue`, `NetworkAddressValue`, `DateRangeValue`, `TextValue`, `NumberValue`, `Money` |
| String extensions              | casing, parsing, blank handling, slugs, duration parsing, truncation        |
| Number and duration extensions | `5.seconds`, `2.hours`, rounding, normalization, time formatting            |
| Iterable and list extensions   | `sum`, `average`, `median`, `chunked`, `groupBy`, `flatten`, `whereNotNull` |
| Stream extensions              | `debounce`, `throttle`, `scan`, `pairwise`, `whereNotNull`, `onErrorReturn` |
| Validation                     | typed validators with sealed `*ValidationIssue` results, and predicate functions |

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
final hasTwenty = doubled.contains(20);

final saved = await doubled
    .tap((value) => print('Saving $value'))
    .flatMapAsync((value) async => Right<String, int>(value + 1));
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
  FutureResult<String> call(LoginParams params) async {
    if (params.email.trim().isEmpty) {
      return const Left(Failure('Email is required'));
    }

    return const Right('auth-token');
  }
}
```

For operations with no meaningful success value, return `unit`:

```dart
FutureResultUnit saveSettings() async {
  return const Right(unit);
}
```

Use `StreamUseCase` when a use case emits fallible values over time:

```dart
class WatchCountUseCase implements StreamUseCase<int, NoParams> {
  @override
  StreamResult<int> call(NoParams params) async* {
    yield const Right<Failure, int>(1);
    yield const Left<Failure, int>(Failure('Stream stopped', 'counter_stopped'));
  }
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
final normalized = '   '.orNull; // null
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

Email validation is designed for product forms and domain input, not SMTP
delivery checks. It trims whitespace, lowercases the returned address, rejects
invalid local-part dot placement, enforces RFC email length limits, and returns
typed issues you can map to your own localized messages.

```dart
const validator = EmailValidator(
  EmailValidationConfig(
    blockedDomains: {'example.test', 'internal.company'},
    disposableDomains: {'mailinator.com', 'tempmail.com'},
    rejectDisposable: true,
  ),
);

final result = validator.validate(' Person@MAIL.Example.Test ');

result.fold(
  (issue) {
    print(issue.code); // email.blockedDomain
    print(resolveEmailValidationIssue(issue));
  },
  (email) => print(email),
);
```

Configured domains are trimmed and compared case-insensitively. By default a
configured domain also matches subdomains, so `example.com` blocks
`mail.example.com`. Set `matchSubdomains: false` when you only want exact
domain matches.

```dart
const exactOnly = EmailValidator(
  EmailValidationConfig(
    blockedDomains: {'example.com'},
    matchSubdomains: false,
  ),
);

print(exactOnly.validate('user@mail.example.com').rightOrNull());
// user@mail.example.com
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

final text = TextValidator(
  TextValidationConfig(trimWhitespace: true, minLength: 3),
).validate('  abc  ');

print(number.rightOrNull()); // 42
print(text.rightOrNull()); // abc
```

For Flutter `FormField.validator` adapters, use `asFormValidator` from
`package:gmana_flutter/form.dart`.

## Instant String Validation

Use `validation.dart` for format checks and regex helpers:

```dart
import 'package:gmana/validation.dart';

print('test@example.com'.isValidEmail); // true
print('Jane Doe'.isValidName); // true
print('550e8400-e29b-41d4-a716-446655440000'.isUuid('4')); // true
print('#F57224'.isHexColor); // true
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

final uuid = IdGenerator.uuidV4Like();
final nanoid = IdGenerator.nanoid(size: 10);
final timestampId = IdGenerator.timestampId();
final random = IdGenerator.randomString(length: 12);
final encoded = IdGenerator.encodeToBase64(['user', 123]);
```

`IdGenerator` uses non-cryptographic randomness. Do not use these helpers for
secrets, reset tokens, or security-sensitive identifiers.

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

## Migrating from the split packages

`gmana` 0.3.0 absorbs `gmana_functional`, `gmana_utils`, `gmana_extensions`,
`gmana_predicates`, `gmana_validation`, and `gmana_value_objects`. Those
packages are discontinued. Replace the dependency with `gmana` and update
imports:

| Old import | New import |
| --- | --- |
| `package:gmana_functional/gmana_functional.dart` | `package:gmana/functional.dart` |
| `package:gmana_utils/gmana_utils.dart` | `package:gmana/utilities.dart` |
| `package:gmana_extensions/gmana_extensions.dart` | `package:gmana/extensions.dart` |
| `package:gmana_predicates/gmana_predicates.dart` | `package:gmana/predicates.dart` |
| `package:gmana_validation/gmana_validation.dart` | `package:gmana/validation.dart` |
| `package:gmana_value_objects/gmana_value_objects.dart` | `package:gmana/value_objects.dart` |

API changes made while merging are listed in the [CHANGELOG](CHANGELOG.md).
