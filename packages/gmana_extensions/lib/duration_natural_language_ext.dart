import 'duration_ext.dart' show HumanizedDuration;

/// Alternative duration formatting for human-readable UI copy.
///
/// Complements [HumanizedDuration] with additional UI-friendly formats:
/// - [toNaturalString] - word-based, top-2 units: `"1 hour 2 minutes"`
/// - [toCompactString] - abbreviated top-2 units: `"1h 2m"`
/// - [toDetailedString] - abbreviated with milliseconds: `"1m 0s 500ms"`
/// - [toNaturalSentence] - word-based with conjunction: `"1 hour and 2 minutes"`
/// - [toApproximateString] - rounded friendly text: `"about 2 hours"`
extension DurationNaturalLanguageX on Duration {
  /// Short compact form showing the most significant non-zero units.
  ///
  /// ```dart
  /// const Duration(hours: 2, minutes: 3).toCompactString(); // '2h 3m'
  /// const Duration(seconds: 45).toCompactString();          // '45s'
  /// Duration.zero.toCompactString();                        // '0s'
  /// ```
  String toCompactString({int maxUnits = 2, bool includeSeconds = true}) {
    final parts = _durationParts(
      this,
      includeSeconds: includeSeconds,
      zeroUnit: includeSeconds ? _DurationUnit.second : _DurationUnit.minute,
    );

    final body = parts
        .take(_checkedMaxUnits(maxUnits))
        .map((part) => part.compact)
        .join(' ');
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
  String toDetailedString({
    bool includeMilliseconds = true,
    bool includeMicroseconds = false,
  }) {
    final parts = _durationParts(
      this,
      includeZeroSeconds: true,
      includeMilliseconds: includeMilliseconds,
      includeMicroseconds: includeMicroseconds,
    );

    final body = parts.map((part) => part.compact).join(' ');
    return inMicroseconds < 0 ? '-$body' : body;
  }

  /// Natural-language description using the largest non-zero units.
  ///
  /// Unlike [HumanizedDuration.toWordString], uses a space separator and
  /// limits output to two units by default.
  ///
  /// ```dart
  /// const Duration(hours: 2, minutes: 3).toNaturalString(); // '2 hours 3 minutes'
  /// const Duration(minutes: 1, seconds: 5).toNaturalString(); // '1 minute 5 seconds'
  /// Duration.zero.toNaturalString(); // '0 seconds'
  /// ```
  String toNaturalString({int maxUnits = 2, bool includeSeconds = true}) {
    final parts = _durationParts(
      this,
      includeSeconds: includeSeconds,
      zeroUnit: includeSeconds ? _DurationUnit.second : _DurationUnit.minute,
    );

    final body = parts
        .take(_checkedMaxUnits(maxUnits))
        .map((part) => part.word)
        .join(' ');
    return inMicroseconds < 0 ? '-$body' : body;
  }

  /// Natural-language description with a final conjunction.
  ///
  /// ```dart
  /// const Duration(hours: 1, minutes: 2).toNaturalSentence(); // '1 hour and 2 minutes'
  /// const Duration(seconds: 30).toNaturalSentence();          // '30 seconds'
  /// ```
  String toNaturalSentence({
    int maxUnits = 2,
    bool includeSeconds = true,
    String conjunction = 'and',
  }) {
    final parts =
        _durationParts(
          this,
          includeSeconds: includeSeconds,
          zeroUnit:
              includeSeconds ? _DurationUnit.second : _DurationUnit.minute,
        ).take(_checkedMaxUnits(maxUnits)).map((part) => part.word).toList();

    final body = _joinWithConjunction(parts, conjunction);
    return inMicroseconds < 0 ? '-$body' : body;
  }

  /// Rounded friendly text for approximate UI copy.
  ///
  /// ```dart
  /// const Duration(minutes: 90).toApproximateString(); // 'about 2 hours'
  /// const Duration(seconds: 20).toApproximateString(); // 'less than a minute'
  /// ```
  String toApproximateString() {
    final d = Duration(microseconds: inMicroseconds.abs());

    final String body;
    if (d.inSeconds < 45) {
      body = 'less than a minute';
    } else if (d.inMinutes < 45) {
      body = _approximateUnit(d.inMinutes, 'minute');
    } else if (d.inHours < 22) {
      body = _approximateUnit((d.inMinutes / 60).round(), 'hour');
    } else if (d.inDays < 26) {
      body = _approximateUnit((d.inHours / 24).round(), 'day');
    } else if (d.inDays < 320) {
      body = _approximateUnit((d.inDays / 30).round(), 'month');
    } else {
      body = _approximateUnit((d.inDays / 365).round(), 'year');
    }

    return inMicroseconds < 0 ? '$body ago' : body;
  }
}

enum _DurationUnit {
  day('d', 'day'),
  hour('h', 'hour'),
  minute('m', 'minute'),
  second('s', 'second'),
  millisecond('ms', 'millisecond'),
  microsecond('us', 'microsecond');

  const _DurationUnit(this.shortName, this.name);

  final String shortName;
  final String name;
}

class _DurationPart {
  const _DurationPart(this.value, this.unit);

  final int value;
  final _DurationUnit unit;

  String get compact => '$value${unit.shortName}';

  String get word => '$value ${value == 1 ? unit.name : '${unit.name}s'}';
}

List<_DurationPart> _durationParts(
  Duration duration, {
  bool includeSeconds = true,
  bool includeZeroSeconds = false,
  bool includeMilliseconds = false,
  bool includeMicroseconds = false,
  _DurationUnit zeroUnit = _DurationUnit.second,
}) {
  final d = Duration(microseconds: duration.inMicroseconds.abs());
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  final seconds = d.inSeconds % 60;
  final milliseconds = d.inMilliseconds % 1000;
  final microseconds = d.inMicroseconds % 1000;

  final parts = <_DurationPart>[
    if (days > 0) _DurationPart(days, _DurationUnit.day),
    if (hours > 0) _DurationPart(hours, _DurationUnit.hour),
    if (minutes > 0) _DurationPart(minutes, _DurationUnit.minute),
    if ((seconds > 0 && includeSeconds) || includeZeroSeconds)
      _DurationPart(seconds, _DurationUnit.second),
    if (milliseconds > 0 && includeMilliseconds)
      _DurationPart(milliseconds, _DurationUnit.millisecond),
    if (microseconds > 0 && includeMicroseconds)
      _DurationPart(microseconds, _DurationUnit.microsecond),
  ];

  if (parts.isNotEmpty) return parts;

  return [_DurationPart(0, zeroUnit)];
}

int _checkedMaxUnits(int maxUnits) {
  if (maxUnits < 1) {
    throw ArgumentError.value(
      maxUnits,
      'maxUnits',
      'must be greater than zero',
    );
  }
  return maxUnits;
}

String _joinWithConjunction(List<String> parts, String conjunction) {
  if (parts.length <= 1) return parts.join();
  if (parts.length == 2) return '${parts.first} $conjunction ${parts.last}';

  final head = parts.take(parts.length - 1).join(', ');
  return '$head, $conjunction ${parts.last}';
}

String _approximateUnit(int value, String singular) {
  final safeValue = value < 1 ? 1 : value;
  return 'about $safeValue ${safeValue == 1 ? singular : '${singular}s'}';
}
