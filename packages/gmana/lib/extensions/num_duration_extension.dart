/// A suite of utilities and overrides extending [Duration] to support arithmetic,
/// accurate double conversions, and standardized string formatting features.
extension DurationX on Duration {
  // ── Arithmetic ──────────────────────────────────────────────────────────

  /// Computes the absolute value of the duration.
  Duration get abs => Duration(microseconds: inMicroseconds.abs());

  /// `await 3.seconds.delay` — reads naturally in async code.
  Future<void> get delay => Future.delayed(this);

  // ── Unit accessors (double, not truncated) ───────────────────────────────

  /// Total duration in fractional days.
  double get inDaysDouble => inMicroseconds / (1000000 * 60 * 60 * 24);

  /// Total duration in fractional hours.
  double get inHoursDouble => inMicroseconds / (1000000 * 60 * 60);

  /// Total duration in fractional milliseconds.
  double get inMillisecondsDouble => inMicroseconds / 1000;

  /// Total duration in fractional minutes.
  double get inMinutesDouble => inMicroseconds / (1000000 * 60);

  /// Total duration in fractional seconds.
  double get inSecondsDouble => inMicroseconds / 1000000;

  /// Total duration in fractional weeks.
  double get inWeeksDouble => inMicroseconds / (1000000 * 60 * 60 * 24 * 7);

  // ── Predicates ───────────────────────────────────────────────────────────

  /// Returns true if the duration is functionally negative (<0 microseconds).
  bool get isNegative => inMicroseconds < 0;

  /// Returns true if the duration is functionally positive (>0 microseconds).
  bool get isPositive => inMicroseconds > 0;

  /// Returns true if the duration is exactly zero.
  bool get isZero => inMicroseconds == 0;

  // ── Clamp / abs ──────────────────────────────────────────────────────────

  /// Scales this duration by [factor].
  ///
  /// ```dart
  /// 2.seconds * 3; // 6 seconds
  /// ```
  Duration operator *(num factor) =>
      Duration(microseconds: (inMicroseconds * factor).round());

  /// Divides this duration by [factor].
  ///
  /// ```dart
  /// 6.seconds / 2; // 3 seconds
  /// ```
  Duration operator /(num factor) =>
      Duration(microseconds: (inMicroseconds / factor).round());

  /// Clamps this duration between [min] and [max].
  Duration clamp(Duration min, Duration max) => Duration(
    microseconds: inMicroseconds.clamp(min.inMicroseconds, max.inMicroseconds),
  );

  /// Ensures this duration is at least [min].
  Duration coerceAtLeast(Duration min) => this < min ? min : this;

  // ── Formatting ───────────────────────────────────────────────────────────

  /// Ensures this duration is at most [max].
  Duration coerceAtMost(Duration max) => this > max ? max : this;

  /// Runs [callback] after this duration.
  Future<T> delayed<T>(T Function() callback) => Future.delayed(this, callback);

  // ── Delay helpers ────────────────────────────────────────────────────────

  /// `HH:MM:SS` — useful for display in timers/players.
  String toHHMMSS() {
    final h = inHours.abs();
    final m = inMinutes.abs().remainder(60);
    final s = inSeconds.abs().remainder(60);
    final hh = h > 0 ? '${h.toString().padLeft(2, '0')}:' : '';
    return '$hh${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Human-readable: `2h 30m`, `45s`, `200ms`.
  String toHuman() {
    if (inMicroseconds.abs() < 1000) {
      return '$inMicrosecondsµs';
    }
    if (inMilliseconds.abs() < 1000) {
      return '${inMillisecondsDouble.toStringAsFixed(0)}ms';
    }
    if (inSeconds.abs() < 60) {
      return '${inSecondsDouble.toStringAsFixed(1)}s';
    }
    if (inMinutes.abs() < 60) {
      return '${inMinutes.abs()}m ${inSeconds.abs().remainder(60)}s';
    }
    if (inHours.abs() < 24) {
      return '${inHours.abs()}h ${inMinutes.abs().remainder(60)}m';
    }
    return '${inDaysDouble.toStringAsFixed(1)}d';
  }
}

// ─── Duration arithmetic & comparison ────────────────────────────────────

/// Extension on [num] allowing concise creation of [Duration] instances (e.g., `5.seconds`).
extension NumDurationExtension on num {
  // ─── Core (everything delegates through microseconds) ──────────────────

  /// Returns a [Duration] in days.
  Duration get days => (this * 1000 * 1000 * 60 * 60 * 24).microseconds;

  /// Returns a [Duration] in hours.
  Duration get hours => (this * 1000 * 1000 * 60 * 60).microseconds;

  /// Returns a [Duration] in microseconds.
  Duration get microseconds => Duration(microseconds: round());

  /// Returns a [Duration] in milliseconds.
  Duration get milliseconds => (this * 1000).microseconds;

  /// Returns a [Duration] in minutes.
  Duration get minutes => (this * 1000 * 1000 * 60).microseconds;

  /// Returns a [Duration] in milliseconds (alias).
  Duration get ms => (this * 1000).microseconds;

  /// Returns a [Duration] in seconds.
  Duration get seconds => (this * 1000 * 1000).microseconds;

  /// Returns a [Duration] in weeks.
  Duration get weeks => (this * 1000 * 1000 * 60 * 60 * 24 * 7).microseconds;
}
