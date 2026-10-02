final _dateOnlyReg = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// Parses [str] as a UTC [DateTime], returning `null` on failure.
///
/// Accepts ISO 8601 formats supported by [DateTime.tryParse].
///
/// A string carrying no time and no zone — `2024-06-15` — names a calendar
/// day, so it is read as UTC midnight. [DateTime.tryParse] would otherwise
/// read it as *local* midnight, and the `toUtc()` that follows would shift the
/// day by the machine's offset: east of Greenwich `2024-06-15` would come back
/// as the 14th, making every predicate here answer differently per timezone.
/// A value that does carry a time but no zone is still local, since a wall
/// clock reading without a zone is a local one.
DateTime? tryParseDate(String str) {
  final trimmed = str.trim();
  final normalized =
      _dateOnlyReg.hasMatch(trimmed) ? '${trimmed}T00:00:00Z' : trimmed;
  return DateTime.tryParse(normalized)?.toUtc();
}

/// Returns `true` if [str] is a parseable date string.
bool isDate(String str) => tryParseDate(str) != null;

/// Returns `true` if [str] represents a date after [reference].
///
/// When [reference] is omitted the current UTC time is used.
bool isAfter(String str, [String? reference]) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final ref =
      reference == null ? DateTime.now().toUtc() : tryParseDate(reference);
  if (ref == null) return false;
  return date.isAfter(ref);
}

/// Returns `true` if [str] represents a date before [reference].
///
/// When [reference] is omitted the current UTC time is used.
bool isBefore(String str, [String? reference]) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final ref =
      reference == null ? DateTime.now().toUtc() : tryParseDate(reference);
  if (ref == null) return false;
  return date.isBefore(ref);
}

/// Returns `true` if [str] represents a date strictly between [from] and [to].
///
/// The bounds are exclusive — see [isBetweenInclusive] when a date equal to a
/// bound should pass.
bool isBetween(String str, String from, String to) {
  final date = tryParseDate(str);
  final f = tryParseDate(from);
  final t = tryParseDate(to);
  if (date == null || f == null || t == null) return false;
  return date.isAfter(f) && date.isBefore(t);
}

/// Returns `true` if [str] represents today's UTC date.
bool isToday(String str) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final now = DateTime.now().toUtc();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

/// Returns `true` if [str] represents a date in the past.
bool isPast(String str) => isBefore(str);

/// Returns `true` if [str] represents a date in the future.
bool isFuture(String str) => isAfter(str);

/// Returns `true` if [str] represents a Saturday or Sunday.
bool isWeekend(String str) {
  final date = tryParseDate(str);
  if (date == null) return false;
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

/// Returns `true` if [str] represents a Monday–Friday.
bool isWeekday(String str) {
  final date = tryParseDate(str);
  if (date == null) return false;
  return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
}

/// Returns `true` if [str] represents a date in a leap year.
bool isLeapYear(String str) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final y = date.year;
  return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
}

/// Returns `true` if [str] matches 24-hour time format (`HH:mm` or `HH:mm:ss`).
bool isTime(String str) {
  final timeRegExp = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$');
  return timeRegExp.hasMatch(str.trim());
}

/// Returns `true` if [date1] and [date2] represent the same UTC calendar day.
bool isSameDay(String date1, String date2) {
  final d1 = tryParseDate(date1);
  final d2 = tryParseDate(date2);
  if (d1 == null || d2 == null) return false;
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

/// Returns `true` if [date1] and [date2] represent the same UTC year and month.
bool isSameMonth(String date1, String date2) {
  final d1 = tryParseDate(date1);
  final d2 = tryParseDate(date2);
  if (d1 == null || d2 == null) return false;
  return d1.year == d2.year && d1.month == d2.month;
}

/// Returns `true` if [date1] and [date2] represent the same UTC year.
bool isSameYear(String date1, String date2) {
  final d1 = tryParseDate(date1);
  final d2 = tryParseDate(date2);
  if (d1 == null || d2 == null) return false;
  return d1.year == d2.year;
}

/// Returns `true` if [str] falls between [from] and [to], bounds included.
///
/// The inclusive counterpart of [isBetween]. Returns `false` if any of the
/// three strings fails to parse.
bool isBetweenInclusive(String str, String from, String to) {
  final date = tryParseDate(str);
  final f = tryParseDate(from);
  final t = tryParseDate(to);
  if (date == null || f == null || t == null) return false;
  return !date.isBefore(f) && !date.isAfter(t);
}

/// Returns `true` if [str] represents yesterday's UTC date.
bool isYesterday(String str) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final target = DateTime.now().toUtc().subtract(const Duration(days: 1));
  return date.year == target.year &&
      date.month == target.month &&
      date.day == target.day;
}

