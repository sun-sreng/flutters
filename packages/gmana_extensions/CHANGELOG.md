## Unreleased

### Changed

- **`StringValidation` moved to `gmana_validation`** and is re-exported from
  this package, so `isValidEmail`, `isValidPhone`, `passwordStrength`, and the
  rest resolve exactly as before.
- **Extensions renamed to the `…X` convention.** `HumanizedDuration` →
  `DurationX`, `StringDateExtension` → `StringDateX`, `NumDurationExtension` →
  `NumDurationX`. Extension members are unaffected; only code that names the
  extension — a `show`/`hide` clause or an explicit override such as
  `HumanizedDuration(value).humanized` — needs the new name.
  `HumanizedDuration.fromFrames` keeps working through a deprecated shim.

### Deprecated

- `Iterable.mapConcurrent` — use `mapConcurrent` from `gmana_utils`, which
  stops starting new work after the first failure.
- **String classification members that duplicate `gmana_predicates`.**
  `isAlpha`, `isEmail`, `isNumeric`, `isUrl`, `containsIgnoreCase`,
  `isNullOrEmpty`, `isDate`, `isToday`, `isPast`, `isFuture`, `isWeekend`,
  `isWeekday`, `isLeapYear`, `isAfter`, `isBefore`, and `isBetween` moved from
  `StringX`, `StringNullableX`, and `StringDateX` into
  `StringPredicateCompatX` / `StringNullablePredicateCompatX` and are
  deprecated. `gmana_predicates` declares the same names on `String`, so
  importing both packages — as `package:gmana/gmana.dart` does — made every
  call ambiguous. Behaviour is unchanged and implicit calls such as
  `'a@b.c'.isEmail` keep working; only explicit overrides like
  `StringX(value).isEmail` need the new extension name.

### Internal

- Added `fake_async` as a dev dependency so the `Duration.delay`,
  `Duration.delayed`, and `Future.delayedBy` tests run on fake time instead of
  asserting on wall-clock elapsed time. No public API changes.

## 0.0.2

Additive release — no existing member changed behaviour or signature.

### New receiver types

- **Any object** (`object_ext.dart`): Kotlin-style scope functions
  `let`, `also`, `takeIf`, `takeUnless`, `asOrNull`, plus null-aware
  `isNull`, `isNotNull`, `letOrNull`, `alsoNotNull`, `orElseGet`.
- **`Comparable`** (`comparable_ext.dart`): `<`, `<=`, `>`, `>=` operators for
  `String`/`DateTime`/`Duration`, plus `coerceIn`, `coerceAtLeast`,
  `coerceAtMost`, `coerceMin`, `coerceMax`, `isInRange`, `isInRangeExclusive`.
- **`Set`** (`set_ext.dart`): `toggle`, `toggled`, `isSubsetOf`, `isSupersetOf`,
  `isProperSubsetOf`, `isProperSupersetOf`, `intersects`, `isDisjointFrom`,
  `symmetricDifference`, `addAllNew`, and `SetNullableX`.
- **`Future`** (`future_ext.dart`): `timeoutOrNull`, `timeoutWith`, `orNull`,
  `onErrorReturn`, `onErrorReturnWith`, `settled`, `thenMap`, `tap`,
  `delayedBy`, plus `mapSequential`, `mapParallel`, `mapConcurrent`, and
  `whereAsync` on `Iterable`.
- **`Uri`** (`uri_ext.dart`): `isSecure`, `isHttp`, `domain`, `fileName`,
  `fileExtension`, `origin`, `withQueryParameters`, `withoutQueryParameters`,
  `withoutQuery`, `appendPath`, and `UriNullableX`.

### Extended receivers

- **`Iterable`**: `firstOrNull`, `lastOrNull`, `elementAtOrNull`, `none`,
  `countWhere`, `whereNot`, `mapNotNull`, `mapIndexed`, `whereIndexed`,
  `forEachIndexed`, `foldIndexed`, `zip`, `zipWith`, `sortedBy`,
  `sortedByDescending`, `sortedWith`, `maxBy`, `minBy`, `sumBy`, `averageBy`,
  `joinToString`, `splitWhen`, `randomOrNull`.
- **`List`**: new `ListX` with `isValidIndex`, `getOrNull`, `getOrElse`, `swap`,
  `swapped`, `moved`, `rotated`, `replaceWhere`, `shuffled`, `distinct`,
  `takeLast`, `dropLast`, plus `ListNullableX`.
- **`DateTime`**: `daysInMonth`, `dayOfYear`, `weekOfYear` (ISO 8601), `quarter`,
  `isPast`, `isFuture`, `startOfMinute`, `startOfHour`, `endOfHour`,
  `startOfQuarter`, `endOfQuarter`, `startOfYear`, `endOfYear`, `isSameMonth`,
  `isSameYear`, `isSameWeek`, `addMonths`, `subtractMonths`, `addYears`,
  `subtractYears`, `daysUntil`, `businessDaysUntil`, `addBusinessDays`,
  `nextWeekday`, `previousWeekday`, `toDateString`, `toTimeString`,
  `toDateTimeString`, `toRelativeString`, `toDateStringOrNull`, `orDate`.
- **`String`**: `words`, `lines`, `initials`, `chunked`, `equalsIgnoreCase`,
  `containsIgnoreCase`, `startsWithIgnoreCase`, `endsWithIgnoreCase`,
  `swapCase`, `ensurePrefix`, `ensureSuffix`, `padCenter`, `indent`,
  `normalizeWhitespace`, `stripHtmlTags`, `charAtOrNull`, `substringSafe`,
  `toBase64`, `fromBase64OrNull`, `toBoolOrNull`, `levenshteinDistance`,
  `similarityTo`, plus `ifBlank` and `ifEmpty` on `String?`.
- **`num` / `int`**: `toRadians`, `toDegrees`, `raisedTo`, `squareRoot`,
  `orFinite`, `isPrime`, `isPowerOfTwo`, `lcm`, `factorial`, and a new
  `num_format_ext.dart` with `toCompact`, `toBytes`, `toThousands`,
  `toCurrency`, `toPercentString`, `toFixed`, `toTrimmed`, `toOrdinal`,
  `toRoman`, `toPadded`, `toHexString`, `toBinaryString`, `toOctalString`.
- **`Stream`**: `bufferCount`, `startWith`, `startWithMany`, `doOnData`,
  `doOnError`, `doOnDone`, `mapNotNull`, `whereNot`, `ignoreErrors`,
  `firstOrNull`, `mergeWith`.

### Notes

- `ComparableX` uses `isInRange`/`isInRangeExclusive` rather than `isBetween`
  because `StringDateExtension.isBetween` already owns that name on `String`
  with date-parsing semantics and wins extension resolution.
- The generic nullable helpers deliberately avoid `orDefault` so the existing
  `IntNullableX`/`BoolNullableX`/`NumNullableX` signatures keep resolving first.

## 0.0.1

- Initial release. Extracted pure-Dart extension methods from `gmana` into a dedicated package.
