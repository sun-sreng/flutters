/// Formatting, arithmetic, and utility methods for [Duration].
extension HumanizedDuration on Duration {
  /// Returns the absolute non-negative value of this duration.
  Duration get abs => Duration(microseconds: inMicroseconds.abs());

  /// Waits for this duration.
  Future<void> get delay => Future.delayed(this);

  /// Returns the absolute hours component of the duration.
  int get hoursPart => inHours.abs();

  /// Returns the absolute days component of the duration.
  int get daysPart => inDays.abs();

  /// Returns the absolute milliseconds component of the duration, from 0 to 999.
  int get millisecondsPart => (inMilliseconds % 1000).abs();

  /// Returns the absolute microseconds component of the duration, from 0 to 999.
  int get microsecondsPart => (inMicroseconds % 1000).abs();

  /// Returns the absolute minutes component of the duration, from 0 to 59.
  int get minutesPart => (inMinutes % 60).abs();

  /// Returns the absolute seconds component of the duration, from 0 to 59.
  int get secondsPart => (inSeconds % 60).abs();

  /// Total duration in fractional days.
  double get inDaysDouble => inMicroseconds / Duration.microsecondsPerDay;

  /// Total duration in fractional hours.
  double get inHoursDouble => inMicroseconds / Duration.microsecondsPerHour;

  /// Total duration in fractional milliseconds.
  double get inMillisecondsDouble =>
      inMicroseconds / Duration.microsecondsPerMillisecond;

  /// Total duration in fractional minutes.
  double get inMinutesDouble => inMicroseconds / Duration.microsecondsPerMinute;

  /// Total duration in fractional seconds.
  double get inSecondsDouble => inMicroseconds / Duration.microsecondsPerSecond;

  /// Total duration in fractional weeks.
  double get inWeeksDouble =>
      inMicroseconds / (Duration.microsecondsPerDay * 7);

  /// Returns `true` if this duration is less than zero.
  bool get isNegative => inMicroseconds < 0;

  /// Returns `true` if this duration is greater than zero.
  bool get isPositive => inMicroseconds > 0;

  /// Returns `true` if this duration is exactly zero.
  bool get isZero => inMicroseconds == 0;

  /// Returns -1 for negative, 0 for zero, and 1 for positive durations.
  int get sign => inMicroseconds.compareTo(0);

  /// Returns the total duration in floating-point days.
  double get totalDays => inDaysDouble;

  /// Returns the total duration in floating-point hours.
  double get totalHours => inHoursDouble;

  /// Returns the total duration in floating-point minutes.
  double get totalMinutes => inMinutesDouble;

  /// Multiplies this duration by [factor].
  Duration operator *(num factor) =>
      Duration(microseconds: (inMicroseconds * factor).round());

  /// Divides this duration by [divisor].
  Duration operator /(num divisor) =>
      Duration(microseconds: (inMicroseconds / divisor).round());

  /// Rounds this duration up to the nearest minute.
  Duration ceilToMinutes() =>
      Duration(minutes: inSeconds % 60 == 0 ? inMinutes : inMinutes + 1);

  /// Rounds this duration up to the nearest positive [interval].
  ///
  /// Throws [ArgumentError] when [interval] is zero.
  Duration ceilTo(Duration interval) {
    final step = _positiveIntervalMicroseconds(interval);
    final units = _ceilDiv(inMicroseconds, step);
    return Duration(microseconds: units * step);
  }

