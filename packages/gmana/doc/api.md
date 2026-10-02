# gmana API Guide

Import the full curated API:

```dart
import 'package:gmana/gmana.dart';
```

Or import by area:

```dart
import 'package:gmana/extensions.dart';
import 'package:gmana/functional.dart';
import 'package:gmana/utilities.dart';
import 'package:gmana/validation.dart';
```

## Functional Results

Use `Either<L, R>` for functions that can fail without throwing exceptions.

```dart
Either<Failure, int> parseCount(String input) {
  final value = int.tryParse(input);
  if (value == null) return const Left(Failure('Invalid count'));
  return Right(value);
}

final message = parseCount('4').fold(
  (failure) => failure.message,
  (count) => 'Count: $count',
);
```

| API                              | Use it for                                                         |
| -------------------------------- | ------------------------------------------------------------------ |
| `Either<L, R>`                   | Model a value that is either a left failure or a right success.    |
| `Left<L, R>`                     | Return or construct a failed result.                               |
| `Right<L, R>`                    | Return or construct a successful result.                           |
| `fold(left, right)`              | Convert either branch into one return value.                       |
| `foldAsync(left, right)`         | Convert either branch with async callbacks.                        |
| `map(transform)`                 | Transform only the right value.                                    |
| `mapAsync(transform)`            | Transform only the right value with an async callback.             |
| `flatMap(transform)`             | Chain another `Either`-returning operation.                        |
| `flatMapAsync(transform)`        | Chain another async `Either`-returning operation.                  |
| `mapLeft(transform)`             | Transform only the left value.                                     |
| `getOrElse(fallback)`            | Extract the right value or derive a fallback from the left value.  |
| `leftOrNull()` / `rightOrNull()` | Read one side as nullable.                                         |
| `getOrNull()`                    | Alias for reading the right value as nullable.                     |
| `contains(value)`                | Check whether this is a right value equal to `value`.              |
| `exists(test)` / `all(test)`     | Run predicates against the right value.                            |
| `tap(callback)` / `tapLeft(...)` | Run side effects for the matching side and keep the same `Either`. |
| `isLeft()` / `isRight()`         | Check which side is present.                                       |
| `Result<T>`                      | Alias for `Either<Failure, T>`.                                    |
| `ResultUnit`                     | Alias for `Result<Unit>`.                                          |
| `Failure`                        | Standard failure object with message, code, and optional details.  |
| `NoParams`                       | Placeholder params object for use cases without input.             |
| `Unit` / `unit`                  | Success marker for operations with no meaningful return value.     |
| `UseCase<T, P>`                  | Clean-architecture callable interface.                             |
| `FutureResult<T>`                | Alias for `Future<Either<Failure, T>>`.                            |
| `FutureResultUnit`               | Alias for `FutureResult<Unit>`.                                    |
| `StreamUseCase<T, P>`            | Clean-architecture interface for fallible streams.                 |
| `StreamResult<T>`                | Alias for `Stream<Either<Failure, T>>`.                            |
| `StreamResultUnit`               | Alias for `StreamResult<Unit>`.                                    |

## String Extensions

```dart
import 'package:gmana/extensions.dart';

final slug = 'Hello World!'.toSlug; // hello-world
final maybeAge = '42'.toIntOrNull; // 42
final title = 'hello world'.toTitleCase; // Hello World
```

