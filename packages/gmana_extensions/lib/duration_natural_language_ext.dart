import 'duration_ext.dart' show HumanizedDuration;
import 'gmana_extensions.dart' show HumanizedDuration;

/// Alternative duration formatting for human-readable UI copy.
///
/// Complements [HumanizedDuration] with two additional formats:
/// - [toNaturalString] — word-based, top-2 units: `"1 hour 2 minutes"`
/// - [toCompactString] — abbreviated top-2 units: `"1h 2m"`
/// - [toDetailedString] — abbreviated with milliseconds: `"1m 0s 500ms"`
extension DurationNaturalLanguageX on Duration {
  /// Short compact form showing the two most significant non-zero units.
  ///
  /// ```dart
  /// const Duration(hours: 2, minutes: 3).toCompactString(); // '2h 3m'
  /// const Duration(seconds: 45).toCompactString();          // '45s'
  /// Duration.zero.toCompactString();                        // '0s'
  /// ```
  String toCompactString() {
    final d = Duration(microseconds: inMicroseconds.abs());
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;

    final parts = <String>[if (h > 0) '${h}h', if (m > 0) '${m}m', if (s > 0 || (h == 0 && m == 0)) '${s}s'];

    final body = parts.take(2).join(' ');
    return inMicroseconds < 0 ? '-$body' : body;
  }

  /// Abbreviated breakdown including milliseconds.
  ///
  /// Unlike [HumanizedDuration.toVerboseString], always includes milliseconds
  /// when non-zero and always shows seconds.
  ///
  /// ```dart
  /// const Duration(minutes: 1, milliseconds: 500).toDetailedString(); // '1m 0s 500ms'
  /// const Duration(hours: 1, minutes: 2).toDetailedString();          // '1h 2m 0s'
  /// ```
  String toDetailedString() {
    final d = Duration(microseconds: inMicroseconds.abs());
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final ms = d.inMilliseconds % 1000;

    final parts = <String>[if (h > 0) '${h}h', if (h > 0 || m > 0) '${m}m', '${s}s', if (ms > 0) '${ms}ms'];

    final body = parts.join(' ');
    return inMicroseconds < 0 ? '-$body' : body;
  }

  /// Natural-language description using the two largest non-zero units.
  ///
  /// Unlike [HumanizedDuration.toWordString], uses a space separator and
  /// limits output to two units.
  ///
  /// ```dart
  /// const Duration(hours: 2, minutes: 3).toNaturalString(); // '2 hours 3 minutes'
  /// const Duration(minutes: 1, seconds: 5).toNaturalString(); // '1 minute 5 seconds'
  /// Duration.zero.toNaturalString(); // '0 seconds'
  /// ```
  String toNaturalString() {
    final d = Duration(microseconds: inMicroseconds.abs());
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;

    String unit(int n, String singular) => '$n ${n == 1 ? singular : '${singular}s'}';

    final parts = <String>[
      if (h > 0) unit(h, 'hour'),
      if (m > 0) unit(m, 'minute'),
      if (s > 0 || (h == 0 && m == 0)) unit(s, 'second'),
    ];

    return parts.take(2).join(' ');
  }
}
