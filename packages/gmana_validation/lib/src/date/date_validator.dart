import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_predicates/gmana_predicates.dart' as predicates;

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
      return config.allowEmpty ? const Right(null) : const Left(DateEmptyIssue());
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

    if (config.minDate case final min? when parsedDate.isBefore(min.toUtc())) {
      return Left(DateBeforeMinIssue(min));
    }

    if (config.maxDate case final max? when parsedDate.isAfter(max.toUtc())) {
      return Left(DateAfterMaxIssue(max));
    }

    return Right(parsedDate);
  }
}
