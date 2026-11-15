/// Configuration options for date and time validation.
final class DateValidationConfig {
  /// Whether an empty string is considered valid.
  final bool allowEmpty;

  /// Whether input should be trimmed before parsing.
  final bool trimWhitespace;

  /// Requires parsed date to be strictly in the past.
  final bool mustBePast;

  /// Requires parsed date to be strictly in the future.
  final bool mustBeFuture;

  /// Requires parsed date to match today's UTC date.
  final bool mustBeToday;

  /// Requires parsed date to fall on a weekday (Monday–Friday).
  final bool mustBeWeekday;

  /// Requires parsed date to fall on a weekend (Saturday/Sunday).
  final bool mustBeWeekend;

  /// Requires parsed date to be in a leap year.
  final bool mustBeLeapYear;

  /// Requires input to match 24-hour time format (`HH:mm` or `HH:mm:ss`).
  final bool mustBeTime;

  /// Minimum allowable UTC DateTime.
  final DateTime? minDate;

  /// Maximum allowable UTC DateTime.
  final DateTime? maxDate;

  /// Creates a [DateValidationConfig].
  const DateValidationConfig({
    this.allowEmpty = false,
    this.trimWhitespace = true,
    this.mustBePast = false,
    this.mustBeFuture = false,
    this.mustBeToday = false,
    this.mustBeWeekday = false,
    this.mustBeWeekend = false,
    this.mustBeLeapYear = false,
    this.mustBeTime = false,
    this.minDate,
    this.maxDate,
  });
}