| API                                                     | Use it for                                            |
| ------------------------------------------------------- | ----------------------------------------------------- |
| `isNullOrBlank`                                         | Check nullable strings safely.                        |
| `orEmpty`, `orNull`                                     | Normalize nullable or blank strings.                  |
| `mapNotBlank(transform)`                                | Transform only non-null, non-blank strings.           |
| `blankToNull`                                           | Convert a blank string to `null`.                     |
| `isAlphanumeric`, `isBlank`, `isNotBlank`               | Common text checks.                                   |
| `jsonDecodeOrNull`                                      | Decode JSON without throwing on invalid input.        |
| `readingTimeMinutes`                                    | Estimate reading time at 225 words per minute.        |
| `removeWhitespace`, `reversed`                          | Transform string content.                             |
| `toBool`                                                | Parse `'true'` as `true`; everything else is `false`. |
| `toCamelCase`, `toKebabCase`, `toSnakeCase`             | Convert naming style.                                 |
| `toScreamingSnakeCase`, `toSentenceCase`, `toTitleCase` | Convert text casing.                                  |
| `toSlug`                                                | Build a URL-safe lowercase slug.                      |
| `toDoubleOrNull`, `toDoubleOrZero`                      | Parse doubles safely.                                 |
| `toIntOrNull`, `toIntOrZero`                            | Parse integers safely.                                |
| `toUriOrNull`                                           | Parse a URI safely.                                   |
| `toDuration()`, `toDurationOrNull`                      | Parse `SS`, `MM:SS`, or `HH:MM:SS`.                   |
| `countOccurrences(pattern)`                             | Count non-overlapping matches.                        |
| `hasLengthBetween(min, max)`                            | Check trimmed length bounds.                          |
| `repeat(count)`                                         | Repeat the string.                                    |
| `truncate(maxLength)`                                   | Truncate with an ellipsis.                            |
| `truncateWords(maxLength)`                              | Truncate at a word boundary.                          |
| `wrap(prefix, [suffix])`                                | Surround text with a prefix and suffix.               |

## Number Extensions

```dart
import 'package:gmana/extensions.dart';

final pageNumbers = 1.to(5).toList(); // [1, 2, 3, 4, 5]
final percent = 260.normalized(0, 300).roundTo(2); // 0.87
final retryDelay = 500.ms;
```

| API                                                     | Use it for                                               |
| ------------------------------------------------------- | -------------------------------------------------------- |
| `bool?.isNullOrFalse`, `orFalse`, `orTrue`              | Nullable boolean defaults.                               |
| `double?.isNullOrZero`, `orZero`, `orDefault(fallback)` | Nullable double defaults.                                |
| `int?.isNullOrZero`, `orZero`, `orDefault(fallback)`    | Nullable integer defaults.                               |
| `num?.isNullOrZero`, `orZero`, `orDefault(fallback)`    | Nullable number defaults.                                |
| `digitCount`, `digits`                                  | Inspect integer digits.                                  |
| `int.isEven`, `int.isOdd`                               | Integer parity checks.                                   |
| `int.isBetween(min, max)`                               | Inclusive integer range check.                           |
| `times(action)`                                         | Run an action `n` times.                                 |
| `to(end, step: 1)`                                      | Build an inclusive integer range.                        |
| `celsiusToFahrenheit`, `celsiusToKelvin`                | Temperature conversions.                                 |
| `fahrenheitToCelsius`, `fahrenheitToKelvin`             | Temperature conversions.                                 |
| `kelvinToCelsius`, `kelvinToFahrenheit`                 | Temperature conversions.                                 |
| `isWholeNumber`                                         | Check whether a `num` has no fraction.                   |
| `ceilToMultiple(multiple)`                              | Round up to a multiple.                                  |
| `floorToMultiple(multiple)`                             | Round down to a multiple.                                |
| `roundToMultiple(multiple)`                             | Round to the nearest multiple.                           |
| `num.isBetween(min, max)`                               | Inclusive numeric range check.                           |
| `lerp(a, b)`                                            | Linear interpolation where the number is `t`.            |
| `normalized(fromMin, fromMax, [toMin, toMax])`          | Map a value from one range into another.                 |
| `normalizedClamped(...)`                                | Normalize and clamp to the output range.                 |
| `safeNormalized(...)`                                   | Normalize with a fallback when the source range is zero. |
| `roundTo(places)`                                       | Round to decimal places.                                 |

## Duration Extensions

