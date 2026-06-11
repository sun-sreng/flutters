import 'package:gmana_extensions/string_date_ext.dart';
import 'package:test/test.dart';

void main() {
  group('StringDateExtension', () {
    group('isDate', () {
      test('returns true for parseable ISO 8601 date strings', () {
        expect('2024-03-15'.isDate, isTrue);
        expect('2024-03-15T10:30:00Z'.isDate, isTrue);
        expect(' 2024-03-15 '.isDate, isTrue);
      });

      test('returns false for non-date strings', () {
        expect('hello'.isDate, isFalse);
        expect(''.isDate, isFalse);
      });
    });

    group('parsing and parts', () {
      test('toDateTimeOrNull parses valid dates strictly', () {
        expect('2024-03-15'.toDateTimeOrNull, isA<DateTime>());
        expect(' 2024-03-15T10:30:00Z '.toDateTimeOrNull, isA<DateTime>());
        expect('2024-02-31'.toDateTimeOrNull, isNull);
        expect('not-a-date'.toDateTimeOrNull, isNull);
      });

      test('toDateTime throws for invalid date strings', () {
        expect('2024-03-15'.toDateTime, isA<DateTime>());
        expect(() => 'not-a-date'.toDateTime, throwsFormatException);
      });

      test('date part getters return nullable parts', () {
        expect('2024-03-15'.year, 2024);
        expect('2024-03-15'.month, 3);
        expect('2024-03-15'.day, 15);
        expect('2024-03-15'.weekday, DateTime.friday);
        expect('not-a-date'.year, isNull);
      });

      test('toIsoDateString formats date portion', () {
        expect('2024-03-15T10:30:00'.toIsoDateString, '2024-03-15');
        expect('not-a-date'.toIsoDateString, isNull);
      });
    });

    group('date comparison', () {
      test('isAfter compares against a reference date', () {
        expect('2024-03-16'.isAfter('2024-03-15'), isTrue);
        expect('2024-03-15'.isAfter('2024-03-15'), isFalse);
        expect('2024-03-14'.isAfter('2024-03-15'), isFalse);
      });

      test('isBefore compares against a reference date', () {
        expect('2024-03-14'.isBefore('2024-03-15'), isTrue);
        expect('2024-03-15'.isBefore('2024-03-15'), isFalse);
        expect('2024-03-16'.isBefore('2024-03-15'), isFalse);
      });

      test('isBetween returns true only within an exclusive range', () {
        expect('2024-06-15'.isBetween('2024-01-01', '2024-12-31'), isTrue);
        expect('2024-01-01'.isBetween('2024-01-01', '2024-12-31'), isFalse);
        expect('2024-12-31'.isBetween('2024-01-01', '2024-12-31'), isFalse);
        expect('2023-12-31'.isBetween('2024-01-01', '2024-12-31'), isFalse);
      });

      test('isBetweenInclusive includes boundaries', () {
        expect(
          '2024-01-01'.isBetweenInclusive('2024-01-01', '2024-12-31'),
          isTrue,
        );
        expect(
          '2024-12-31'.isBetweenInclusive('2024-01-01', '2024-12-31'),
          isTrue,
        );
        expect(
          '2023-12-31'.isBetweenInclusive('2024-01-01', '2024-12-31'),
          isFalse,
        );
        expect(
          '2024-06-01'.isBetweenInclusive('2024-12-31', '2024-01-01'),
          isFalse,
        );
        expect(
          'not-a-date'.isBetweenInclusive('2024-01-01', '2024-12-31'),
          isFalse,
        );
      });

      test('isSameDayAs compares calendar dates', () {
        expect(
          '2024-03-15T10:30:00'.isSameDayAs('2024-03-15T20:00:00'),
          isTrue,
        );
        expect('2024-03-15'.isSameDayAs('2024-03-16'), isFalse);
        expect('not-a-date'.isSameDayAs('2024-03-15'), isFalse);
      });

      test('differenceFrom and daysUntil compare valid dates', () {
        expect(
          '2024-03-16'.differenceFrom('2024-03-15'),
          const Duration(days: 1),
        );
        expect('2024-03-15'.daysUntil('2024-03-20'), 5);
        expect('2024-03-20'.daysUntil('2024-03-15'), -5);
        expect('not-a-date'.differenceFrom('2024-03-15'), isNull);
        expect('2024-03-15'.daysUntil('not-a-date'), isNull);
      });
    });

    group('relative date checks', () {
      test('isToday matches the current UTC calendar date', () {
        final now = DateTime.now().toUtc();
        final today = DateTime.utc(now.year, now.month, now.day);

        expect(today.toIso8601String().isToday, isTrue);
      });

      test('isPast and isFuture compare against now', () {
        expect('2000-01-01'.isPast, isTrue);
        expect('2999-01-01'.isFuture, isTrue);
        expect('2000-01-01'.isFuture, isFalse);
        expect('2999-01-01'.isPast, isFalse);
      });
    });

    group('calendar properties', () {
      test('isWeekend identifies Saturday and Sunday', () {
        expect('2024-03-16T12:00:00Z'.isWeekend, isTrue);
        expect('2024-03-17T12:00:00Z'.isWeekend, isTrue);
        expect('2024-03-15T12:00:00Z'.isWeekend, isFalse);
      });

      test('isWeekday identifies Monday through Friday', () {
        expect('2024-03-15T12:00:00Z'.isWeekday, isTrue);
        expect('2024-03-18T12:00:00Z'.isWeekday, isTrue);
        expect('2024-03-16T12:00:00Z'.isWeekday, isFalse);
      });

      test('isLeapYear applies leap year rules', () {
        expect('2024-01-01T12:00:00Z'.isLeapYear, isTrue);
        expect('2023-01-01T12:00:00Z'.isLeapYear, isFalse);
        expect('2000-01-01T12:00:00Z'.isLeapYear, isTrue);
        expect('1900-01-01T12:00:00Z'.isLeapYear, isFalse);
      });
    });

    group('date arithmetic', () {
      test('addDays and subtractDays return ISO date strings', () {
        expect('2024-02-28'.addDays(1), '2024-02-29');
        expect('2024-03-01'.subtractDays(1), '2024-02-29');
        expect('not-a-date'.addDays(1), isNull);
      });
    });

    test('date utilities return false for invalid date strings', () {
      expect('not-a-date'.isAfter('2024-01-01'), isFalse);
      expect('not-a-date'.isBefore('2024-01-01'), isFalse);
      expect('not-a-date'.isBetween('2024-01-01', '2024-12-31'), isFalse);
      expect('not-a-date'.isToday, isFalse);
      expect('not-a-date'.isPast, isFalse);
      expect('not-a-date'.isFuture, isFalse);
      expect('not-a-date'.isWeekend, isFalse);
      expect('not-a-date'.isWeekday, isFalse);
      expect('not-a-date'.isLeapYear, isFalse);
    });
  });
}
