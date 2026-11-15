## Unreleased

`gmana` now contains the code of `gmana_functional`, `gmana_utils`,
`gmana_extensions`, `gmana_predicates`, `gmana_validation`, and
`gmana_value_objects` instead of depending on them. Those packages are
discontinued. Every behaviour now has one implementation and one public name,
so several duplicate APIs were removed (listed below).

### Migration

Replace the old dependencies with `gmana` and update imports:

| Old import | New import |
| --- | --- |
| `package:gmana_functional/gmana_functional.dart` | `package:gmana/functional.dart` |
| `package:gmana_utils/gmana_utils.dart` | `package:gmana/utilities.dart` |
| `package:gmana_extensions/gmana_extensions.dart` | `package:gmana/extensions.dart` |
| `package:gmana_predicates/gmana_predicates.dart` | `package:gmana/predicates.dart` |
| `package:gmana_validation/gmana_validation.dart` | `package:gmana/validation.dart` |
| `package:gmana_value_objects/gmana_value_objects.dart` | `package:gmana/value_objects.dart` |

### Added

- `package:gmana/predicates.dart` topic library. `validation.dart` exports it
  too.
- `resolveValidationIssue(issue)`, which returns the default English message
  for any built-in `ValidationIssue`. `messageOrNull()` uses it when no
  resolver is passed.
- `PasswordValidationConfig.minCharacterClasses`, `minCodeUnit`,
  `maxCodeUnit`, and `sequentialRunFactor`, the
  `PasswordValidationConfig.balanced` preset, `copyWith`, and value equality.
  New issues: `PasswordDisallowedCharacterIssue` and
  `PasswordTooFewCharacterClassesIssue`.
- `TextValidationConfig` presets `username()`, `name()`, `shortText()`,
  `mediumText()`, `longText()`, and `alphanumeric()`, moved from the value
  objects. `copyWith` can now clear `minLength`, `maxLength`, `pattern`, and
  `allowedCharacters`, and the config has value equality.
- `TextValue.defaultConfig`, the policy `TextValue` uses when no config is
  passed.
- `MoneyValidationIssue` and `DateRangeValidationIssue` hierarchies with
  `resolveMoneyValidationIssue` and `resolveDateRangeValidationIssue`.
- `Money.maxMinorUnits` (2^53 − 1), the largest amount `Money` holds exactly on
  every platform, and `MoneyOutOfRangeIssue` (`money.outOfRange`), which
  `MoneyValidator` returns for amounts above it.

### Changed

- **Breaking:** value objects fail with the validation issue types.
  `Email.tryParse` returns `Either<EmailValidationIssue, Email>`, and likewise
  for `Password`, `TextValue`, `NumberValue`, `PhoneValue`, `UrlValue`,
  `IdentifierValue`, and `NetworkAddressValue`. Rename error classes by adding
  `Issue` (`EmailEmpty` → `EmailEmptyIssue`, `MoneyTooLarge` →
  `MoneyTooLargeIssue`, `DateRangeInvalidOrder` →
  `DateRangeInvalidOrderIssue`), and the sealed bases from `XError` to
  `XValidationIssue`.
- **Breaking:** issue codes are dotted and stable: `email_empty` →
  `email.empty`, `money_too_large` → `money.tooLarge`. Update any persisted or
  logged codes.
- **Breaking:** `ValueObjectException.error` is now `ValueObjectException.issue`.
- **Breaking:** value objects take the validation configs. Password configs
  map as `minComplexityScore` → `minCharacterClasses`, `minAsciiCode` /
  `maxAsciiCode` → `minCodeUnit` / `maxCodeUnit`, and `.strict()` →
  `.strong()`. `Password` still defaults to the previous policy, now named
  `PasswordValidationConfig.balanced`. The old `PasswordNonAscii` is
  `PasswordDisallowedCharacterIssue`; `PasswordTooWeak` and
  `PasswordComplexityRequired` are `PasswordTooFewCharacterClassesIssue`;
  `PasswordTooPredictable` is `PasswordRepeatedCharacterIssue` or
  `PasswordSequentialPatternIssue`.
- **Breaking:** `TextValidationConfig.pattern` is a `RegExp`, not a `String`.
  A `TextValidationConfig()` passed to `TextValue` now has the validation
  defaults (empty allowed, no trimming, whole-word blacklist). Use
  `TextValue.defaultConfig.copyWith(...)` or `TextValidationConfig.required(...)`
  to keep the previous value-object defaults.
