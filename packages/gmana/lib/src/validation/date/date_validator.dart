import '../../../functional.dart';
import '../../../predicates.dart' as predicates;
import '../../core/iso_date.dart';

import '../core/validation_issue.dart';
import 'date_validation_config.dart';
import 'date_validation_issue.dart';

/// Canonical validator for date and time inputs.
final class DateValidator {
  /// Rules used during validation.
  final DateValidationConfig config;

  /// Creates a date validator.
  const DateValidator([this.config = const DateValidationConfig()]);

  /// Validates and normalizes [input] returning parsed UTC [DateTime].
  ValidationResult<DateValidationIssue, DateTime?> validate(String input) {
    final value = config.trimWhitespace ? input.trim() : input;

    if (value.isEmpty) {
      return config.allowEmpty
          ? const Right(null)
          : const Left(DateEmptyIssue());
    }

    if (config.mustBeTime) {
      if (!predicates.isTime(value)) {
        return const Left(DateInvalidTimeIssue());
      }
      return const Right(null);
    }

    final parsedDate = predicates.tryParseDate(value);
    if (parsedDate == null) {
      return const Left(DateInvalidFormatIssue());
    }

    if (config.mustBePast && !predicates.isPast(value)) {
      return const Left(DateNotPastIssue());
    }

    if (config.mustBeFuture && !predicates.isFuture(value)) {
      return const Left(DateNotFutureIssue());
    }

    if (config.mustBeToday && !predicates.isToday(value)) {
      return const Left(DateNotTodayIssue());
    }

    if (config.mustBeWeekday && !predicates.isWeekday(value)) {
      return const Left(DateNotWeekdayIssue());
    }

    if (config.mustBeWeekend && !predicates.isWeekend(value)) {
      return const Left(DateNotWeekendIssue());
    }

    if (config.mustBeLeapYear && !predicates.isLeapYear(value)) {
      return const Left(DateNotLeapYearIssue());
    }

    // A date without a time names a calendar day, not an instant, so it is
    // compared with each bound's own calendar day. Comparing UTC midnight
    // with a local bound would make the answer depend on the timezone.
    final writtenDay =
        _dateOnly.hasMatch(value.trim())
            ? _calendarDay(tryParseIsoDateTime(value)!)
            : null;
    bool before(DateTime bound) =>
        writtenDay != null
            ? writtenDay.isBefore(_calendarDay(bound))
            : parsedDate.isBefore(bound.toUtc());
    bool after(DateTime bound) =>
        writtenDay != null
            ? writtenDay.isAfter(_calendarDay(bound))
            : parsedDate.isAfter(bound.toUtc());

    if (config.minDate case final min? when before(min)) {
      return Left(DateBeforeMinIssue(min));
    }

    if (config.maxDate case final max? when after(max)) {
      return Left(DateAfterMaxIssue(max));
    }

    return Right(parsedDate);
  }
}

final RegExp _dateOnly = RegExp(r'^[+-]?\d{4,6}-?\d\d-?\d\d$');

/// The year, month and day of [date] in its own zone, as a UTC midnight.
DateTime _calendarDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);
