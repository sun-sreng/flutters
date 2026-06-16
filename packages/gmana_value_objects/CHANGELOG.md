# Changelog

## 0.1.0 - 2026-06-16

Major redesign around an "always valid" value-object model. This release
contains **breaking changes**.

### Breaking

- Value objects are now always valid. `Email`, `Password`, `TextValue`, and
  `NumberValue` no longer wrap an `Either<ValidationError, T>`; their `value`
  getter now returns the validated primitive directly.
  - Use `T.tryParse(input)` (returns `Either<Error, T>`) for untrusted input.
  - Use the `T(input)` constructor for trusted literals; it throws
    `ValueObjectException` when the input is invalid.
  - Removed `value` (as `Either`), `isValid`, `isInvalid`, `valueOrNull`,
    `errorOrNull`, and the `T.validated(...)` constructors.
- Removed `MoneyAmount`. Its behavior is merged into `Money`, which is now a
  standalone composite value object (no longer extends `ValueObject`). Removed
  `Money.fromAmount` and `Money.amountValue`; `MoneyValidator` now returns
  `Either<MoneyError, Money>`.
- `Password.toString()` now returns `Password(***)` (value masked) instead of
  `Password(valid)` / `Password(invalid)`.
- `NumberValue.asInt` / `asDouble` are now non-nullable; added
  `NumberValue.tryParse` and `NumberValue.tryParseNum`.

### Added

- `ValueObjectException`, thrown by throwing constructors and wrapping the
  underlying `ValidationError`.
- Structural `==` / `hashCode` for all value objects (via the `ValueObject`
  base) and for all validation config classes.
- `copyWith` on every validation config. Nullable fields (e.g. `min`, `max`,
  `pattern`, `allowedCurrencies`) can be cleared by passing `null` explicitly.

### Fixed

- Email validation now rejects a local part that starts or ends with a dot, or
  contains consecutive dots (for example `.a@x.com`, `a.@x.com`, `a..b@x.com`),
  which the format regex previously accepted.

### Changed

- `EmailValidator` no longer normalizes disposable/blocked domain sets on every
  call; the default (disposable allowed, no blocked domains) path does no extra
  work.
- `Money.fromNum` now computes minor units directly with half-up rounding
  instead of routing through a throwaway `MoneyAmount`.
- `Currency.subunitFactor` is now resolved without recomputing a power-of-ten on
  every access.
- Removed dead/duplicate imports in `MoneyValidationConfig`.
- `ValidationError.code` documents that derivation from `runtimeType` is not
  stable under code obfuscation; override `code` for persisted/transport codes.
- Rewrote `QUICK_START.md` and `PACKAGE_STRUCTURE.md`, which referenced an
  outdated package name, dependency, and API.

## 0.0.6 - 2026-05-24

### Changed

- Annotated `Money` as `@immutable` to satisfy strict equality/hashCode lints.
- Updated lint configuration to use the shared `gmana_lints` workspace ruleset.
- Internal test, dependency, and documentation polish — no public API changes.

## 0.0.5 - 2026-05-05

### Added

- Add `Money`, `MoneyAmount`, `Currency`, `MoneyValidator`, money validation errors, and money validation config for currency-aware ecommerce amounts stored in exact minor units.
- Add money documentation covering construction, parsing, formatting, arithmetic, allocation, validation, and DTO mapping.
- Add `ValidationError.code` for stable machine-readable error codes derived from validation error type names.
- Add focused API docs for email, password, text, number, money, and default validation messages.
- Add broader test coverage for all value objects, validators, default messages, money arithmetic, money parsing, and validator edge cases.

### Changed

- Money and `MoneyAmount` now enforce non-negative minor-unit invariants in release mode instead of relying on asserts.
- Money decimal parsing now rejects excess fractional digits instead of silently truncating them.
- Money precision now consistently comes from `Currency` metadata.
- Currency symbols are stored with correct UTF-8 characters.
- Email domain deny/disposable lists are normalized before comparison.
- Number validation rejects non-finite values and counts decimal places from decimal input text.

## 0.0.4 - 2026-04-23

### Changed

- docs: clarify `gmana_value_objects` as the typed domain-validation layer built on top of `gmana`

## 0.0.3 - 2026-04-19

### Changed

- doc: update README.md documentation

## 0.0.2 - 2026-04-09

### Fixed

- Added extensive dartdoc coverage for public API elements (`Email`, `Password`, `TextValue`, `NumberValue`, validation configs, error hierarchies). This fixes the pub.dev analysis score for missing documentation.

## 0.0.1 - 2026-04-09

### Added

- Initial release
- Email value object with validation
  - RFC 5322 compliant format validation
  - Configurable max lengths for email, local part, and domain
  - Disposable domain detection
  - Custom blocked domains support
- Password value object with validation
  - Configurable min/max length
  - Complexity scoring (uppercase, lowercase, numbers, symbols)
  - Common password detection
  - Sequential character detection
  - ASCII-only enforcement
  - Lenient and strict presets
- Text value object with validation
  - Configurable min/max length
  - Pattern matching support
  - Blacklisted words detection
  - Whitespace handling
  - Allowed characters validation
  - Presets: username, name, shortText, mediumText, longText, alphanumeric
- Number value object with validation
  - Min/max range validation
  - Integer-only enforcement
  - Negative number control
  - Decimal places limiting
  - Presets: positiveInteger, naturalNumber, percentage, price, age, rating
- Core abstractions
  - `ValueObject<T>` base class
  - `ValidationError` base class
- Default English error messages
- Full sealed error hierarchies for type-safe pattern matching
