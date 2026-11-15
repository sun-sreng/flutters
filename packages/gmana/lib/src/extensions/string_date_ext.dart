import '../core/iso_date.dart';

/// Date parsing and arithmetic utilities for date strings.
///
/// Assumes ISO 8601 format (`yyyy-MM-dd` or `yyyy-MM-ddTHH:mm:ss`) unless
/// otherwise noted. Use [toDateTimeOrNull] as a guard when input is untrusted.
///
/// ```dart
/// final raw = '2024-03-15';
/// final due = raw.toDateTimeOrNull;
/// if (due != null) {
///   scheduleReminder(due);
/// }
/// ```
extension StringDateX on String {
  /// Day of month, or `null` when this string is not a valid date.
  int? get day => toDateTimeOrNull?.day;

  /// Month number, or `null` when this string is not a valid date.
  int? get month => toDateTimeOrNull?.month;

  /// Parses this string into a [DateTime].
  ///
  /// Throws [FormatException] when the string is not a valid ISO date/time.
  DateTime get toDateTime =>
      toDateTimeOrNull ?? (throw FormatException('Invalid date: "$this"'));

  /// Parses this string into a [DateTime], returning `null` on failure.
  ///
  /// Impossible calendar values are rejected, so `2024-02-31` returns `null`
  /// instead of rolling into March. The result is UTC when the string has a
  /// zone designator and local otherwise.
  DateTime? get toDateTimeOrNull => tryParseIsoDateTime(this);

  /// Formats this date as `yyyy-MM-dd`, or returns `null` when invalid.
  String? get toIsoDateString {
    final date = toDateTimeOrNull;
    return date == null ? null : _formatIsoDate(date);
  }

  /// Weekday number using Dart's convention: Monday is 1 and Sunday is 7.
  int? get weekday => toDateTimeOrNull?.weekday;

  /// Year, or `null` when this string is not a valid date.
  int? get year => toDateTimeOrNull?.year;

  /// Returns an ISO date string after adding [days], or `null` when invalid.
  String? addDays(int days) {
    final date = toDateTimeOrNull;
    return date == null
        ? null
        : _formatIsoDate(DateTime.utc(date.year, date.month, date.day + days));
  }

  /// Difference from [other], or `null` when either value is invalid.
  Duration? differenceFrom(String other) {
    final date = toDateTimeOrNull;
    final reference = other.toDateTimeOrNull;
    return date == null || reference == null
        ? null
        : date.difference(reference);
  }

  /// Whole calendar days from this date until [other].
  ///
  /// Uses only the year/month/day portion, ignoring clock time.
  int? daysUntil(String other) {
    final date = toDateTimeOrNull;
    final reference = other.toDateTimeOrNull;
    if (date == null || reference == null) return null;

    return _dateOnlyUtc(reference).difference(_dateOnlyUtc(date)).inDays;
  }

  /// Returns an ISO date string after subtracting [days], or `null` when invalid.
  String? subtractDays(int days) => addDays(-days);
}

DateTime _dateOnlyUtc(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

String _formatIsoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