/// Returns `true` if [str] represents tomorrow's UTC date.
bool isTomorrow(String str) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final target = DateTime.now().toUtc().add(const Duration(days: 1));
  return date.year == target.year &&
      date.month == target.month &&
      date.day == target.day;
}

/// Returns `true` if [date1] and [date2] fall in the same Monday-start week.
///
/// Weeks are compared by their Monday, so dates in different months or years
/// can still share a week.
bool isSameWeek(String date1, String date2) {
  final d1 = tryParseDate(date1);
  final d2 = tryParseDate(date2);
  if (d1 == null || d2 == null) return false;
  final m1 = _mondayOf(d1);
  final m2 = _mondayOf(d2);
  return m1 == m2;
}

/// Returns `true` if [str] is in the past and no older than [duration].
///
/// A date in the future returns `false`.
///
/// ```dart
/// isWithinLast(signupDate, const Duration(days: 30));
/// ```
bool isWithinLast(String str, Duration duration) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final now = DateTime.now().toUtc();
  return !date.isAfter(now) && date.isAfter(now.subtract(duration));
}

/// Returns `true` if [str] is in the future and no further off than [duration].
///
/// A date in the past returns `false`.
bool isWithinNext(String str, Duration duration) {
  final date = tryParseDate(str);
  if (date == null) return false;
  final now = DateTime.now().toUtc();
  return !date.isBefore(now) && date.isBefore(now.add(duration));
}

/// Returns `true` if [str] is the first day of its month.
bool isStartOfMonth(String str) {
  final date = tryParseDate(str);
  return date != null && date.day == 1;
}

/// Returns `true` if [str] is the last day of its month.
bool isEndOfMonth(String str) {
  final date = tryParseDate(str);
  if (date == null) return false;
  return date.day == DateTime.utc(date.year, date.month + 1, 0).day;
}

/// Returns `true` if a birth date of [str] means an age of at least [years]
/// as of today (UTC).
///
/// The birthday itself counts, so someone born exactly [years] ago passes.
/// A birth date in the future returns `false`.
///
/// ```dart
/// isAgeAtLeast('2000-01-01', 18);  // true
/// ```
bool isAgeAtLeast(String str, int years) {
  final birth = tryParseDate(str);
  if (birth == null) return false;
  final now = DateTime.now().toUtc();
  if (birth.isAfter(now)) return false;
  var age = now.year - birth.year;
  final hadBirthday =
      now.month > birth.month ||
      (now.month == birth.month && now.day >= birth.day);
  if (!hadBirthday) age--;
  return age >= years;
}

/// Returns `true` if [str] is a full ISO 8601 date or date-time.
///
/// Stricter than [isDate] in two ways: the space-separated form
/// `2024-06-15 10:00:00` that [DateTime.tryParse] tolerates is rejected, and
/// so is an out-of-range component. [DateTime.tryParse] silently rolls those
/// over — `2024-13-01` becomes January 2025 and `2023-02-29` becomes March —
/// whereas this returns `false`.
bool isIso8601(String str) {
  final trimmed = str.trim();
  final match = _iso8601Reg.firstMatch(trimmed);
  if (match == null) return false;
  if (DateTime.tryParse(trimmed) == null) return false;

  // Reject rolled-over dates by checking the calendar day survives a
  // round-trip through DateTime.utc.
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final probe = DateTime.utc(year, month, day);
  return probe.year == year && probe.month == month && probe.day == day;
}

final _iso8601Reg = RegExp(
  r'^(\d{4})-(\d{2})-(\d{2})'
  r'(?:T\d{2}:\d{2}(?::\d{2}(?:\.\d+)?)?(?:Z|[+-]\d{2}:?\d{2})?)?$',
);

DateTime _mondayOf(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}
