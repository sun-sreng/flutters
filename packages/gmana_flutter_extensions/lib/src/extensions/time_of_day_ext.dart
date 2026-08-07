// TimeOfDay extension getters.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Arithmetic, comparison, and formatting for [TimeOfDay].
///
/// `TimeOfDay` is a bare hour/minute pair — it has no `compareTo`, no
/// arithmetic, and no way to express a span. These fill that in, treating the
/// value as an offset within a single 24-hour day.
extension TimeOfDayExtensions on TimeOfDay {
  /// Builds a [TimeOfDay] from [minutes] past midnight, wrapping across days.
  ///
  /// ```dart
  /// TimeOfDayExtensions.fromMinutes(90);   // 01:30
  /// TimeOfDayExtensions.fromMinutes(1500); // 01:00 the next day
  /// ```
  static TimeOfDay fromMinutes(int minutes) {
    // Dart's `%` is the Euclidean modulus, so negative inputs already wrap
    // forward into the day rather than producing a negative hour.
    final wrapped = minutes % Duration.minutesPerDay;

    return TimeOfDay(
      hour: wrapped ~/ Duration.minutesPerHour,
      minute: wrapped % Duration.minutesPerHour,
    );
  }

  /// Minutes elapsed since midnight.
  int get inMinutes => hour * Duration.minutesPerHour + minute;

  /// Hours since midnight as a fraction, e.g. `13:30` is `13.5`.
  double get asFractionalHours => inMinutes / Duration.minutesPerHour;

  /// The time expressed as a [Duration] since midnight.
  Duration get sinceMidnight => Duration(minutes: inMinutes);

  /// Whether this is exactly midnight.
  bool get isMidnight => inMinutes == 0;

  /// Whether this is exactly noon.
  bool get isNoon => inMinutes == Duration.minutesPerDay ~/ 2;

  /// `'14:05'` — zero-padded 24-hour form, independent of locale.
  String to24HourString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String toCustomString() {
    final periodText = period == DayPeriod.am ? 'AM' : 'PM';
    final hourText = hourOfPeriod.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');

    return '$hourText:$minuteText $periodText';
  }

  /// Orders two times within the same day. Suitable for `List.sort`.
  int compareTo(TimeOfDay other) => inMinutes.compareTo(other.inMinutes);

  /// Whether this time is earlier in the day than [other].
  bool isBefore(TimeOfDay other) => inMinutes < other.inMinutes;

  /// Whether this time is later in the day than [other].
  bool isAfter(TimeOfDay other) => inMinutes > other.inMinutes;

  /// Whether both times land on the same hour and minute.
  bool isAtSameTimeAs(TimeOfDay other) => inMinutes == other.inMinutes;

  /// Whether this time falls within `[start, end]` inclusive.
  ///
  /// When [end] is earlier than [start] the range is treated as spanning
  /// midnight, so `22:00`–`02:00` correctly contains `23:30`.
  ///
  /// ```dart
  /// const TimeOfDay(hour: 23, minute: 30)
  ///     .isBetween(const TimeOfDay(hour: 22, minute: 0),
  ///                const TimeOfDay(hour: 2, minute: 0)); // true
  /// ```
  bool isBetween(TimeOfDay start, TimeOfDay end) {
    final value = inMinutes;
    final from = start.inMinutes;
    final to = end.inMinutes;

    if (from <= to) return value >= from && value <= to;
    return value >= from || value <= to;
  }

  /// Signed distance from [other] to this time, within one day.
  ///
  /// Positive when this time is later. It does not wrap — use
  /// [durationUntil] for a forward-only span.
  Duration difference(TimeOfDay other) =>
      Duration(minutes: inMinutes - other.inMinutes);

  /// Forward-only span from this time to [other], wrapping past midnight.
  ///
  /// ```dart
  /// const TimeOfDay(hour: 23, minute: 0)
  ///     .durationUntil(const TimeOfDay(hour: 1, minute: 0)); // 2 hours
  /// ```
  Duration durationUntil(TimeOfDay other) {
    final delta = other.inMinutes - inMinutes;
    return Duration(
      minutes: delta >= 0 ? delta : delta + Duration.minutesPerDay,
    );
  }

  /// Adds [minutes], wrapping past midnight.
  TimeOfDay addMinutes(int minutes) => fromMinutes(inMinutes + minutes);

  /// Subtracts [minutes], wrapping past midnight.
  TimeOfDay subtractMinutes(int minutes) => fromMinutes(inMinutes - minutes);

  /// Adds [hours], wrapping past midnight.
  TimeOfDay addHours(int hours) =>
      fromMinutes(inMinutes + hours * Duration.minutesPerHour);

  /// Adds [duration], wrapping past midnight. Sub-minute precision is dropped.
  TimeOfDay add(Duration duration) =>
      fromMinutes(inMinutes + duration.inMinutes);

  /// Rounds to the nearest multiple of [minutes], wrapping past midnight.
  ///
  /// ```dart
  /// const TimeOfDay(hour: 9, minute: 22).roundToNearest(15); // 09:15
  /// ```
  TimeOfDay roundToNearest(int minutes) {
    if (minutes <= 0) {
      throw ArgumentError.value(
        minutes,
        'minutes',
        'must be greater than zero',
      );
    }
    return fromMinutes((inMinutes / minutes).round() * minutes);
  }

  /// Constrains this time to `[min, max]`, comparing within the same day.
  TimeOfDay clampTo(TimeOfDay min, TimeOfDay max) {
    if (min.inMinutes > max.inMinutes) {
      throw ArgumentError.value(
        max,
        'max',
        'must not be earlier in the day than min',
      );
    }
    if (isBefore(min)) return min;
    if (isAfter(max)) return max;
    return this;
  }

  /// Combines this time with the calendar date of [date] (today by default).
  DateTime toDateTime([DateTime? date]) {
    final day = date ?? DateTime.now();
    return DateTime(day.year, day.month, day.day, hour, minute);
  }
}

/// Converts a [DateTime] to its wall-clock time.
extension DateTimeTimeOfDayX on DateTime {
  /// The hour and minute of this moment, discarding the date.
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);
}
