import 'package:meta/meta.dart';

/// Immutable representation of a validated date range with start and end UTC DateTimes.
@immutable
final class DateRange {
  /// Start of the range in UTC.
  final DateTime start;

  /// End of the range in UTC.
  final DateTime end;

  /// Creates a [DateRange].
  DateRange({required DateTime start, required DateTime end})
      : start = start.toUtc(),
        end = end.toUtc();

  /// Duration spanned by this date range.
  Duration get duration => end.difference(start);

  /// Returns `true` if [dateTime] falls within this range (inclusive).
  bool contains(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return (utc.isAfter(start) || utc.isAtSameMomentAs(start)) &&
        (utc.isBefore(end) || utc.isAtSameMomentAs(end));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start to $end)';
}
