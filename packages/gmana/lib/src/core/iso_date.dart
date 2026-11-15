import 'package:meta/meta.dart';

final RegExp _calendarDatePrefix = RegExp(
  r'^(\d{4})-(\d{2})-(\d{2})(?:$|[Tt\s])',
);

/// Parses an ISO 8601 date or date-time, rejecting impossible calendar values.
///
/// Accepts what [DateTime.tryParse] accepts, except that a leading
/// `yyyy-MM-dd` must name a real calendar day. [DateTime.tryParse] rolls
/// `2024-02-31` into March and `2024-13-01` into the next year; this returns
/// `null` for both. When the input has no zone designator, a time that rolls
/// into another day (`2024-06-15T24:00`) is rejected too.
///
/// The result is what [DateTime.tryParse] returns: UTC when the input carries
/// a zone designator, local otherwise. Surrounding whitespace is ignored.
///
/// This is the one date-string parser in the package: the date predicates and
/// `StringDateX` both build on it.
@internal
DateTime? tryParseIsoDateTime(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return null;

  final match = _calendarDatePrefix.firstMatch(trimmed);
  if (match == null) return parsed;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);

  final calendarDay = DateTime.utc(year, month, day);
  if (calendarDay.year != year ||
      calendarDay.month != month ||
      calendarDay.day != day) {
    return null;
  }

  // Without a zone the result is local and keeps the written wall-clock day,
  // so a difference means the time overflowed into another day. With a zone
  // the result is converted to UTC and may legitimately land on another day.
  if (!parsed.isUtc &&
      (parsed.year != year || parsed.month != month || parsed.day != day)) {
    return null;
  }

  return parsed;
}
