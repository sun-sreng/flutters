/// Creates [Duration] values from numbers, such as `5.seconds`.
extension NumDurationExtension on num {
  /// Returns a duration in days.
  Duration get days => (this * Duration.microsecondsPerDay).microseconds;

  /// Returns a duration in hours.
  Duration get hours => (this * Duration.microsecondsPerHour).microseconds;

  /// Returns a duration in microseconds.
  Duration get microseconds => Duration(microseconds: round());

  /// Returns a duration in milliseconds.
  Duration get milliseconds => (this * Duration.microsecondsPerMillisecond).microseconds;

  /// Returns a duration in minutes.
  Duration get minutes => (this * Duration.microsecondsPerMinute).microseconds;

  /// Returns a duration in milliseconds.
  Duration get ms => milliseconds;

  /// Returns a duration in seconds.
  Duration get seconds => (this * Duration.microsecondsPerSecond).microseconds;

  /// Returns a duration in weeks.
  Duration get weeks => (this * Duration.microsecondsPerDay * 7).microseconds;
}
