import 'package:gmana_functional/gmana_functional.dart';
import 'package:meta/meta.dart';

import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import 'date_range.dart';
import 'date_range_errors.dart';
import 'date_range_validator.dart';

/// Immutable domain value object representing a validated date range.
@immutable
final class DateRangeValue extends ValueObject<DateRange> {
  @override
  final DateRange value;

  const DateRangeValue._(this.value);

  /// Constructs a [DateRangeValue] from trusted [start] and [end] dates.
  /// Throws [ValueObjectException] if `start > end`.
  factory DateRangeValue(DateTime start, DateTime end) {
    return tryParse(start, end).fold(
      (error) => throw ValueObjectException(error),
      (val) => val,
    );
  }

  /// Attempts to parse [start] and [end] into a [DateRangeValue].
  /// Returns `Either<DateRangeError, DateRangeValue>`.
  static Either<DateRangeError, DateRangeValue> tryParse(
    DateTime start,
    DateTime end,
  ) {
    return const DateRangeValidator().validate(start, end).map(DateRangeValue._);
  }
}
