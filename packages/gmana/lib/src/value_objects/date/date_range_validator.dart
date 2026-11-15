import '../../../functional.dart';

import 'date_range.dart';
import 'date_range_validation_issue.dart';

/// Validator for date ranges.
final class DateRangeValidator {
  /// Creates a [DateRangeValidator].
  const DateRangeValidator();

  /// Validates [start] and [end], ensuring `start <= end`.
  Either<DateRangeValidationIssue, DateRange> validate(
    DateTime start,
    DateTime end,
  ) {
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();

    if (startUtc.isAfter(endUtc)) {
      return Left(DateRangeInvalidOrderIssue(start: startUtc, end: endUtc));
    }

    return Right(DateRange(start: startUtc, end: endUtc));
  }
}
