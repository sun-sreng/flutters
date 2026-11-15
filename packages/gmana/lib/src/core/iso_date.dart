import 'package:meta/meta.dart';

/// The grammar [DateTime.parse] accepts, with every field captured so it can
/// be range-checked before [DateTime.tryParse] normalises it.
///
/// Groups: 1 year, 2 month, 3 day, 4 hour, 5 minute, 6 second, 7 zone
/// offset hours, 8 zone offset minutes.
final RegExp _isoDateTime = RegExp(
  r'^([+-]?\d{4,6})-?(\d\d)-?(\d\d)'
  r'(?:[ T](\d\d)(?::?(\d\d)(?::?(\d\d)(?:[.,]\d+)?)?)?'
  r'(?: ?[zZ]| ?[-+](\d\d)(?::?(\d\d))?)?)?$',
);

const List<int> _daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/// Parses an ISO 8601 date or date-time, rejecting impossible values.
///
/// Accepts the same forms as [DateTime.tryParse], including the compact
/// (`20240215T103000Z`) and signed-year (`+002024-02-15`) forms, but every
/// field must be in range: a real calendar day, an hour of 0–23, minutes and
/// seconds of 0–59, and a zone offset of at most 23:59. [DateTime.tryParse]
/// rolls `2024-02-31` into March and `10:75` into `11:15`; this returns
/// `null` for both.
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

  final match = _isoDateTime.firstMatch(trimmed);
  if (match == null) return null;

  final year = int.parse(match[1]!);
  final month = int.parse(match[2]!);
  final day = int.parse(match[3]!);
  if (month < 1 || month > 12) return null;
  if (day < 1 || day > _lastDayOf(year, month)) return null;

  if (!_atMost(match[4], 23) ||
      !_atMost(match[5], 59) ||
      !_atMost(match[6], 59) ||
      !_atMost(match[7], 23) ||
      !_atMost(match[8], 59)) {
    return null;
  }

  return DateTime.tryParse(trimmed);
}

/// Whether the optional two-digit [field] is absent or no more than [max].
bool _atMost(String? field, int max) =>
    field == null || int.parse(field) <= max;

int _lastDayOf(int year, int month) {
  if (month != DateTime.february) return _daysInMonth[month - 1];
  final isLeap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  return isLeap ? 29 : 28;
}
