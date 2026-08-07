import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

/// An ISO date [days] away from today (UTC), so the tests stay correct
/// whenever they are run.
String daysFromNow(int days) {
  final target = DateTime.now().toUtc().add(Duration(days: days));
  final month = target.month.toString().padLeft(2, '0');
  final day = target.day.toString().padLeft(2, '0');
  return '${target.year}-$month-$day';
}

void main() {
  group('tryParseDate reads a bare date as a UTC calendar day', () {
    test('does not shift the day by the local offset', () {
      final parsed = tryParseDate('2024-06-15')!;

      expect(parsed.isUtc, isTrue);
      expect(parsed.year, 2024);
      expect(parsed.month, 6);
      expect(parsed.day, 15);
      expect(parsed.hour, 0);
    });

    test('so weekday predicates answer the same in every timezone', () {
      // 2024-01-13 is a Saturday and 2024-01-15 a Monday. Read as *local*
      // midnight these shift a day east of Greenwich, which is what the
      // previous implementation did.
      expect(isWeekend('2024-01-13'), isTrue);
      expect(isWeekend('2024-01-15'), isFalse);
      expect(isWeekday('2024-01-15'), isTrue);
    });

    test('a value carrying a time but no zone is still local', () {
      final local = tryParseDate('2024-06-15T00:00:00')!;
      final expected = DateTime(2024, 6, 15).toUtc();

      expect(local, expected);
    });

    test('an explicit zone is honoured', () {
      expect(
        tryParseDate('2024-06-15T10:30:00+07:00'),
        DateTime.utc(2024, 6, 15, 3, 30),
      );
    });
  });

  group('isBetweenInclusive', () {
    test('accepts a date strictly inside the range', () {
      expect(
        isBetweenInclusive('2024-06-15', '2024-01-01', '2024-12-31'),
        isTrue,
      );
    });

    test('accepts both bounds, unlike the exclusive isBetween', () {
      expect(
        isBetweenInclusive('2024-01-01', '2024-01-01', '2024-12-31'),
        isTrue,
      );
      expect(
        isBetweenInclusive('2024-12-31', '2024-01-01', '2024-12-31'),
        isTrue,
      );

      expect(isBetween('2024-01-01', '2024-01-01', '2024-12-31'), isFalse);
      expect(isBetween('2024-12-31', '2024-01-01', '2024-12-31'), isFalse);
    });

    test('rejects dates outside the range', () {
      expect(
        isBetweenInclusive('2023-12-31', '2024-01-01', '2024-12-31'),
        isFalse,
      );
    });

    test('rejects unparseable input', () {
      expect(isBetweenInclusive('nope', '2024-01-01', '2024-12-31'), isFalse);
      expect(isBetweenInclusive('2024-06-15', 'nope', '2024-12-31'), isFalse);
      expect(isBetweenInclusive('2024-06-15', '2024-01-01', 'nope'), isFalse);
    });
  });

  group('isYesterday and isTomorrow', () {
    test('recognise the adjacent days', () {
      expect(isYesterday(daysFromNow(-1)), isTrue);
      expect(isTomorrow(daysFromNow(1)), isTrue);
    });

    test('do not match today or dates further out', () {
      expect(isYesterday(daysFromNow(0)), isFalse);
      expect(isTomorrow(daysFromNow(0)), isFalse);
      expect(isYesterday(daysFromNow(-2)), isFalse);
      expect(isTomorrow(daysFromNow(2)), isFalse);
    });

    test('reject unparseable input', () {
      expect(isYesterday('nope'), isFalse);
      expect(isTomorrow('nope'), isFalse);
    });
  });

  group('isSameWeek', () {
    test('groups dates sharing a Monday-start week', () {
      // 2024-06-10 is a Monday; 2024-06-16 is the Sunday that closes the week.
      expect(isSameWeek('2024-06-10', '2024-06-16'), isTrue);
      expect(isSameWeek('2024-06-12', '2024-06-14'), isTrue);
    });

    test('separates the Sunday from the Monday that follows it', () {
      expect(isSameWeek('2024-06-16', '2024-06-17'), isFalse);
    });

    test('spans a month and a year boundary', () {
      // 2024-12-30 is a Monday, so it shares a week with 2025-01-01.
      expect(isSameWeek('2024-12-30', '2025-01-01'), isTrue);
    });

    test('rejects unparseable input', () {
      expect(isSameWeek('nope', '2024-06-10'), isFalse);
    });
  });

  group('isWithinLast', () {
    test('accepts a recent past date', () {
      expect(isWithinLast(daysFromNow(-3), const Duration(days: 30)), isTrue);
    });

    test('rejects a date older than the window', () {
      expect(isWithinLast(daysFromNow(-60), const Duration(days: 30)), isFalse);
    });

    test('rejects a future date', () {
      expect(isWithinLast(daysFromNow(1), const Duration(days: 30)), isFalse);
    });
  });

  group('isWithinNext', () {
    test('accepts a date soon in the future', () {
      expect(isWithinNext(daysFromNow(3), const Duration(days: 30)), isTrue);
    });

    test('rejects a date beyond the window', () {
      expect(isWithinNext(daysFromNow(60), const Duration(days: 30)), isFalse);
    });

    test('rejects a past date', () {
      expect(isWithinNext(daysFromNow(-1), const Duration(days: 30)), isFalse);
    });
  });

  group('isStartOfMonth and isEndOfMonth', () {
    test('identify the first day', () {
      expect(isStartOfMonth('2024-06-01'), isTrue);
      expect(isStartOfMonth('2024-06-02'), isFalse);
    });

    test('identify the last day across differing month lengths', () {
      expect(isEndOfMonth('2024-01-31'), isTrue);
      expect(isEndOfMonth('2024-04-30'), isTrue);
      expect(isEndOfMonth('2024-04-29'), isFalse);
    });

    test('handle February in leap and common years', () {
      expect(isEndOfMonth('2024-02-29'), isTrue);
      expect(isEndOfMonth('2024-02-28'), isFalse);
      expect(isEndOfMonth('2023-02-28'), isTrue);
    });

    test('handle December, where the next month rolls the year', () {
      expect(isEndOfMonth('2024-12-31'), isTrue);
      expect(isEndOfMonth('2024-12-30'), isFalse);
    });
  });

  group('isAgeAtLeast', () {
    test('accepts someone comfortably older', () {
      expect(isAgeAtLeast('1990-01-01', 18), isTrue);
    });

    test('rejects someone too young', () {
      expect(isAgeAtLeast(daysFromNow(-365), 18), isFalse);
    });

    test('the birthday itself counts', () {
      final eighteenYearsAgo = DateTime.now().toUtc();
      final birth = DateTime.utc(
        eighteenYearsAgo.year - 18,
        eighteenYearsAgo.month,
        eighteenYearsAgo.day,
      );
      final iso = birth.toIso8601String().substring(0, 10);

      expect(isAgeAtLeast(iso, 18), isTrue);
    });

    test('the day before the birthday does not', () {
      final now = DateTime.now().toUtc();
      final birth = DateTime.utc(
        now.year - 18,
        now.month,
        now.day,
      ).add(const Duration(days: 1));
      final iso = birth.toIso8601String().substring(0, 10);

      expect(isAgeAtLeast(iso, 18), isFalse);
    });

    test('rejects a future birth date and unparseable input', () {
      expect(isAgeAtLeast(daysFromNow(30), 0), isFalse);
      expect(isAgeAtLeast('nope', 18), isFalse);
    });
  });

  group('isIso8601', () {
    test('accepts dates and date-times in the T form', () {
      expect(isIso8601('2024-06-15'), isTrue);
      expect(isIso8601('2024-06-15T10:30'), isTrue);
      expect(isIso8601('2024-06-15T10:30:00'), isTrue);
      expect(isIso8601('2024-06-15T10:30:00.123'), isTrue);
      expect(isIso8601('2024-06-15T10:30:00Z'), isTrue);
      expect(isIso8601('2024-06-15T10:30:00+07:00'), isTrue);
    });

    test('is stricter than isDate about the space-separated form', () {
      expect(isDate('2024-06-15 10:30:00'), isTrue);
      expect(isIso8601('2024-06-15 10:30:00'), isFalse);
    });

    test('rejects other layouts', () {
      expect(isIso8601('15/06/2024'), isFalse);
      expect(isIso8601('2024-6-15'), isFalse);
      expect(isIso8601(''), isFalse);
    });

    test('rejects out-of-range components that isDate rolls over', () {
      expect(isIso8601('2024-13-01'), isFalse);
      expect(isIso8601('2023-02-29'), isFalse);
      expect(isIso8601('2024-06-31'), isFalse);

      // isDate accepts them because DateTime.tryParse rolls them forward.
      expect(isDate('2024-13-01'), isTrue);
      expect(isIso8601('2024-02-29'), isTrue, reason: '2024 is a leap year');
    });
  });

  group('fluent extensions for the new date predicates', () {
    test('mirror the top-level functions', () {
      expect(daysFromNow(-1).isYesterday, isTrue);
      expect(daysFromNow(1).isTomorrow, isTrue);
      expect('2024-06-15T10:30:00Z'.isIso8601, isTrue);
      expect('2024-06-01'.isStartOfMonth, isTrue);
      expect('2024-02-29'.isEndOfMonth, isTrue);
      expect('2024-06-10'.isSameWeek('2024-06-16'), isTrue);
      expect(daysFromNow(-3).isWithinLast(const Duration(days: 30)), isTrue);
      expect(daysFromNow(3).isWithinNext(const Duration(days: 30)), isTrue);
      expect('1990-01-01'.isAgeAtLeast(18), isTrue);
    });
  });
}
