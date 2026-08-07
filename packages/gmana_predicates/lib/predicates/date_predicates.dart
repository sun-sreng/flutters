/// Parses [str] as a UTC [DateTime], returning `null` on failure.
///
/// Accepts ISO 8601 formats supported by [DateTime.tryParse].
DateTime? tryParseDate(String str) => DateTime.tryParse(str.trim())?.toUtc();

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