```dart
import 'package:gmana/extensions.dart';

await 2.seconds.delay;

final duration = Duration(hours: 1, minutes: 2, seconds: 34);
duration.toHumanizedString(); // 1:02:34
duration.toWordString(); // 1 hour, 2 minutes, 34 seconds
```

`package:gmana/extensions.dart` exports a single `Duration` extension API from
`duration_ext.dart`. The alternative natural-language duration helpers remain
available only by direct import from `extensions/duration_natural_language_ext.dart`.

| API                                                                     | Use it for                                          |
| ----------------------------------------------------------------------- | --------------------------------------------------- |
| `1.microseconds`, `1.ms`, `1.milliseconds`                              | Create short durations from numbers.                |
| `1.seconds`, `1.minutes`, `1.hours`, `1.days`, `1.weeks`                | Create larger durations from numbers.               |
| `delay`, `delayed(callback)`                                            | Wait for a duration in async code.                  |
| `abs`, `isNegative`, `isPositive`, `isZero`                             | Inspect duration sign.                              |
| `inSecondsDouble`, `inMinutesDouble`, `inHoursDouble`                   | Fractional unit conversions.                        |
| `inDaysDouble`, `inWeeksDouble`, `inMillisecondsDouble`                 | Fractional unit conversions.                        |
| `operator *`, `operator /`                                              | Scale durations.                                    |
| `clamp(min, max)`, `coerceAtLeast(min)`, `coerceAtMost(max)`            | Bound durations.                                    |
| `toHHMMSS()`                                                            | Format for timers and players.                      |
| `toHuman()`                                                             | Compact human-readable output.                      |
| `hoursPart`, `minutesPart`, `secondsPart`, `millisecondsPart`           | Component accessors.                                |
| `totalDays`, `totalHours`, `totalMinutes`                               | Fractional totals.                                  |
| `ceilToMinutes()`, `floorToMinutes()`, `roundToMinutes()`               | Minute rounding.                                    |
| `roundToSeconds()`                                                      | Second rounding.                                    |
| `isLongerThan(other)`, `isShorterThan(other)`, `isWithin(range, other)` | Duration comparisons.                               |
| `progressOf(total)`                                                     | Convert elapsed duration into a 0-1 progress value. |
| `remainingIn(total)`                                                    | Calculate remaining duration.                       |
| `toFrames(fps)`, `DurationX.fromFrames(frames, fps)`            | Convert between duration and frame counts.          |
| `toHumanizedString()`, `toPaddedString()`                               | Stopwatch-style formatting.                         |
| `toRelativeString()`                                                    | Format as `in 2 hours` or `5 minutes ago`.          |
| `toSeconds()`                                                           | Fractional seconds.                                 |
| `toVerboseString()`, `toWordString()`                                   | Longer display strings.                             |

## Iterable And Stream Extensions

```dart
import 'package:gmana/extensions.dart';

final scores = [10, 20, 30];
scores.sum(); // 60
scores.average; // 20.0

final grouped = ['a', 'bb'].groupBy((value) => value.length);
```

