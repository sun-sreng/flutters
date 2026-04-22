/// A powerful extension on [Duration] offering formatting, arithmetic operations,
/// and utility functions.
///
/// Features include:
/// - Human-readable string formatting (e.g. `toHumanizedString`, `toWordString`, `toRelativeString`)
/// - Mathematical operations (`*`, `/`) and bound checking (`clamp`, `abs`)
/// - Convenient component accessors (`hoursPart`, `totalMinutes`)
/// - Progress percentages and rounding calculations
extension HumanizedDuration on Duration {
  // ─── Formatting ────────────────────────────────────────────────────────────

  /// Returns the absolute (non-negative) value of this duration.
  Duration get abs => Duration(microseconds: inMicroseconds.abs());

  /// Returns the absolute hours component of the duration.
  int get hoursPart => inHours.abs();

  /// Returns `true` if this duration is less than zero.
  bool get isNegative => inMicroseconds < 0;

  /// Returns `true` if this duration is greater than zero.
  bool get isPositive => inMicroseconds > 0;

  /// Returns `true` if this duration is exactly zero.
  bool get isZero => inMicroseconds == 0;

  // ─── Arithmetic helpers ────────────────────────────────────────────────────

  /// Returns the absolute milliseconds component of the duration (0-999).
  int get millisecondsPart => (inMilliseconds % 1000).abs();

  /// Returns the absolute minutes component of the duration (0-59).
  int get minutesPart => (inMinutes % 60).abs();

  /// Returns the absolute seconds component of the duration (0-59).
  int get secondsPart => (inSeconds % 60).abs();

  /// Returns the total duration in floating-point days.
  double get totalDays => inMicroseconds / Duration.microsecondsPerDay;

  /// Returns the total duration in floating-point hours.
  double get totalHours => inMicroseconds / Duration.microsecondsPerHour;

  /// Returns the total duration in floating-point minutes.
  double get totalMinutes => inMicroseconds / Duration.microsecondsPerMinute;

  /// Multiplies this duration by the given [factor].
  Duration operator *(num factor) =>
      Duration(microseconds: (inMicroseconds * factor).round());

  // ─── Component accessors ──────────────────────────────────────────────────

  /// Divides this duration by the given [divisor].
  Duration operator /(num divisor) =>
      Duration(microseconds: (inMicroseconds / divisor).round());

  /// Rounds the duration up to the nearest upper minute.
  Duration ceilToMinutes() =>
      Duration(minutes: inSeconds % 60 == 0 ? inMinutes : inMinutes + 1);

