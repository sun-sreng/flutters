/// Creates [Duration] values from numbers, such as `5.seconds`.
extension NumDurationExtension on num {
  /// Returns a duration in days.
  Duration get day => days;

  /// Returns a duration in days.
  Duration get days => (this * Duration.microsecondsPerDay).microseconds;

  /// Returns a duration in fortnights (14 days).
  Duration get fortnight => fortnights;

  /// Returns a duration in fortnights (14 days).
  Duration get fortnights =>
      (this * Duration.microsecondsPerDay * 14).microseconds;

  /// Returns a duration in hours.
  Duration get hour => hours;

  /// Returns a duration in hours.
  Duration get hours => (this * Duration.microsecondsPerHour).microseconds;

  /// Returns a duration in microseconds.
  Duration get microsecond => microseconds;

  /// Returns a duration in microseconds.
  Duration get microseconds => Duration(microseconds: round());

  /// Returns a duration in microseconds.
  Duration get micros => microseconds;

  /// Returns a duration in milliseconds.
  Duration get millisecond => milliseconds;

  /// Returns a duration in milliseconds.
  Duration get milliseconds =>
      (this * Duration.microsecondsPerMillisecond).microseconds;

  /// Returns a duration in milliseconds.
  Duration get millis => milliseconds;

  /// Returns a duration in minutes.
  Duration get minute => minutes;

  /// Returns a duration in minutes.
  Duration get minutes => (this * Duration.microsecondsPerMinute).microseconds;

  /// Returns a duration in milliseconds.
  Duration get ms => milliseconds;

  /// Returns a duration in nanoseconds, rounded to the nearest microsecond.
  Duration get nanosecond => nanoseconds;

  /// Returns a duration in nanoseconds, rounded to the nearest microsecond.
  Duration get nanoseconds => (this / 1000).microseconds;

  /// Returns a duration in seconds.
  Duration get second => seconds;

  /// Returns a duration in seconds.
  Duration get seconds => (this * Duration.microsecondsPerSecond).microseconds;

  /// Returns a duration in seconds.
  Duration get sec => seconds;

  /// Returns a duration in seconds.
  Duration get secs => seconds;

  /// Returns a duration in microseconds.
  Duration get us => microseconds;

  /// Returns a duration in weeks.
  Duration get week => weeks;

  /// Returns a duration in weeks.
  Duration get weeks => (this * Duration.microsecondsPerDay * 7).microseconds;

  /// Converts a frame count into a duration at [fps].
  ///
  /// ```dart
  /// 120.framesAt(24); // Duration(seconds: 5)
  /// ```
  Duration framesAt(num fps) {
    if (fps <= 0) {
      throw ArgumentError.value(fps, 'fps', 'must be greater than zero');
    }

    return (this / fps).seconds;
  }
}
