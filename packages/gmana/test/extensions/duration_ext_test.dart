import 'package:test/test.dart';
import 'package:gmana/extensions/duration_ext.dart';

void main() {
  group('HumanizedDuration Extension', () {
    group('Formatting', () {
      test('toHumanizedString formats correctly', () {
        expect(
          const Duration(hours: 1, minutes: 2, seconds: 34).toHumanizedString(),
          '1:02:34',
        );
        expect(
          const Duration(minutes: 2, seconds: 5).toHumanizedString(),
          '2:05',
        );
        expect(
          const Duration(minutes: 65, seconds: 5).toHumanizedString(),
          '1:05:05',
        );
        expect(
          const Duration(minutes: -2, seconds: -5).toHumanizedString(),
          '-2:05',
        );
      });

      test('toPaddedString formats with full padding', () {
        expect(
          const Duration(hours: 1, minutes: 2, seconds: 34).toPaddedString(),
          '01:02:34',
        );
        expect(
          const Duration(minutes: 2, seconds: 5).toPaddedString(),
          '02:05',
        );
        expect(
          const Duration(minutes: -2, seconds: -5).toPaddedString(),
          '-02:05',
        );
        expect(
          const Duration(hours: 10, minutes: 0, seconds: 0).toPaddedString(),
          '10:00:00',
        );
      });

      test('toVerboseString formats concisely', () {
        expect(
          const Duration(hours: 1, minutes: 2, seconds: 34).toVerboseString(),
          '1h 2m 34s',
        );
        expect(
          const Duration(minutes: 2, seconds: 34).toVerboseString(),
          '2m 34s',
        );
        expect(
          const Duration(hours: 1).toVerboseString(includeSeconds: false),
          '1h',
        );
        expect(const Duration().toVerboseString(), '0s');
        expect(const Duration().toVerboseString(includeSeconds: false), '0m');
        expect(const Duration(minutes: -5).toVerboseString(), '-5m');
      });

      test('toWordString formats with full words', () {
        expect(
          const Duration(hours: 1, minutes: 2, seconds: 34).toWordString(),
          '1 hour, 2 minutes, 34 seconds',
        );
        expect(
          const Duration(hours: 2, minutes: 1, seconds: 1).toWordString(),
          '2 hours, 1 minute, 1 second',
        );
        expect(const Duration().toWordString(), '0 seconds');
        expect(
          const Duration().toWordString(includeSeconds: false),
          '0 minutes',
        );
        expect(const Duration(minutes: -5).toWordString(), '-5 minutes');
      });

      test('toRelativeString formats correctly depending on distance', () {
        expect(const Duration(seconds: 5).toRelativeString(), 'just now');
        expect(const Duration(seconds: 15).toRelativeString(), 'in 15 seconds');
        expect(const Duration(minutes: -5).toRelativeString(), '5 minutes ago');
        expect(
          const Duration(hours: 1, minutes: 10).toRelativeString(),
          'in 1 hour',
        );
        expect(const Duration(hours: 2).toRelativeString(), 'in 2 hours');
        expect(const Duration(days: -1).toRelativeString(), '1 day ago');
        expect(const Duration(days: 35).toRelativeString(), 'in 1 month');
        expect(const Duration(days: -365).toRelativeString(), '1 year ago');
      });
    });

    group('Arithmetic helpers', () {
      test('multiplication operator works', () {
        expect(
          const Duration(minutes: 1) * 2.5,
          const Duration(minutes: 2, seconds: 30),
        );
        expect(const Duration(minutes: 2) * 3, const Duration(minutes: 6));
      });

      test('division operator works', () {
        expect(
          const Duration(minutes: 5) / 2,
          const Duration(minutes: 2, seconds: 30),
        );
        expect(const Duration(hours: 1) / 3, const Duration(minutes: 20));
      });

      test('abs returns absolute value', () {
        // HumanizedDuration.abs is a getter, but Duration.abs() is a method.
        // We test the extension getter by explicitly resolving it:
        expect(
          HumanizedDuration(const Duration(minutes: -5)).abs,
          const Duration(minutes: 5),
        );
        expect(
          HumanizedDuration(const Duration(minutes: 5)).abs,
          const Duration(minutes: 5),
        );
      });

      test('predicates isNegative, isZero, isPositive', () {
        expect(const Duration(minutes: -1).isNegative, isTrue);
        expect(const Duration().isZero, isTrue);
        expect(const Duration(seconds: 1).isPositive, isTrue);

        expect(const Duration().isNegative, isFalse);
        expect(const Duration(seconds: 1).isZero, isFalse);
        expect(const Duration(minutes: -1).isPositive, isFalse);
      });

      test('clamp keeps duration within bounds', () {
        final min = const Duration(minutes: 1);
        final max = const Duration(hours: 1);

        expect(const Duration(seconds: 30).clamp(min, max), min);
        expect(const Duration(hours: 2).clamp(min, max), max);
        expect(
          const Duration(minutes: 30).clamp(min, max),
          const Duration(minutes: 30),
        );
      });
    });

    group('Component accessors', () {
      test('parts accessors return correct values', () {
        final d = const Duration(
          hours: 2,
          minutes: 15,
          seconds: 30,
          milliseconds: 500,
        );
        expect(d.hoursPart, 2);
        expect(d.minutesPart, 15);
        expect(d.secondsPart, 30);
        expect(d.millisecondsPart, 500);

        // Note: For negative durations, the extension uses % which can yield confusing results in Dart,
        // so we mainly verify standard extraction here.
      });

      test('total accessors return correct float values', () {
        final d = const Duration(hours: 1, minutes: 30);
        expect(d.totalMinutes, 90.0);
        expect(d.totalHours, 1.5);
        expect(const Duration(hours: 36).totalDays, 1.5);
      });
    });

    group('Predicates', () {
      test('isLongerThan and isShorterThan', () {
        final d1 = const Duration(minutes: 5);
        final d2 = const Duration(minutes: 10);

        expect(d2.isLongerThan(d1), isTrue);
        expect(d1.isShorterThan(d2), isTrue);
        expect(d1.isLongerThan(d2), isFalse);
        expect(d2.isShorterThan(d1), isFalse);
        expect(d1.isLongerThan(d1), isFalse); // Strict
      });

      test('isWithin check range difference', () {
        final base = const Duration(minutes: 10);
        final range = const Duration(minutes: 2);

        expect(const Duration(minutes: 11).isWithin(range, base), isTrue);
        expect(const Duration(minutes: 8).isWithin(range, base), isTrue);
        expect(const Duration(minutes: 7).isWithin(range, base), isFalse);
        expect(const Duration(minutes: 13).isWithin(range, base), isFalse);
      });
    });

    group('Progress / percentage', () {
      test('progressOf calculates correct ratio', () {
        final total = const Duration(hours: 1);
        expect(const Duration(minutes: 30).progressOf(total), 0.5);
        expect(const Duration(hours: 2).progressOf(total), 1.0); // Clamped
        expect(
          const Duration(hours: 2).progressOf(total, clampResult: false),
          2.0,
        ); // Not clamped
        expect(
          const Duration().progressOf(const Duration()),
          0.0,
        ); // zero total handles
      });

      test('remainingIn calculates correct remaining duration', () {
        final total = const Duration(hours: 1);
        expect(
          const Duration(minutes: 15).remainingIn(total),
          const Duration(minutes: 45),
        );
        expect(
          const Duration(minutes: 75).remainingIn(total),
          const Duration(minutes: -15),
        );
      });
    });

    group('Rounding / truncating', () {
      test('roundToSeconds rounds to nearest second', () {
        expect(
          const Duration(milliseconds: 1499).roundToSeconds(),
          const Duration(seconds: 1),
        );
        expect(
          const Duration(milliseconds: 1500).roundToSeconds(),
          const Duration(seconds: 2),
        );
      });

      test('roundToMinutes rounds to nearest minute', () {
        expect(
          const Duration(seconds: 29).roundToMinutes(),
          const Duration(minutes: 0),
        );
        expect(
          const Duration(seconds: 30).roundToMinutes(),
          const Duration(minutes: 1),
        );
      });

      test('floorToMinutes floors consistently', () {
        expect(
          const Duration(minutes: 1, seconds: 59).floorToMinutes(),
          const Duration(minutes: 1),
        );
      });

      test('ceilToMinutes ceils consistently', () {
        expect(
          const Duration(minutes: 1, seconds: 1).ceilToMinutes(),
          const Duration(minutes: 2),
        );
        expect(
          const Duration(minutes: 1, seconds: 0).ceilToMinutes(),
          const Duration(minutes: 1),
        );
      });
    });

    group('Conversion', () {
      test('toSeconds returns float seconds', () {
        expect(const Duration(milliseconds: 1500).toSeconds(), 1.5);
      });

      test('toFrames converts to frame count accurately', () {
        // 1 second at 24 fps = 24 frames
        expect(const Duration(seconds: 1).toFrames(24.0), 24);

        // 0.5 sec at 60fps = 30 frames
        expect(const Duration(milliseconds: 500).toFrames(60.0), 30);
      });

      test('fromFrames reconstructs duration', () {
        expect(
          HumanizedDuration.fromFrames(24, 24.0),
          const Duration(seconds: 1),
        );
        expect(
          HumanizedDuration.fromFrames(30, 60.0),
          const Duration(milliseconds: 500),
        );
      });
    });
  });
}
