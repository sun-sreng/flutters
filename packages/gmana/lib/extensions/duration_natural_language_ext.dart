/// Alternative duration formatting focused on human-readable text for UI copy.
///
/// This library is intentionally not exported from `package:gmana/gmana.dart`
/// because `gmana` already provides another `Duration` extension with some
/// overlapping method names.
extension DurationNaturalLanguageX on Duration {
  /// Whether this duration is negative.
  bool get isNegative => inMicroseconds < 0;

  /// Whether this duration is exactly zero.
  bool get isZero => inMicroseconds == 0;

  Duration get _abs => abs();

  /// Returns `true` when this duration exceeds [other].
  bool isLongerThan(Duration other) => compareTo(other) > 0;

  /// Returns `true` when this duration is shorter than [other].
  bool isShorterThan(Duration other) => compareTo(other) < 0;

  /// Returns a stopwatch-style string.
  String toClockString() {
    final d = _abs;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;

    final mm = '$m'.padLeft(2, '0');
    final ss = '$s'.padLeft(2, '0');
    final body = h > 0 ? '$h:$mm:$ss' : '$m:$ss';

    return isNegative ? '-$body' : body;
  }

  /// Returns a short compact form for tight UI.
  String toCompactString() {
    final d = _abs;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;

    final parts = <String>[
      if (h > 0) '${h}h',
      if (m > 0) '${m}m',
      if (s > 0 || (h == 0 && m == 0)) '${s}s',
    ];

    final body = parts.take(2).join(' ');
    return isNegative ? '-$body' : body;
  }

  /// Returns a natural-language description using the two largest non-zero units.
  String toHumanizedString() {
    final d = _abs;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;

    String unit(int n, String singular) =>
        '$n ${n == 1 ? singular : '${singular}s'}';

    final parts = <String>[
      if (h > 0) unit(h, 'hour'),
      if (m > 0) unit(m, 'minute'),
      if (s > 0 || (h == 0 && m == 0)) unit(s, 'second'),
    ];

    return parts.take(2).join(' ');
  }

  /// Returns a relative time string suitable for UI copy.
  String toRelativeString() {
    if (_abs.inSeconds < 5) return 'just now';
    final base = _abs.toHumanizedString();
    return isNegative ? '$base ago' : 'in $base';
  }

  /// Full breakdown including milliseconds.
  String toVerboseString() {
    final d = _abs;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final ms = d.inMilliseconds % 1000;

    final parts = <String>[
      if (h > 0) '${h}h',
      if (h > 0 || m > 0) '${m}m',
      '${s}s',
      if (ms > 0) '${ms}ms',
    ];

    final body = parts.join(' ');
    return isNegative ? '-$body' : body;
  }
}
