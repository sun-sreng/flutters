import '../core/validation_error.dart';

/// Base class for date range validation errors.
sealed class DateRangeError extends ValidationError {
  /// Internal constructor for [DateRangeError].
  const DateRangeError();
}

/// Error indicating that start date is after end date.
final class DateRangeInvalidOrder extends DateRangeError {
  /// Provided start date.
  final DateTime start;

  /// Provided end date.
  final DateTime end;

  /// Creates a [DateRangeInvalidOrder] error.
  const DateRangeInvalidOrder({required this.start, required this.end});
}