| API                                                     | Use it for                                              |
| ------------------------------------------------------- | ------------------------------------------------------- |
| `whereNotNull`, `compact()`                             | Remove null values from nullable iterables.             |
| `compactMap(transform)`                                 | Transform and remove null results.                      |
| `flatten()`, `flattenToList()`                          | Flatten nested iterables.                               |
| `chunked(size)`                                         | Split an iterable into fixed-size chunks.               |
| `distinctBy(keyOf)`                                     | Keep first item per key.                                |
| `flatMap(transform)`, `flatMapNotNull(transform)`       | Map to iterables and flatten.                           |
| `groupBy(keyOf)`                                        | Group items by key.                                     |
| `sum()`, `product()`                                    | Aggregate numeric iterables.                            |
| `average`, `averageOrThrow`                             | Compute arithmetic mean.                                |
| `minOrNull`, `minOrThrow`, `maxOrNull`, `maxOrThrow`    | Min/max helpers.                                        |
| `median`, `range`, `variance`, `stdDev`                 | Basic statistics.                                       |
| `allPositive`, `allNegative`, `allNonNegative`          | Numeric predicates.                                     |
| `top(n)`, `bottom(n)`                                   | Highest or lowest values.                               |
| `clampAll(lo, hi)`, `normalize()`                       | Transform numeric series.                               |
| `runningSum()`, `runningProduct()`                      | Lazy cumulative aggregates.                             |
| `Stream<List<T>>.lengths`                               | Emit each list length.                                  |
| `Stream<List<T>>.whereNotEmpty`                         | Keep non-empty lists.                                   |
| `filter(predicate)`, `mapItems(transform)`              | Transform each emitted list.                            |
| `flatMapItems(transform)`, `flatten()`                  | Flatten emitted lists.                                  |
| `sortedBy(compare)`                                     | Sort each emitted list.                                 |
| `indexed`                                               | Emit `(index, value)` pairs.                            |
| `pairwise`                                              | Emit `(previous, current)` pairs.                       |
| `debounce(duration)`, `throttle(duration)`              | Rate-limit stream events.                               |
| `distinctUntilChanged([equals])`                        | Skip repeated neighboring values.                       |
| `lastOrNull()`                                          | Read the last stream value or `null`.                   |
| `onErrorReturn(fallback)`, `onErrorReturnWith(recover)` | Recover stream errors.                                  |
| `scan(seed, accumulate)`                                | Emit running state.                                     |
| `skipUntil(predicate)`                                  | Ignore events until a predicate matches.                |
| `takeWhileInclusive(predicate)`                         | Emit until predicate first fails, including that value. |
| `whereNotNull<R>()`                                     | Narrow a stream to non-null values.                     |

## Validation

Validators return `Either<ValidationIssue, String>` so UI and domain code can
choose how to display errors.

```dart
import 'package:gmana/validation.dart';

final result = EmailValidator().validate('user@example.com');
final message = result.fold(resolveEmailValidationIssue, (_) => null);
```

Email validation normalizes successful values by trimming whitespace and
lowercasing the address. It also rejects invalid local-part dot placement such
as `.user@example.com`, `user.@example.com`, and `user..name@example.com`.

```dart
const validator = EmailValidator(
  EmailValidationConfig(
    blockedDomains: {'blocked.example'},
    disposableDomains: {'mailinator.com'},
    rejectDisposable: true,
  ),
);

final blocked = validator.validate('User@Blocked.Example');
print(blocked.leftOrNull()?.code); // email.blockedDomain

final disposable = validator.validate('user@mailinator.com');
print(disposable.leftOrNull()?.code); // email.disposableDomain
```

Configured domains are trimmed and compared case-insensitively. Domain policies
match subdomains by default, so `blocked.example` also matches
`mail.blocked.example`. Use `matchSubdomains: false` for exact matches only.

```dart
const validator = EmailValidator(
  EmailValidationConfig(
    blockedDomains: {'blocked.example'},
    matchSubdomains: false,
  ),
);

print(validator.validate('user@mail.blocked.example').rightOrNull());
// user@mail.blocked.example
```

