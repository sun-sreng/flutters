# Changelog

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
