import 'package:gmana/extensions/duration_natural_language_ext.dart';
import 'package:test/test.dart';

void main() {
  group('DurationNaturalLanguageX', () {
    test('formats clock strings', () {
      expect(
        const Duration(hours: 1, minutes: 3, seconds: 7).toClockString(),
        '1:03:07',
      );
      expect(const Duration(minutes: 4, seconds: 2).toClockString(), '4:02');
      expect(const Duration(minutes: -2, seconds: -5).toClockString(), '-2:05');
    });

    test('formats compact strings', () {
      expect(const Duration(hours: 2, minutes: 3).toCompactString(), '2h 3m');
      expect(const Duration(seconds: 45).toCompactString(), '45s');
      expect(Duration.zero.toCompactString(), '0s');
    });

    test('formats humanized strings', () {
      expect(
        const Duration(hours: 2, minutes: 3).toHumanizedString(),
        '2 hours 3 minutes',
      );
      expect(
        const Duration(minutes: 1, seconds: 5).toHumanizedString(),
        '1 minute 5 seconds',
      );
      expect(Duration.zero.toHumanizedString(), '0 seconds');
    });

    test('formats relative strings', () {
      expect(const Duration(minutes: 5).toRelativeString(), 'in 5 minutes');
      expect(const Duration(minutes: -3).toRelativeString(), '3 minutes ago');
      expect(const Duration(seconds: 3).toRelativeString(), 'just now');
    });

    test('formats verbose strings', () {
      expect(
        const Duration(minutes: 1, milliseconds: 500).toVerboseString(),
        '1m 0s 500ms',
      );
      expect(
        const Duration(hours: -1, minutes: -2).toVerboseString(),
        '-1h 2m 0s',
      );
    });
  });
}
