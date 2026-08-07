## 0.0.2

### Fixed

- **`tryParseDate` no longer shifts a bare date by the local UTC offset.**
  `DateTime.tryParse('2024-06-15')` returns *local* midnight, and the
  `toUtc()` that followed moved the calendar day: east of Greenwich
  `isWeekend('2024-01-13')` answered `false` for a Saturday, and
  `isToday`, `isSameDay`, `isLeapYear` and the rest were all off by a day for
  part of every day. A date carrying no time and no zone is now read as UTC
  midnight, so these predicates answer the same in every timezone. A value
  that does carry a time but no zone is still treated as local.

  This changes results for date-only input on any machine not at UTC+0. It is
  the behaviour the README already documented.

### Added

- **Combinators.** `Predicate<T>` plus `Predicates.all`, `.any`, `.none`,
  `.not`, `.alwaysTrue`, `.alwaysFalse`, `.equalTo`, `.oneOf`, and `.nullable`,
  with a fluent `PredicateX` extension providing `and`, `or`, `xor`,
  `negated`, `on` (retarget at a field of another type), `everyIn` and
  `anyIn`. Every existing predicate is assignable to `Predicate<String>`, so
  they compose directly.

- **Strings.** `isScreamingSnakeCase`, `isTitleCase`, `isBinary`, `isOctal`,
  `isBase32`, `isRgbColor`, `isHslColor`, `isPrintable`, `hasWhitespace`,
  `startsWithIgnoreCase`, `endsWithIgnoreCase`, `isAnagram`, `isDecimal`
  (with an optional exact `places`), `isLatitude`, `isLongitude`, `isLatLong`,
  and `isStrongPassword` with per-rule switches.

- **Dates.** `isBetweenInclusive` (the inclusive counterpart of the exclusive
  `isBetween`), `isYesterday`, `isTomorrow`, `isSameWeek`, `isWithinLast`,
  `isWithinNext`, `isStartOfMonth`, `isEndOfMonth`, `isAgeAtLeast`, and
  `isIso8601` — which unlike `isDate` rejects the space-separated form and
  out-of-range components that `DateTime.tryParse` silently rolls over.

- **Identifiers.** `isIban` (ISO 13616 mod-97 checksum) and `isBic`.
  `isUuid` now recognises versions `'1'`, `'6'` and `'7'` alongside 3, 4 and 5.

- **Network.** `isPrivateIpv4`, `isLoopbackIpv4`, `isPublicIpv4`, and
  `isHostname`, which unlike `isFQDN` does not require a TLD.

- **Fluent extensions** for every addition above, plus the experimental
  width predicates that were previously function-only: `isFullWidth`,
  `isHalfWidth`, `isMultiByte`, `isSurrogatePair`, `isVariableWidth`.

  `startsWithIgnoreCase`, `endsWithIgnoreCase` and `isBetweenInclusive` are
  deliberately function-only — `gmana_extensions` already declares those names
  on `String`, and a second declaration would make every call ambiguous for
  anyone importing `package:gmana`.

## 0.0.1

- Initial
