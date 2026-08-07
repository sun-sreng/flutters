import 'package:gmana_functional/gmana_functional.dart';

import 'date_range.dart';
import 'date_range_errors.dart';

/// Validator for date ranges.
final class DateRangeValidator {
  /// Creates a [DateRangeValidator].
  const DateRangeValidator();

  /// Validates [start] and [end], ensuring `start <= end`.
  Either<DateRangeError, DateRange> validate(DateTime start, DateTime end) {
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();

    if (startUtc.isAfter(endUtc)) {
      return Left(DateRangeInvalidOrder(start: startUtc, end: endUtc));
    }

    return Right(DateRange(start: startUtc, end: endUtc));
  }
}
