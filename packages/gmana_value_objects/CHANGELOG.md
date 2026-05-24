# Changelog

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
