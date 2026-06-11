import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DurationNaturalLanguageX', () {
    test('formats compact strings', () {
      expect(const Duration(hours: 2, minutes: 3).toCompactString(), '2h 3m');
      expect(const Duration(seconds: 45).toCompactString(), '45s');
      expect(Duration.zero.toCompactString(), '0s');
      expect(
        const Duration(days: 1, hours: 2, minutes: 3).toCompactString(),
        '1d 2h',
      );
      expect(
        const Duration(
          days: 1,
          hours: 2,
          minutes: 3,
        ).toCompactString(maxUnits: 3),
        '1d 2h 3m',
      );
      expect(
        const Duration(seconds: 45).toCompactString(includeSeconds: false),
        '0m',
      );
      expect(const Duration(minutes: -5).toCompactString(), '-5m');
    });

    test('formats natural strings', () {
      expect(
        const Duration(hours: 2, minutes: 3).toNaturalString(),
        '2 hours 3 minutes',
      );
      expect(
        const Duration(minutes: 1, seconds: 5).toNaturalString(),
        '1 minute 5 seconds',
      );
      expect(Duration.zero.toNaturalString(), '0 seconds');
      expect(
        const Duration(
          days: 1,
          hours: 2,
          minutes: 3,
        ).toNaturalString(maxUnits: 3),
        '1 day 2 hours 3 minutes',
      );
      expect(
        const Duration(
          minutes: 1,
          seconds: 5,
        ).toNaturalString(includeSeconds: false),
        '1 minute',
      );
      expect(const Duration(minutes: -5).toNaturalString(), '-5 minutes');
      expect(
        () => Duration.zero.toNaturalString(maxUnits: 0),
        throwsArgumentError,
      );
    });

    test('formats detailed strings with milliseconds', () {
      expect(
        const Duration(minutes: 1, milliseconds: 500).toDetailedString(),
        '1m 0s 500ms',
      );
      expect(
        const Duration(hours: 1, minutes: 2).toDetailedString(),
        '1h 2m 0s',
      );
      expect(
        const Duration(
          days: 1,
          microseconds: 250,
        ).toDetailedString(includeMicroseconds: true),
        '1d 0s 250us',
      );
      expect(
        const Duration(
          milliseconds: 500,
        ).toDetailedString(includeMilliseconds: false),
        '0s',
      );
      expect(
        const Duration(milliseconds: -500).toDetailedString(),
        '-0s 500ms',
      );
    });

    test('formats natural sentences', () {
      expect(
        const Duration(hours: 1, minutes: 2).toNaturalSentence(),
        '1 hour and 2 minutes',
      );
      expect(
        const Duration(
          days: 1,
          hours: 2,
          minutes: 3,
        ).toNaturalSentence(maxUnits: 3),
        '1 day, 2 hours, and 3 minutes',
      );
      expect(
        const Duration(
          hours: 1,
          minutes: 2,
        ).toNaturalSentence(conjunction: 'plus'),
        '1 hour plus 2 minutes',
      );
      expect(const Duration(seconds: 30).toNaturalSentence(), '30 seconds');
    });

    test('formats approximate strings', () {
      expect(
        const Duration(seconds: 20).toApproximateString(),
        'less than a minute',
      );
      expect(
        const Duration(minutes: 10).toApproximateString(),
        'about 10 minutes',
      );
      expect(
        const Duration(minutes: 90).toApproximateString(),
        'about 2 hours',
      );
      expect(
        const Duration(days: -400).toApproximateString(),
        'about 1 year ago',
      );
    });

    // toClockString was removed — use HumanizedDuration.toHumanizedString instead
    test('clock format via HumanizedDuration', () {
      expect(
        const Duration(hours: 1, minutes: 3, seconds: 7).toHumanizedString(),
        '1:03:07',
      );
      expect(
        const Duration(minutes: 4, seconds: 2).toHumanizedString(),
        '4:02',
      );
    });
  });
}
