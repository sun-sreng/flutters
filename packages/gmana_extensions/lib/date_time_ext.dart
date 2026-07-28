/// Utilities and convenience getters for [DateTime] objects.
extension DateTimeX on DateTime {
  /// Whether this date falls on today's calendar date.
  bool get isToday => isSameDay(DateTime.now());

  /// Whether this date fell on yesterday's calendar date.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// Whether this date falls on tomorrow's calendar date.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }

  /// Whether the year of this date is a leap year.
  bool get isLeapYear =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  /// Whether this date falls on a Saturday or Sunday.
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Whether this date falls on a Monday through Friday.
  bool get isWeekday => !isWeekend;

  /// Returns the start of the calendar day (00:00:00.000000).
  DateTime get startOfDay =>
      isUtc
          ? DateTime.utc(year, month, day)
          : DateTime(year, month, day);

  /// Returns the end of the calendar day (23:59:59.999999).
  DateTime get endOfDay =>
      isUtc
          ? DateTime.utc(year, month, day, 23, 59, 59, 999, 999)
          : DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// Returns the start of the month (1st day at 00:00:00.000000).
  DateTime get startOfMonth =>
      isUtc ? DateTime.utc(year, month, 1) : DateTime(year, month, 1);

  /// Returns the end of the month (last day at 23:59:59.999999).
  DateTime get endOfMonth {
    final lastDay = DateTime(year, month + 1, 0).day;
    return isUtc
        ? DateTime.utc(year, month, lastDay, 23, 59, 59, 999, 999)
        : DateTime(year, month, lastDay, 23, 59, 59, 999, 999);
  }

  /// Returns the start of the week given a starting weekday (default Monday).
  DateTime startOfWeek({int firstDayOfWeek = DateTime.monday}) {
    var daysToSubtract = weekday - firstDayOfWeek;
    if (daysToSubtract < 0) daysToSubtract += 7;
    final date = subtract(Duration(days: daysToSubtract));
    return date.startOfDay;
  }

  /// Returns the end of the week given a starting weekday (default Monday).
  DateTime endOfWeek({int firstDayOfWeek = DateTime.monday}) {
    return startOfWeek(firstDayOfWeek: firstDayOfWeek)
        .add(const Duration(days: 6))
        .endOfDay;
  }

  /// Returns the next calendar day at 00:00:00.
  DateTime get nextDay => startOfDay.add(const Duration(days: 1));

  /// Returns the previous calendar day at 00:00:00.
  DateTime get previousDay => startOfDay.subtract(const Duration(days: 1));

  /// Checks if this date has the same year, month, and day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Calculates age in complete years relative to [at] (defaults to now).
  int age({DateTime? at}) {
    final reference = at ?? DateTime.now();
    var years = reference.year - year;
    if (reference.month < month ||
        (reference.month == month && reference.day < day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  /// Returns a new [DateTime] with updated components.
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
    bool? isUtc,
  }) {
    final utc = isUtc ?? this.isUtc;
    if (utc) {
      return DateTime.utc(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );
    } else {
      return DateTime(
        year ?? this.year,
        month ?? this.month,
        day ?? this.day,
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
        millisecond ?? this.millisecond,
        microsecond ?? this.microsecond,
      );
    }
  }
}

/// Extension on nullable [DateTime] values.
extension DateTimeNullableX on DateTime? {
  /// Returns `this` or [DateTime.now()] if null.
  DateTime get orNow => this ?? DateTime.now();

  /// Returns `true` if both dates are non-null and fall on the same calendar day.
  bool isSameDayAs(DateTime? other) {
    if (this == null || other == null) return false;
    return this!.isSameDay(other);
  }
}