- **Breaking:** the date predicates and `StringDateX` share one parser that
  rejects impossible values instead of rolling them over, in every form
  `DateTime.parse` accepts (extended, compact such as `20240215`, and
  signed-year). The day must exist, the hour must be 0–23, minutes and seconds
  0–59, and a zone offset at most 23:59. `isDate('2024-13-01')`,
  `isDate('20240231')`, `tryParseDate('2024-02-31')`,
  `'2024-02-15T10:75'.toDateTimeOrNull`, and every predicate given such a value
  now return `false` or `null`. Previously only `toDateTimeOrNull` and
  `isIso8601` rejected impossible days, and only in the `yyyy-MM-dd` form.
- **Breaking:** `DateValidator` compares a date-only input with `minDate` and
  `maxDate` by calendar day, using each bound's own year, month and day.
  `minDate: DateTime(2024, 1, 1)` now accepts `'2024-01-01'` in every timezone;
  before, the result depended on the local offset. Input with a time is still
  compared as an instant.
- **Breaking:** `Stream.debounce` and `Stream.throttle` use the stricter
  implementation from the former `gmana_utils`: both throw `ArgumentError`
  for a non-positive duration, and `throttle` takes `trailing:`.
- `package:gmana/gmana.dart` exports every area with no `hide` clauses.

### Fixed

- `MoneyValidator.validate` no longer throws a `FormatException` for an amount
  with more digits than an `int` holds, and no longer lets a large amount
  overflow into a wrong or negative value. Both now return
  `MoneyOutOfRangeIssue`. `Money` constructors, `+`, `*`, and `fromNum` throw a
  `RangeError` instead of overflowing, and `*`/`fromNum` reject non-finite
  numbers with an `ArgumentError`.
- `Money.allocate` no longer gives leftover minor units to a part whose ratio is
  zero. Leftover units now go to the parts with the largest remainder, and the
  arithmetic is exact for any amount and ratios.
- `kDefaultDisposableDomains` no longer lists `qq.com` and `fastmail.com`, two
  permanent providers, so `EmailValidationConfig.strict()` stops rejecting
  their users.
- `toDateTimeOrNull` (and so `toDateTime`, `year`, `daysUntil`, and the other
  `StringDateX` members) no longer returns `null` for a valid date-time whose
  zone offset moves it to another UTC day, such as
  `2024-06-15T23:00:00-05:00`.

### Removed

- **Breaking:** the parallel value-object validation layer: `ValidationError`,
  every `XError` hierarchy, `DefaultValidationErrorMessages`,
  `ValidationErrorMessages`, the value-object copies of the validators and
  configs, and the validation adapter extensions. Use the validators, configs,
  and issues from `validation.dart`, and `resolveValidationIssue` for
  messages.
- **Breaking:** `GmanaValueObjectResultX`. `GmanaValidationResultX` covers the
  same results; `errorOrNull` is `issueOrNull`.
- **Breaking:** `NumberNotInRange`, which no validator produced.
- **Breaking:** `GmanaStreamTimingX`. Its `debounce` and `throttle` are now the
  `StreamX` members.
- **Breaking:** `GmanaDateTimePredicatesX`. Use the `DateTimeX` members with
  the same names. Note that `DateTimeX.isToday` compares in local time, where
  the predicate version used UTC.
- **Breaking:** duplicate string helpers:

  | Removed | Use |
  | --- | --- |
  | `isNullOrBlank` | `isBlank` (also on `String?`) |
  | `blankToNull` | `orNull` |
  | `StringX.isAlphanumeric` | `isAlphaNumeric` |
  | `hasLengthBetween(min, max)` | `trim().isLength(min, max)` |
  | `isWithinLength(min:, max:)` | `isLength(min, max)` |
  | `isValidUrl` | `isUrl(allowedSchemes: {'http', 'https'})` |
  | `isValidUuid` | `isUuid('4')` |
  | `isValidIpAddress` | `isIP()` |
  | `isValidIpv4`, `isValidIpv6` | `isIpv4`, `isIpv6` |
  | `isValidSlug` | `trim().isSlug` |
  | `isValidCreditCard` | `isCreditCard` |
  | `isValidHexColor` | `isHexColor` |
  | `isValidMacAddress` | `isMacAddress` |

  `isLength` counts a surrogate pair (an emoji) as one character and does not
  check its arguments.
- **Breaking:** `StringDateX.isSameDayAs` and `StringDateX.isBetweenInclusive`.
  Use the predicate members `isSameDay` and `isBetweenInclusive`, which have
  the same call syntax. They compare in UTC, so a string with a local time
  near midnight can land on a different day than before.

## 0.2.2 - 2026-10-13

### Changed

- The `Either` ↔ `GResult` conversions (`toResult`, `toEither`, `toResultAsync`,
  `toEitherAsync`) are now declared in `gmana_functional`. The facade exports
  the same extensions as before and no longer contains code of its own.
