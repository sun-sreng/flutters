## Unreleased

- change: re-exported extensions follow their packages' renames to the `…X` convention (`HumanizedDuration` → `DurationX`, `StringDateExtension` → `StringDateX`, `NumDurationExtension` → `NumDurationX`, `GmanaStringPredicatesExt` → `GmanaStringPredicatesX`, `MoneyIterableExtension` → `MoneyIterableX`). Members are unaffected; only code that names an extension needs updating.
- fix: `package:gmana/gmana.dart` no longer exports two declarations of `isEmail`, `isUrl`, `isAlpha`, `isNumeric`, `containsIgnoreCase`, `isNullOrEmpty`, `isDate`, `isToday`, `isPast`, `isFuture`, `isWeekend`, `isWeekday`, `isLeapYear`, `isAfter`, `isBefore`, and `isBetween` on `String`. Every call to one of them was an ambiguous-extension compile error. They now resolve to `gmana_predicates`; note that its `isUrl` is a method (`value.isUrl()`), its `isEmail` does not trim, and its `isNumeric` accepts digits only.
- docs: the package description now lists `gmana_value_objects`, which the facade has re-exported since 0.2.0.

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
