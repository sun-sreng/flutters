import 'package:gmana_predicates/predicates/date_predicates.dart' as dates;

/// Date validation and comparison utilities for date strings.
///
/// Assumes ISO 8601 format (`yyyy-MM-dd` or `yyyy-MM-ddTHH:mm:ss`) unless
/// otherwise noted. Behavior with non-date strings is undefined — guard with
/// [isDate] first when input is untrusted.
///
/// ```dart
/// final raw = '2024-03-15';
/// if (raw.isDate && raw.isFuture) {
///   scheduleReminder(raw);
/// }
/// ```
extension StringDateExtension on String {
  /// Day of month, or `null` when this string is not a valid date.
  int? get day => toDateTimeOrNull?.day;

  /// Whether this string is a recognizable date value.
  ///
  /// Returns `true` for valid ISO 8601 date strings. Use this as a guard
  /// before calling other date utilities on untrusted input.
  bool get isDate => dates.isDate(this);

  /// Whether this date is after [reference].
  ///
  /// When [reference] is omitted, compares against the current date/time (now).
  bool isAfter([String? reference]) => dates.isAfter(this, reference);

  /// Whether this date is before [reference].
  ///
  /// When [reference] is omitted, compares against the current date/time (now).
  bool isBefore([String? reference]) => dates.isBefore(this, reference);

  /// Whether this date falls within the range [[from], [to]] exclusively.
  bool isBetween(String from, String to) => dates.isBetween(this, from, to);

  /// Whether this date represents today's date (UTC).
  bool get isToday => dates.isToday(this);

  /// Whether this date is strictly before today.
  bool get isPast => dates.isPast(this);

  /// Whether this date is strictly after today.
  bool get isFuture => dates.isFuture(this);

  /// Whether this date falls on a Saturday or Sunday.
  bool get isWeekend => dates.isWeekend(this);

  /// Whether this date falls on a Monday through Friday.
  bool get isWeekday => dates.isWeekday(this);

  /// Whether the year of this date is a leap year.
  bool get isLeapYear => dates.isLeapYear(this);

  /// Month number, or `null` when this string is not a valid date.
  int? get month => toDateTimeOrNull?.month;

  /// Parses this string into a [DateTime].
  ///
  /// Throws [FormatException] when the string is not a valid ISO date/time.
  DateTime get toDateTime =>
      toDateTimeOrNull ?? (throw FormatException('Invalid date: "$this"'));

  /// Parses this string into a [DateTime], returning `null` on failure.
  ///
  /// Date-only strings are validated strictly, so `2024-02-31` returns `null`
  /// instead of rolling into March.
  DateTime? get toDateTimeOrNull => _parseStrictDateTime(this);

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
    return date == null ? null : _formatIsoDate(date.add(Duration(days: days)));
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

  /// Whether this date falls within the range [[from], [to]] inclusively.
  bool isBetweenInclusive(String from, String to) {
    final date = toDateTimeOrNull;
    final start = from.toDateTimeOrNull;
    final end = to.toDateTimeOrNull;
    if (date == null || start == null || end == null || start.isAfter(end)) {
      return false;
    }

    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Whether this date has the same calendar day as [other].
  bool isSameDayAs(String other) {
    final date = toDateTimeOrNull;
    final reference = other.toDateTimeOrNull;
    if (date == null || reference == null) return false;

    return date.year == reference.year &&
        date.month == reference.month &&
        date.day == reference.day;
  }

  /// Returns an ISO date string after subtracting [days], or `null` when invalid.
  String? subtractDays(int days) => addDays(-days);
}

DateTime? _parseStrictDateTime(String value) {
  final input = value.trim();
  if (input.isEmpty) return null;

  final parsed = DateTime.tryParse(input);
  if (parsed == null) return null;

  final match = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})(?:$|[T\s])',
  ).firstMatch(input);
  if (match == null) return parsed;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }

  return parsed;
}

DateTime _dateOnlyUtc(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

String _formatIsoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