  /// Clamps this duration to be between [min] and [max].
  Duration clamp(Duration min, Duration max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Truncates the duration to the nearest lower minute.
  Duration floorToMinutes() => Duration(minutes: inMinutes);

  /// Returns true if this duration is strictly longer than [other].
  bool isLongerThan(Duration other) => this > other;

  /// Returns true if this duration is strictly shorter than [other].
  bool isShorterThan(Duration other) => this < other;

  /// Returns true if this duration is within [range] difference from [other].
  bool isWithin(Duration range, Duration other) =>
      (this - other).abs() <= range;

  // ─── Predicates ───────────────────────────────────────────────────────────

  /// Returns a 0.0–1.0 progress value relative to [total].
  /// Clamps to [0, 1] by default; pass [clampResult] = false to allow overflow.
  double progressOf(Duration total, {bool clampResult = true}) {
    if (total.isZero) return 0.0;
    final ratio = inMicroseconds / total.inMicroseconds;
    return clampResult ? ratio.clamp(0.0, 1.0) : ratio;
  }

  /// Remaining duration when [this] is the elapsed time within [total].
  Duration remainingIn(Duration total) => total - this;

  /// Rounds the duration to the nearest minute.
  Duration roundToMinutes() => Duration(minutes: (inSeconds / 60).round());

  // ─── Progress / percentage ────────────────────────────────────────────────

  /// Rounds the duration to the nearest second.
  Duration roundToSeconds() =>
      Duration(seconds: (inMilliseconds / 1000).round());

  /// Frame count at a given [fps] (e.g. 24, 30, 60).
  int toFrames(double fps) => (inMilliseconds * fps / 1000).round();

  // ─── Rounding / truncating ────────────────────────────────────────────────

  /// `1:02:34` or `2:05` — no forced padding on leading minute
  String toHumanizedString() {
    final abs = this.abs();
    final h = abs.inHours;
    final m = abs.inMinutes % 60;
    final s = abs.inSeconds % 60;
    final mm = '$m'.padLeft(2, '0');
    final ss = '$s'.padLeft(2, '0');
    final body = h > 0 ? '$h:$mm:$ss' : '$m:$ss';
    return isNegative ? '-$body' : body;
  }

  /// `01:02:34` — always zero-pads all components (useful for fixed-width UI)
  String toPaddedString() {
    final abs = this.abs();
    final h = '${abs.inHours}'.padLeft(2, '0');
    final m = '${abs.inMinutes % 60}'.padLeft(2, '0');
    final s = '${abs.inSeconds % 60}'.padLeft(2, '0');
    final body = abs.inHours > 0 ? '$h:$m:$s' : '$m:$s';
    return isNegative ? '-$body' : body;
  }

  /// Approximate relative: `in 2 hours`, `3 minutes ago`, `just now`
  String toRelativeString() {
    final abs = this.abs();

    if (abs.inSeconds < 10) return 'just now';

    final String body;
    if (abs.inDays >= 365) {
      final y = (abs.inDays / 365).round();
      body = '$y ${y == 1 ? 'year' : 'years'}';
    } else if (abs.inDays >= 30) {
      final mo = (abs.inDays / 30).round();
      body = '$mo ${mo == 1 ? 'month' : 'months'}';
    } else if (abs.inDays >= 1) {
      body = '${abs.inDays} ${abs.inDays == 1 ? 'day' : 'days'}';
    } else if (abs.inHours >= 1) {
      body = '${abs.inHours} ${abs.inHours == 1 ? 'hour' : 'hours'}';
    } else if (abs.inMinutes >= 1) {
      body = '${abs.inMinutes} ${abs.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      body = '${abs.inSeconds} seconds';
    }

    return isNegative ? '$body ago' : 'in $body';
  }

  /// Total fractional seconds, including milliseconds.
  double toSeconds() => inMilliseconds / 1000.0;

  // ─── Conversion ───────────────────────────────────────────────────────────

  /// `1h 2m 34s` — verbose, good for settings/accessibility labels
  String toVerboseString({bool includeSeconds = true}) {
    final abs = this.abs();
    final h = abs.inHours;
    final m = abs.inMinutes % 60;
    final s = abs.inSeconds % 60;

    final parts = <String>[
      if (h > 0) '${h}h',
      if (m > 0) '${m}m',
      if (s > 0 && includeSeconds) '${s}s',
    ];

    if (parts.isEmpty) return includeSeconds ? '0s' : '0m';
    final body = parts.join(' ');
    return isNegative ? '-$body' : body;
  }

  /// `1 hour, 2 minutes, 34 seconds` — fully written out
  String toWordString({bool includeSeconds = true}) {
    final abs = this.abs();
    final h = abs.inHours;
    final m = abs.inMinutes % 60;
    final s = abs.inSeconds % 60;

    final parts = <String>[
      if (h > 0) '$h ${h == 1 ? 'hour' : 'hours'}',
      if (m > 0) '$m ${m == 1 ? 'minute' : 'minutes'}',
      if (s > 0 && includeSeconds) '$s ${s == 1 ? 'second' : 'seconds'}',
    ];

    if (parts.isEmpty) return includeSeconds ? '0 seconds' : '0 minutes';
    final body = parts.join(', ');
    return isNegative ? '-$body' : body;
  }

  /// Reconstruct from frame count.
  static Duration fromFrames(int frames, double fps) =>
      Duration(milliseconds: (frames / fps * 1000).round());
}
