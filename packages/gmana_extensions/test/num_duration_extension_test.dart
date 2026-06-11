import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('NumDurationExtension', () {
    test('microseconds', () {
      expect(5.microseconds, equals(const Duration(microseconds: 5)));
      expect(5.5.microseconds, equals(const Duration(microseconds: 6)));
    });

    test('microsecond aliases', () {
      expect(5.microsecond, equals(const Duration(microseconds: 5)));
      expect(5.micros, equals(const Duration(microseconds: 5)));
      expect(5.us, equals(const Duration(microseconds: 5)));
    });

    test('nanoseconds round to nearest microsecond', () {
      expect(500.nanoseconds, equals(const Duration(microseconds: 1)));
      expect(1499.nanoseconds, equals(const Duration(microseconds: 1)));
      expect(1500.nanoseconds, equals(const Duration(microseconds: 2)));
      expect(1.nanosecond, equals(Duration.zero));
    });

    test('milliseconds', () {
      expect(5.milliseconds, equals(const Duration(milliseconds: 5)));
    });

    test('ms alias', () {
      expect(5.ms, equals(const Duration(milliseconds: 5)));
      expect(5.millisecond, equals(const Duration(milliseconds: 5)));
      expect(5.millis, equals(const Duration(milliseconds: 5)));
    });

    test('seconds', () {
      expect(5.seconds, equals(const Duration(seconds: 5)));
      expect(5.second, equals(const Duration(seconds: 5)));
      expect(5.sec, equals(const Duration(seconds: 5)));
      expect(5.secs, equals(const Duration(seconds: 5)));
      expect(1.5.seconds, equals(const Duration(milliseconds: 1500)));
    });

    test('minutes', () {
      expect(5.minutes, equals(const Duration(minutes: 5)));
      expect(5.minute, equals(const Duration(minutes: 5)));
    });

    test('hours', () {
      expect(5.hours, equals(const Duration(hours: 5)));
      expect(5.hour, equals(const Duration(hours: 5)));
    });

    test('days', () {
      expect(5.days, equals(const Duration(days: 5)));
      expect(5.day, equals(const Duration(days: 5)));
    });

    test('weeks', () {
      expect(2.weeks, equals(const Duration(days: 14)));
      expect(2.week, equals(const Duration(days: 14)));
    });

    test('fortnights', () {
      expect(1.fortnight, equals(const Duration(days: 14)));
      expect(2.fortnights, equals(const Duration(days: 28)));
    });

    test('framesAt converts frames to duration', () {
      expect(120.framesAt(24), equals(const Duration(seconds: 5)));
      expect(30.framesAt(60), equals(const Duration(milliseconds: 500)));
      expect(1.framesAt(2), equals(const Duration(milliseconds: 500)));
      expect(() => 1.framesAt(0), throwsArgumentError);
      expect(() => 1.framesAt(-24), throwsArgumentError);
    });
  });

  group('DurationX', () {
    test('operator *', () {
      expect(2.seconds * 3, equals(6.seconds));
      expect(3.seconds * 1.5, equals(4500.milliseconds));
    });

    test('operator /', () {
      expect(6.seconds / 2, equals(3.seconds));
      expect(5.seconds / 2, equals(2500.milliseconds));
    });

    test('inMillisecondsDouble', () {
      expect(1500.microseconds.inMillisecondsDouble, equals(1.5));
    });

    test('inSecondsDouble', () {
      expect(1500.milliseconds.inSecondsDouble, equals(1.5));
    });

    test('inMinutesDouble', () {
      expect(90.seconds.inMinutesDouble, equals(1.5));
    });

    test('inHoursDouble', () {
      expect(90.minutes.inHoursDouble, equals(1.5));
    });

    test('inDaysDouble', () {
      expect(36.hours.inDaysDouble, equals(1.5));
    });

    test('inWeeksDouble', () {
      expect(10.5.days.inWeeksDouble, equals(1.5));
    });

    test('isZero', () {
      expect(0.seconds.isZero, isTrue);
      expect(1.seconds.isZero, isFalse);
    });

    test('isPositive', () {
      expect(1.seconds.isPositive, isTrue);
      expect(0.seconds.isPositive, isFalse);
      expect((-1).seconds.isPositive, isFalse);
    });

    test('isNegative', () {
      expect((-1).seconds.isNegative, isTrue);
      expect(0.seconds.isNegative, isFalse);
      expect(1.seconds.isNegative, isFalse);
    });

    test('abs', () {
      expect((-5).seconds.abs(), equals(5.seconds));
      expect(5.seconds.abs(), equals(5.seconds));
    });

    test('clamp', () {
      final value = 5.seconds;
      expect(value.clamp(1.seconds, 10.seconds), equals(5.seconds));
      expect(value.clamp(6.seconds, 10.seconds), equals(6.seconds));
      expect(value.clamp(1.seconds, 3.seconds), equals(3.seconds));
    });

    test('coerceAtLeast', () {
      expect(5.seconds.coerceAtLeast(3.seconds), equals(5.seconds));
      expect(5.seconds.coerceAtLeast(8.seconds), equals(8.seconds));
    });

    test('coerceAtMost', () {
      expect(5.seconds.coerceAtMost(8.seconds), equals(5.seconds));
      expect(5.seconds.coerceAtMost(3.seconds), equals(3.seconds));
    });

    test('toHHMMSS', () {
      expect(
        const Duration(hours: 2, minutes: 30, seconds: 45).toHHMMSS(),
        equals('02:30:45'),
      );
      expect(
        const Duration(minutes: 5, seconds: 9).toHHMMSS(),
        equals('05:09'),
      );
      expect(const Duration(seconds: 45).toHHMMSS(), equals('00:45'));
      expect(
        const Duration(hours: -1, minutes: -5, seconds: -9).toHHMMSS(),
        equals('01:05:09'),
      );
    });

    test('toHuman', () {
      expect(500.microseconds.toHuman(), equals('500us'));
      expect(500.milliseconds.toHuman(), equals('500ms'));
      expect(45.seconds.toHuman(), equals('45.0s'));
      expect(90.seconds.toHuman(), equals('1m 30s'));
      expect(150.minutes.toHuman(), equals('2h 30m'));
      expect(36.hours.toHuman(), equals('1.5d'));
      expect((-90).seconds.toHuman(), equals('1m 30s'));
    });

    test('delay and delayed', () async {
      final start = DateTime.now();
      await 50.milliseconds.delay;
      expect(
        DateTime.now().difference(start).inMilliseconds,
        greaterThanOrEqualTo(45),
      );

      final result = await 50.milliseconds.delayed(() => 'done');
      expect(result, equals('done'));
    });
  });
}