  /// Clamps this duration between [min] and [max].
  Duration clamp(Duration min, Duration max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Ensures this duration is at least [min].
  Duration coerceAtLeast(Duration min) => this < min ? min : this;

  /// Ensures this duration is at most [max].
  Duration coerceAtMost(Duration max) => this > max ? max : this;

  /// Runs [callback] after this duration.
  Future<T> delayed<T>(T Function() callback) => Future.delayed(this, callback);

  /// Truncates this duration down to the nearest minute.
  Duration floorToMinutes() => Duration(minutes: inMinutes);

  /// Rounds this duration down to the nearest positive [interval].
  ///
  /// Throws [ArgumentError] when [interval] is zero.
  Duration floorTo(Duration interval) {
    final step = _positiveIntervalMicroseconds(interval);
    final units = _floorDiv(inMicroseconds, step);
    return Duration(microseconds: units * step);
  }

  /// Returns the greater of this duration and [other].
  Duration max(Duration other) => this >= other ? this : other;

  /// Returns the lesser of this duration and [other].
  Duration min(Duration other) => this <= other ? this : other;

  /// Returns `true` when this duration is between [min] and [max].
  ///
  /// Boundaries are included by default. Pass [inclusive] as false to make the
  /// check strict.
  bool isBetween(Duration min, Duration max, {bool inclusive = true}) {
    if (min > max) {
      throw ArgumentError.value(
        max,
        'max',
        'must be greater than or equal to min',
      );
    }

    return inclusive ? this >= min && this <= max : this > min && this < max;
  }

  /// Returns `true` if this duration is strictly longer than [other].
  bool isLongerThan(Duration other) => this > other;

  /// Returns `true` if this duration is strictly shorter than [other].
  bool isShorterThan(Duration other) => this < other;

  /// Returns `true` if this duration is within [range] of [other].
  bool isWithin(Duration range, Duration other) =>
      (this - other).abs() <= range;

  /// Returns a 0.0-1.0 progress value relative to [total].
  ///
  /// Pass [clampResult] as false to allow values outside the 0-1 range.
  double progressOf(Duration total, {bool clampResult = true}) {
    if (total.isZero) return 0.0;
    final ratio = inMicroseconds / total.inMicroseconds;
    return clampResult ? ratio.clamp(0.0, 1.0) : ratio;
  }

  /// Returns a 0.0-100.0 percent value relative to [total].
  ///
  /// Pass [clampResult] as false to allow values outside the 0-100 range.
  double percentOf(Duration total, {bool clampResult = true}) =>
      progressOf(total, clampResult: clampResult) * 100;

  /// Remaining duration when this duration is elapsed within [total].
  Duration remainingIn(Duration total) => total - this;

  /// Rounds this duration to the nearest positive [interval].
  ///
  /// Throws [ArgumentError] when [interval] is zero.
  Duration roundTo(Duration interval) {
    final step = _positiveIntervalMicroseconds(interval);
    final units = (inMicroseconds / step).round();
    return Duration(microseconds: units * step);
  }

  /// Rounds this duration to the nearest minute.
  Duration roundToMinutes() => Duration(minutes: (inSeconds / 60).round());

  /// Rounds this duration to the nearest second.
  Duration roundToSeconds() =>
      Duration(seconds: (inMilliseconds / 1000).round());

  /// Converts this duration to a frame count at [fps].
  int toFrames(double fps) => (inMilliseconds * fps / 1000).round();

  /// Formats this duration as ISO-8601 duration text, such as `PT1H2M3S`.
  ///
  /// Negative durations are prefixed with `-`, for example `-PT30S`.
  String toIso8601String() {
    final absolute = Duration(microseconds: inMicroseconds.abs());
    if (absolute == Duration.zero) return 'PT0S';

    final days = absolute.inDays;
    final hours = absolute.inHours % 24;
    final minutes = absolute.inMinutes % 60;
    final seconds = absolute.inSeconds % 60;
    final microseconds =
        absolute.inMicroseconds % Duration.microsecondsPerSecond;

    final buffer = StringBuffer();
    if (isNegative) buffer.write('-');
    buffer.write('P');
    if (days > 0) buffer.write('${days}D');

    if (hours > 0 ||
        minutes > 0 ||
        seconds > 0 ||
        microseconds > 0 ||
        days == 0) {
      buffer.write('T');
      if (hours > 0) buffer.write('${hours}H');
      if (minutes > 0) buffer.write('${minutes}M');
      if (seconds > 0 || microseconds > 0) {
        if (microseconds == 0) {
          buffer.write('${seconds}S');
        } else {
          final fraction = microseconds
              .toString()
              .padLeft(6, '0')
              .replaceFirst(RegExp(r'0+$'), '');
          buffer.write('$seconds.${fraction}S');
        }
      }
    }

    return buffer.toString();
  }

  /// Formats this duration as `HH:MM:SS` or `MM:SS`.
  String toHHMMSS() {
    final h = inHours.abs();
    final m = inMinutes.abs().remainder(60);
    final s = inSeconds.abs().remainder(60);
    final hh = h > 0 ? '${h.toString().padLeft(2, '0')}:' : '';
    return '$hh${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Formats this duration as compact human-readable text.
  String toHuman() {
    if (inMicroseconds.abs() < Duration.microsecondsPerMillisecond) {
      return '${inMicroseconds.abs()}us';
    }
    if (inMilliseconds.abs() < Duration.millisecondsPerSecond) {
      return '${inMillisecondsDouble.abs().toStringAsFixed(0)}ms';
    }
    if (inSeconds.abs() < Duration.secondsPerMinute) {
      return '${inSecondsDouble.abs().toStringAsFixed(1)}s';
    }
    if (inMinutes.abs() < Duration.minutesPerHour) {
      return '${inMinutes.abs()}m ${inSeconds.abs().remainder(60)}s';
    }
    if (inHours.abs() < Duration.hoursPerDay) {
      return '${inHours.abs()}h ${inMinutes.abs().remainder(60)}m';
    }
    return '${inDaysDouble.abs().toStringAsFixed(1)}d';
  }

  /// Formats this duration as `1:02:34` or `2:05`.
  String toHumanizedString() {
    final absolute = Duration(microseconds: inMicroseconds.abs());
    final h = absolute.inHours;
    final m = absolute.inMinutes % 60;
    final s = absolute.inSeconds % 60;
    final mm = '$m'.padLeft(2, '0');
    final ss = '$s'.padLeft(2, '0');
    final body = h > 0 ? '$h:$mm:$ss' : '$m:$ss';
    return isNegative ? '-$body' : body;
  }

  /// Formats this duration as `01:02:34` or `02:05`.
  String toPaddedString() {
    final absolute = Duration(microseconds: inMicroseconds.abs());
    final h = '${absolute.inHours}'.padLeft(2, '0');
    final m = '${absolute.inMinutes % 60}'.padLeft(2, '0');
    final s = '${absolute.inSeconds % 60}'.padLeft(2, '0');
    final body = absolute.inHours > 0 ? '$h:$m:$s' : '$m:$s';
    return isNegative ? '-$body' : body;
  }

  /// Formats this duration as relative text.
  String toRelativeString() {
    final absolute = Duration(microseconds: inMicroseconds.abs());

    if (absolute.inSeconds < 10) return 'just now';

    final String body;
    if (absolute.inDays >= 365) {
      final years = (absolute.inDays / 365).round();
      body = '$years ${years == 1 ? 'year' : 'years'}';
    } else if (absolute.inDays >= 30) {
      final months = (absolute.inDays / 30).round();
      body = '$months ${months == 1 ? 'month' : 'months'}';
    } else if (absolute.inDays >= 1) {
      body = '${absolute.inDays} ${absolute.inDays == 1 ? 'day' : 'days'}';
    } else if (absolute.inHours >= 1) {
      body = '${absolute.inHours} ${absolute.inHours == 1 ? 'hour' : 'hours'}';
    } else if (absolute.inMinutes >= 1) {
      body =
          '${absolute.inMinutes} ${absolute.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      body = '${absolute.inSeconds} seconds';
    }

    return isNegative ? '$body ago' : 'in $body';
  }

  /// Total fractional seconds, including milliseconds.
  double toSeconds() => inMilliseconds / 1000.0;

  /// Formats this duration as compact parts such as `1h 2m 34s`.
  String toVerboseString({bool includeSeconds = true}) {
    final absolute = Duration(microseconds: inMicroseconds.abs());
    final h = absolute.inHours;
    final m = absolute.inMinutes % 60;
    final s = absolute.inSeconds % 60;

    final parts = <String>[
      if (h > 0) '${h}h',
      if (m > 0) '${m}m',
      if (s > 0 && includeSeconds) '${s}s',
    ];

    if (parts.isEmpty) return includeSeconds ? '0s' : '0m';
    final body = parts.join(' ');
    return isNegative ? '-$body' : body;
  }

  /// Formats this duration with fully written-out units.
  String toWordString({bool includeSeconds = true}) {
    final absolute = Duration(microseconds: inMicroseconds.abs());
    final h = absolute.inHours;
    final m = absolute.inMinutes % 60;
    final s = absolute.inSeconds % 60;

    final parts = <String>[
      if (h > 0) '$h ${h == 1 ? 'hour' : 'hours'}',
      if (m > 0) '$m ${m == 1 ? 'minute' : 'minutes'}',
      if (s > 0 && includeSeconds) '$s ${s == 1 ? 'second' : 'seconds'}',
    ];

    if (parts.isEmpty) return includeSeconds ? '0 seconds' : '0 minutes';
    final body = parts.join(', ');
    return isNegative ? '-$body' : body;
  }

  /// Reconstructs a duration from [frames] at [fps].
  static Duration fromFrames(int frames, double fps) =>
      Duration(milliseconds: (frames / fps * 1000).round());
}

int _positiveIntervalMicroseconds(Duration interval) {
  final step = interval.inMicroseconds.abs();
  if (step == 0) {
    throw ArgumentError.value(interval, 'interval', 'must not be zero');
  }
  return step;
}

int _floorDiv(int value, int divisor) {
  final truncated = value ~/ divisor;
  return value >= 0 || value % divisor == 0 ? truncated : truncated - 1;
}

int _ceilDiv(int value, int divisor) => -_floorDiv(-value, divisor);
