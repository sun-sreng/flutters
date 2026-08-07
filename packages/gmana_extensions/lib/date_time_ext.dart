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
      isUtc ? DateTime.utc(year, month, day) : DateTime(year, month, day);

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
    return startOfWeek(
      firstDayOfWeek: firstDayOfWeek,
    ).add(const Duration(days: 6)).endOfDay;
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

  // --- Calendar facts ---

  /// Number of days in this date's month (leap-year aware).
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// 1-based day of the year (1 through 365 or 366).
  int get dayOfYear =>
      DateTime.utc(year, month, day).difference(DateTime.utc(year)).inDays + 1;

  /// ISO 8601 week number (1 through 53).
  ///
  /// Weeks start on Monday and week 1 is the one containing the first
  /// Thursday of the year.
  int get weekOfYear {
    final date = DateTime.utc(year, month, day);
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final firstOfYear = DateTime.utc(thursday.year);
    return thursday.difference(firstOfYear).inDays ~/ 7 + 1;
  }

  /// Calendar quarter, 1 through 4.
  int get quarter => (month - 1) ~/ 3 + 1;

  /// Whether this moment has already passed.
  bool get isPast => isBefore(DateTime.now());

  /// Whether this moment is still ahead.
  bool get isFuture => isAfter(DateTime.now());

  // --- Boundaries ---

  /// Start of the minute (seconds and below zeroed).
  DateTime get startOfMinute =>
      copyWith(second: 0, millisecond: 0, microsecond: 0);

  /// Start of the hour (minutes and below zeroed).
  DateTime get startOfHour =>
      copyWith(minute: 0, second: 0, millisecond: 0, microsecond: 0);

  /// End of the hour (`:59:59.999999`).
  DateTime get endOfHour =>
      copyWith(minute: 59, second: 59, millisecond: 999, microsecond: 999);

  /// Start of the calendar quarter.
  DateTime get startOfQuarter {
    final firstMonth = (quarter - 1) * 3 + 1;
    return isUtc ? DateTime.utc(year, firstMonth) : DateTime(year, firstMonth);
  }

  /// End of the calendar quarter (last day at `23:59:59.999999`).
  DateTime get endOfQuarter {
    final lastMonth = quarter * 3;
    final lastDay = DateTime(year, lastMonth + 1, 0).day;
    return isUtc
        ? DateTime.utc(year, lastMonth, lastDay, 23, 59, 59, 999, 999)
        : DateTime(year, lastMonth, lastDay, 23, 59, 59, 999, 999);
  }

  /// Start of the year (January 1st at `00:00:00.000000`).
  DateTime get startOfYear => isUtc ? DateTime.utc(year) : DateTime(year);

  /// End of the year (December 31st at `23:59:59.999999`).
  DateTime get endOfYear =>
      isUtc
          ? DateTime.utc(year, 12, 31, 23, 59, 59, 999, 999)
          : DateTime(year, 12, 31, 23, 59, 59, 999, 999);

  // --- Comparison ---

  /// Whether this date shares the same year and month as [other].
  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  /// Whether this date shares the same year as [other].
  bool isSameYear(DateTime other) => year == other.year;

  /// Whether this date falls in the same week as [other].
  bool isSameWeek(DateTime other, {int firstDayOfWeek = DateTime.monday}) =>
      startOfWeek(
        firstDayOfWeek: firstDayOfWeek,
      ).isSameDay(other.startOfWeek(firstDayOfWeek: firstDayOfWeek));

  // --- Calendar arithmetic ---

  /// Adds [months], clamping the day to the target month's length.
  ///
  /// ```dart
  /// DateTime(2024, 1, 31).addMonths(1); // 2024-02-29
  /// ```
  DateTime addMonths(int months) {
    final absoluteMonth = year * 12 + (month - 1) + months;
    final targetYear = (absoluteMonth / 12).floor();
    final targetMonth = absoluteMonth - targetYear * 12 + 1;
    final maxDay = DateTime(targetYear, targetMonth + 1, 0).day;
    return copyWith(
      year: targetYear,
      month: targetMonth,
      day: day < maxDay ? day : maxDay,
    );
  }

  /// Subtracts [months], clamping the day to the target month's length.
  DateTime subtractMonths(int months) => addMonths(-months);

  /// Adds [years], clamping Feb 29 to Feb 28 in non-leap years.
  DateTime addYears(int years) => addMonths(years * 12);

  /// Subtracts [years], clamping Feb 29 to Feb 28 in non-leap years.
  DateTime subtractYears(int years) => addMonths(-years * 12);

  /// Whole calendar days from this date to [other]. Negative when [other]
  /// is earlier.
  ///
  /// Unlike `difference(other).inDays` this ignores the time of day and is
  /// DST-safe.
  int daysUntil(DateTime other) =>
      DateTime.utc(
        other.year,
        other.month,
        other.day,
      ).difference(DateTime.utc(year, month, day)).inDays;

  /// Weekdays (Mon–Fri) between this date and [other], excluding this date
  /// and including [other]. Negative when [other] is earlier.
  int businessDaysUntil(DateTime other) {
    final totalDays = daysUntil(other);
    if (totalDays == 0) return 0;

    final step = totalDays > 0 ? 1 : -1;
    var cursor = startOfDay;
    var count = 0;
    for (var i = 0; i != totalDays; i += step) {
      cursor = cursor.add(Duration(days: step)).startOfDay;
      if (cursor.isWeekday) count += step;
    }
    return count;
  }

  /// Advances by [days] weekdays, skipping weekends.
  ///
  /// ```dart
  /// DateTime(2024, 1, 5).addBusinessDays(1); // Monday 2024-01-08
  /// ```
  DateTime addBusinessDays(int days) {
    if (days == 0) return this;

    final step = days > 0 ? 1 : -1;
    var cursor = this;
    var remaining = days.abs();
    while (remaining > 0) {
      cursor = cursor.add(Duration(days: step));
      if (cursor.isWeekday) remaining--;
    }
    return cursor;
  }

  /// The next occurrence of [weekday] (`DateTime.monday` … `DateTime.sunday`),
  /// always strictly after this date.
  DateTime nextWeekday(int weekday) {
    _checkWeekday(weekday);
    var delta = (weekday - this.weekday) % 7;
    if (delta == 0) delta = 7;
    return startOfDay.add(Duration(days: delta));
  }

  /// The previous occurrence of [weekday], always strictly before this date.
  DateTime previousWeekday(int weekday) {
    _checkWeekday(weekday);
    var delta = (this.weekday - weekday) % 7;
    if (delta == 0) delta = 7;
    return startOfDay.subtract(Duration(days: delta));
  }

  // --- Formatting ---

  /// `yyyy-MM-dd`.
  String toDateString() =>
      '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(day)}';

  /// `HH:mm` or `HH:mm:ss`.
  String toTimeString({bool withSeconds = true}) =>
      withSeconds
          ? '${_two(hour)}:${_two(minute)}:${_two(second)}'
          : '${_two(hour)}:${_two(minute)}';

  /// `yyyy-MM-dd HH:mm:ss`.
  String toDateTimeString({bool withSeconds = true}) =>
      '${toDateString()} ${toTimeString(withSeconds: withSeconds)}';

  /// Coarse relative description such as `'3 days ago'` or `'in an hour'`.
  ///
  /// Pass [clock] to make the result deterministic in tests.
  String toRelativeString({DateTime? clock}) {
    final now = clock ?? DateTime.now();
    final deltaMicroseconds = difference(now).inMicroseconds;
    final elapsed = Duration(microseconds: deltaMicroseconds.abs());

    final phrase = switch (elapsed) {
      _ when elapsed.inSeconds < 45 => 'a few seconds',
      _ when elapsed.inMinutes < 2 => 'a minute',
      _ when elapsed.inMinutes < 60 => '${elapsed.inMinutes} minutes',
      _ when elapsed.inHours < 2 => 'an hour',
      _ when elapsed.inHours < 24 => '${elapsed.inHours} hours',
      _ when elapsed.inDays < 2 => 'a day',
      _ when elapsed.inDays < 30 => '${elapsed.inDays} days',
      _ when elapsed.inDays < 60 => 'a month',
      _ when elapsed.inDays < 365 => '${elapsed.inDays ~/ 30} months',
      _ when elapsed.inDays < 730 => 'a year',
      _ => '${elapsed.inDays ~/ 365} years',
    };

    return deltaMicroseconds >= 0 ? 'in $phrase' : '$phrase ago';
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

  /// `yyyy-MM-dd`, or `null` when this date is null.
  String? get toDateStringOrNull => this?.toDateString();

  /// Returns this date, or [fallback] when null.
  DateTime orDate(DateTime fallback) => this ?? fallback;
}

String _two(int value) => value.toString().padLeft(2, '0');

void _checkWeekday(int weekday) {
  if (weekday < DateTime.monday || weekday > DateTime.sunday) {
    throw ArgumentError.value(
      weekday,
      'weekday',
      'must be between DateTime.monday (1) and DateTime.sunday (7)',
    );
  }
}