- `IdentifierValidationConfig`, `NetworkValidationConfig`,
  `NumberValidationConfig`, `PhoneValidationConfig`, `UrlValidationConfig`,
  `IdentifierType`, and `NetworkAddressType` are now one class each, shared by
  `gmana_validation` and `gmana_value_objects`, so the facade no longer hides a
  second copy.
- Re-exported extensions follow their packages' renames to the `…X`
  convention (`HumanizedDuration` → `DurationX`, `StringDateExtension` →
  `StringDateX`, `NumDurationExtension` → `NumDurationX`,
  `GmanaStringPredicatesExt` → `GmanaStringPredicatesX`,
  `MoneyIterableExtension` → `MoneyIterableX`). Members are unaffected; only
  code that names an extension needs updating.
- The package description now lists `gmana_value_objects`, which the facade
  has re-exported since 0.2.0.

### Fixed

- `package:gmana/gmana.dart` no longer exports two declarations of `isEmail`,
  `isUrl`, `isAlpha`, `isNumeric`, `containsIgnoreCase`, `isNullOrEmpty`,
  `isDate`, `isToday`, `isPast`, `isFuture`, `isWeekend`, `isWeekday`,
  `isLeapYear`, `isAfter`, `isBefore`, and `isBetween` on `String`. Every call
  to one of them was an ambiguous-extension compile error. They now resolve to
  `gmana_predicates`; note that its `isUrl` is a method (`value.isUrl()`), its
  `isEmail` does not trim, and its `isNumeric` accepts digits only.

## 0.2.0 - 2026-05-18

- breaking: remove `GSpacing` from `utilities.dart`; import from `package:gmana_flutter/gmana_flutter.dart` instead
- breaking: remove `waveVerticalOffset` from `utilities.dart`; it lives only in `package:gmana_spinner`
- breaking: stop exporting raw regex constants from `validation.dart`; use predicate functions such as `isEmail`, `isUuid`, and `isPostalCode`
- breaking: remove the misleading callback `.debounce()` and `.throttle()` extensions; use retained `Debouncer`/`Throttler` instances or stream timing helpers instead
- breaking: replace `EitherFailure`, `FutureEither`, and `StreamEither` aliases with `Result`, `FutureResult`, and `StreamResult`
- breaking: remove public `IdGeneratorService` and `IdGeneratorUtils`; use `IdGenerator`
- breaking: consolidate exported duration helpers so `duration_ext.dart` is the only exported `Duration` extension API
- feat: add `IdGenerator.uuidV4Like()` and deprecate the misleading `uuidV1()` name
- fix: validate debounce/throttle durations and cancel stream throttle cooldown timers with the stream lifecycle
- refactor: clean self-package imports, validator docs, and text validator allowed-character configuration

## 0.1.6 - 2026-05-06

- feat: add async `Either` helpers with `mapAsync`, `flatMapAsync`, and `foldAsync`
- feat: add `Either` convenience helpers including `getOrNull`, `contains`, `exists`, `all`, `tap`, and `tapLeft`
- feat: add `StreamEither`, `StreamEitherUnit`, and `StreamUseCase` for fallible streaming use cases
- feat: expand `Failure` with optional `code` and structured `details`
- feat: enhance email validation with normalized domain policies, subdomain matching, and local-part dot checks
- doc: update README and API guide for the new functional helpers
- doc: expand public email validation examples and API reference

## 0.1.5 - 2026-04-23

- breaking: split the public surface into `functional.dart`, `extensions.dart`, `validation.dart`, and `utilities.dart`
- breaking: remove deprecated validator and utility aliases in favor of canonical rule builders, field validators, and utility classes
- doc: expand README into a practical usage guide for entrypoints, extensions, validation, functional results, and utilities

## 0.1.4

- doc: update README.md

## 0.1.3

- doc: add dart doc

## 0.1.2

- feat: add validators

## 0.1.1

- doc: add dart doc

## 0.1.0

- feat: refactor

## 0.0.14

- feat: theme_mode helper
- feat: locale helper

## 0.0.13

- doc: add validators

## 0.0.12

- doc: add format

## 0.0.11

- feat: add GElevatedButton

## 0.0.10

- feat: merge with gmana_ext

## 0.0.9

- feat: add either function

## 0.0.8

- feat: update staggered_dots_wave

## 0.0.7

- refactor structure of the library

## 0.0.6

- failure model
- server exception model

## 0.0.5

- add Validators

## 0.0.4

- format document.

## 0.0.3

- format document.

## 0.0.2

- format document.

## 0.0.1

- initial release.