| API                                         | Use it for                                                                                 |
| ------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `EmailValidationConfig`                     | Configure email length, local/domain limits, disposable domains, and blocked domains.      |
| `EmailValidationConfig.strict()`            | Reject disposable domains using the default disposable-domain list.                        |
| `EmailValidationConfig.matchSubdomains`     | Decide whether configured domains also match subdomains.                                   |
| `EmailValidator(config).validate(value)`    | Validate and normalize an email string.                                                    |
| `EmailValidationIssue`                      | Base type for typed email validation failures.                                             |
| `EmailEmptyIssue`                           | Input is empty after trimming.                                                             |
| `EmailInvalidFormatIssue`                   | Input does not match the supported email format.                                           |
| `EmailTooLongIssue`                         | Full address exceeds the configured maximum length.                                        |
| `EmailLocalPartTooLongIssue`                | Local part before `@` exceeds the configured maximum length.                               |
| `EmailDomainTooLongIssue`                   | Domain after `@` exceeds the configured maximum length.                                    |
| `EmailDisposableDomainIssue`                | Domain is disposable and disposable domains are rejected.                                  |
| `EmailBlockedDomainIssue`                   | Domain is in the configured block list.                                                    |
| `resolveEmailValidationIssue(issue)`        | Convert email validation issues to English messages.                                       |
| `PasswordValidationConfig`                  | Configure password length, character classes, common-password checks, and pattern checks.  |
| `PasswordValidator(config).validate(value)` | Validate a password string.                                                                |
| `resolvePasswordValidationIssue(issue)`     | Convert password validation issues to English messages.                                    |
| `NumberValidationConfig`                    | Configure number bounds, integer-only mode, negatives, and decimal places.                 |
| `NumberValidator(config).validate(value)`   | Validate and normalize numeric text.                                                       |
| `resolveNumberValidationIssue(issue)`       | Convert number validation issues to English messages.                                      |
| `TextValidationConfig`                      | Configure required text, trimming, length, pattern, allowed characters, and blocked words. |
| `TextValidator(config).validate(value)`     | Validate and normalize text.                                                               |
| `resolveTextValidationIssue(issue)`         | Convert text validation issues to English messages.                                        |
| `ValidationIssue.code`                      | Stable machine-readable error code.                                                        |
| `ValidationResult<TIssue, TValue>`          | Alias for `Either<TIssue, TValue>`.                                                        |
| `ValidationMessageResolver<TIssue>`         | Alias for an issue-to-message function.                                                    |

## Predicate Functions

Import `package:gmana/validation.dart` for standalone checks.

```dart
isEmail('user@example.com'); // true
isUuid('550e8400-e29b-41d4-a716-446655440000'); // true
```

| API                                                                               | Use it for                                                     |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `contains`, `containsIgnoreCase`, `equals`, `matches`                             | Generic string matching.                                       |
| `isAfter`, `isBefore`, `isDate`                                                   | Date-like string checks.                                       |
| `isAlpha`, `isAlphaNumeric`, `isAscii`, `isFullWidth`, `isHalfWidth`              | Character set checks.                                          |
| `isBase64`, `isCreditCard`, `isEmail`, `isFQDN`, `isHexColor`                     | Common structured formats.                                     |
| `isHexadecimal`, `isISBN`, `isInt`, `isFloat`, `isNumeric`                        | Numeric and identifier-like formats.                           |
| `isJson`, `isMongoId`, `isPostalCode`, `isUuid`                                   | Data format checks.                                            |
| `isByteLength`, `isLength`                                                        | Length checks.                                                 |
| `isDivisibleBy`                                                                   | Numeric divisibility check.                                    |
| `isLowerCase`, `isUpperCase`, `isMultiByte`, `isSurrogatePair`, `isVariableWidth` | Text property checks.                                          |

## Utilities

```dart
import 'package:gmana/utilities.dart';

final id = IdGenerator.uuidV4Like();

final debouncer = Debouncer(milliseconds: 300);
debouncer.run(() => print('Search'));
```

`IdGenerator` uses non-cryptographic randomness and reversible Base64 encoding.
Do not use it for secrets or security-sensitive tokens.

| API                       | Use it for                                                                            |
| ------------------------- | ------------------------------------------------------------------------------------- |
| `IdGenerator`             | Generate UUID-shaped IDs, nano IDs, random strings, timestamp IDs, and Base64 values. |
| `Debouncer.run(action)`   | Run only the last action after a quiet period.                                        |
| `Debouncer.dispose()`     | Cancel pending debounced work.                                                        |
| `Throttler.run(action)`   | Run an action at most once per cooldown window.                                       |
| `Throttler.dispose()`     | Cancel pending throttler state.                                                       |
