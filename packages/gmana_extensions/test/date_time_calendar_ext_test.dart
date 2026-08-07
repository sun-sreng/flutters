import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeX calendar facts', () {
    test('daysInMonth is leap-year aware', () {
      expect(DateTime(2024, 2, 10).daysInMonth, 29);
      expect(DateTime(2023, 2, 10).daysInMonth, 28);
      expect(DateTime(2024, 4, 10).daysInMonth, 30);
      expect(DateTime(2024, 12, 10).daysInMonth, 31);
    });

    test('dayOfYear counts from 1', () {
      expect(DateTime(2024).dayOfYear, 1);
      expect(DateTime(2024, 3).dayOfYear, 61);
      expect(DateTime(2024, 12, 31).dayOfYear, 366);
      expect(DateTime(2023, 12, 31).dayOfYear, 365);
    });

    test('weekOfYear follows ISO 8601', () {
      expect(DateTime(2024).weekOfYear, 1);
      expect(DateTime(2024, 6, 15).weekOfYear, 24);
      expect(DateTime(2024, 12, 31).weekOfYear, 1);
      expect(DateTime(2021).weekOfYear, 53);
    });

    test('quarter maps months to 1-4', () {
      expect(DateTime(2024).quarter, 1);
      expect(DateTime(2024, 4).quarter, 2);
      expect(DateTime(2024, 9).quarter, 3);
      expect(DateTime(2024, 12).quarter, 4);
    });

    test('isPast and isFuture', () {
      expect(DateTime(2000).isPast, isTrue);
      expect(DateTime(2000).isFuture, isFalse);
      expect(DateTime(2999).isFuture, isTrue);
    });
  });

  group('DateTimeX boundaries', () {
    final moment = DateTime(2024, 5, 17, 14, 37, 22, 500, 250);

    test('startOfMinute clears seconds and below', () {
      expect(moment.startOfMinute, DateTime(2024, 5, 17, 14, 37));
    });

    test('startOfHour and endOfHour', () {
      expect(moment.startOfHour, DateTime(2024, 5, 17, 14));
      expect(moment.endOfHour, DateTime(2024, 5, 17, 14, 59, 59, 999, 999));
    });

    test('startOfYear and endOfYear', () {
      expect(moment.startOfYear, DateTime(2024));
      expect(moment.endOfYear, DateTime(2024, 12, 31, 23, 59, 59, 999, 999));
    });

    test('startOfQuarter and endOfQuarter', () {
      expect(moment.startOfQuarter, DateTime(2024, 4));
      expect(moment.endOfQuarter, DateTime(2024, 6, 30, 23, 59, 59, 999, 999));
      expect(DateTime(2024, 2, 3).startOfQuarter, DateTime(2024));
    });

    test('boundaries stay in UTC for UTC inputs', () {
      final utc = DateTime.utc(2024, 5, 17, 14, 37);
      expect(utc.startOfHour.isUtc, isTrue);
      expect(utc.startOfYear, DateTime.utc(2024));
      expect(utc.startOfQuarter.isUtc, isTrue);
    });
  });

  group('DateTimeX comparison', () {
    test('isSameMonth and isSameYear', () {
      expect(DateTime(2024, 5, 1).isSameMonth(DateTime(2024, 5, 31)), isTrue);
      expect(DateTime(2024, 5, 1).isSameMonth(DateTime(2023, 5, 1)), isFalse);
      expect(DateTime(2024).isSameYear(DateTime(2024, 12, 31)), isTrue);
    });

    test('isSameWeek groups Monday through Sunday', () {
      // 2024-01-01 is a Monday, 2024-01-07 the following Sunday.
      expect(DateTime(2024).isSameWeek(DateTime(2024, 1, 7)), isTrue);
      expect(DateTime(2024).isSameWeek(DateTime(2024, 1, 8)), isFalse);
    });
  });

  group('DateTimeX calendar arithmetic', () {
    test('addMonths clamps the day to the target month', () {
      expect(DateTime(2024, 1, 31).addMonths(1), DateTime(2024, 2, 29));
      expect(DateTime(2023, 1, 31).addMonths(1), DateTime(2023, 2, 28));
      expect(DateTime(2024, 1, 15).addMonths(1), DateTime(2024, 2, 15));
    });

    test('addMonths rolls over the year', () {
      expect(DateTime(2024, 12, 15).addMonths(1), DateTime(2025, 1, 15));
      expect(DateTime(2024, 1, 15).addMonths(-1), DateTime(2023, 12, 15));
      expect(DateTime(2024, 1, 15).addMonths(24), DateTime(2026, 1, 15));
    });

    test('subtractMonths mirrors addMonths', () {
      expect(DateTime(2024, 3, 31).subtractMonths(1), DateTime(2024, 2, 29));
    });

    test('addYears and subtractYears clamp February 29', () {
      expect(DateTime(2024, 2, 29).addYears(1), DateTime(2025, 2, 28));
      expect(DateTime(2024, 2, 29).addYears(4), DateTime(2028, 2, 29));
      expect(DateTime(2024, 2, 29).subtractYears(1), DateTime(2023, 2, 28));
    });

    test('daysUntil ignores the time of day', () {
      expect(DateTime(2024, 3, 15, 23).daysUntil(DateTime(2024, 3, 20, 1)), 5);
      expect(DateTime(2024, 3, 20).daysUntil(DateTime(2024, 3, 15)), -5);
      expect(DateTime(2024, 3, 15).daysUntil(DateTime(2024, 3, 15, 22)), 0);
    });

    test('businessDaysUntil skips weekends', () {
      // Friday 2024-01-05 -> Monday 2024-01-08
      expect(DateTime(2024, 1, 5).businessDaysUntil(DateTime(2024, 1, 8)), 1);
      // Monday -> Friday of the same week
      expect(DateTime(2024).businessDaysUntil(DateTime(2024, 1, 5)), 4);
      expect(DateTime(2024).businessDaysUntil(DateTime(2024)), 0);
      // Going backwards is negative
      expect(DateTime(2024, 1, 8).businessDaysUntil(DateTime(2024, 1, 5)), -1);
    });

    test('addBusinessDays skips over the weekend', () {
      expect(DateTime(2024, 1, 5).addBusinessDays(1), DateTime(2024, 1, 8));
      expect(DateTime(2024, 1, 5).addBusinessDays(5), DateTime(2024, 1, 12));
      expect(DateTime(2024, 1, 8).addBusinessDays(-1), DateTime(2024, 1, 5));
      expect(DateTime(2024, 1, 8).addBusinessDays(0), DateTime(2024, 1, 8));
    });

    test('nextWeekday and previousWeekday are strict', () {
      // 2024-01-01 is a Monday.
      expect(DateTime(2024).nextWeekday(DateTime.monday), DateTime(2024, 1, 8));
      expect(DateTime(2024).nextWeekday(DateTime.friday), DateTime(2024, 1, 5));
      expect(
        DateTime(2024, 1, 3).previousWeekday(DateTime.monday),
        DateTime(2024),
      );
      expect(
        DateTime(2024, 1, 8).previousWeekday(DateTime.monday),
        DateTime(2024),
      );
    });

    test('weekday helpers validate their argument', () {
      expect(() => DateTime(2024).nextWeekday(0), throwsArgumentError);
      expect(() => DateTime(2024).previousWeekday(8), throwsArgumentError);
    });
  });

  group('DateTimeX formatting', () {
    final moment = DateTime(2024, 3, 5, 9, 7, 3);

    test('toDateString, toTimeString, toDateTimeString', () {
      expect(moment.toDateString(), '2024-03-05');
      expect(moment.toTimeString(), '09:07:03');
      expect(moment.toTimeString(withSeconds: false), '09:07');
      expect(moment.toDateTimeString(), '2024-03-05 09:07:03');
      expect(moment.toDateTimeString(withSeconds: false), '2024-03-05 09:07');
    });

    test('toRelativeString describes the past', () {
      final clock = DateTime(2024, 3, 5, 12);

      expect(
        DateTime(2024, 3, 5, 11, 59, 40).toRelativeString(clock: clock),
        'a few seconds ago',
      );
      expect(
        DateTime(2024, 3, 5, 11, 30).toRelativeString(clock: clock),
        '30 minutes ago',
      );
      expect(
        DateTime(2024, 3, 5, 9).toRelativeString(clock: clock),
        '3 hours ago',
      );
      expect(
        DateTime(2024, 3, 1, 12).toRelativeString(clock: clock),
        '4 days ago',
      );
      expect(
        DateTime(2023, 3, 5, 12).toRelativeString(clock: clock),
        'a year ago',
      );
    });

    test('toRelativeString describes the future', () {
      final clock = DateTime(2024, 3, 5, 12);

      expect(
        DateTime(2024, 3, 8, 12).toRelativeString(clock: clock),
        'in 3 days',
      );
      expect(
        DateTime(2024, 3, 5, 13, 30).toRelativeString(clock: clock),
        'in an hour',
      );
    });
  });

  group('DateTimeNullableX', () {
    test('toDateStringOrNull and orDate', () {
      const DateTime? missing = null;
      final fallback = DateTime(2024);

      expect(missing.toDateStringOrNull, isNull);
      expect(DateTime(2024, 3, 5).toDateStringOrNull, '2024-03-05');
      expect(missing.orDate(fallback), fallback);
      expect(DateTime(2025).orDate(fallback), DateTime(2025));
    });
  });
}
