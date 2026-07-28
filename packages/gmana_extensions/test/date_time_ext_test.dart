import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeX', () {
    test('isToday, isYesterday, isTomorrow', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      expect(now.isToday, isTrue);
      expect(yesterday.isYesterday, isTrue);
      expect(tomorrow.isTomorrow, isTrue);
    });

    test('isSameDay compares year, month, day', () {
      final dt1 = DateTime(2024, 3, 15, 10, 30);
      final dt2 = DateTime(2024, 3, 15, 23, 59);
      final dt3 = DateTime(2024, 3, 16, 10, 30);

      expect(dt1.isSameDay(dt2), isTrue);
      expect(dt1.isSameDay(dt3), isFalse);
    });

    test('isLeapYear', () {
      expect(DateTime(2024, 1, 1).isLeapYear, isTrue);
      expect(DateTime(2023, 1, 1).isLeapYear, isFalse);
      expect(DateTime(2000, 1, 1).isLeapYear, isTrue);
      expect(DateTime(1900, 1, 1).isLeapYear, isFalse);
    });

    test('isWeekend and isWeekday', () {
      final saturday = DateTime(2024, 3, 16); // Saturday
      final monday = DateTime(2024, 3, 18); // Monday

      expect(saturday.isWeekend, isTrue);
      expect(saturday.isWeekday, isFalse);

      expect(monday.isWeekend, isFalse);
      expect(monday.isWeekday, isTrue);
    });

    test('startOfDay and endOfDay', () {
      final dt = DateTime(2024, 5, 10, 14, 25, 36);
      expect(dt.startOfDay, DateTime(2024, 5, 10, 0, 0, 0));
      expect(dt.endOfDay, DateTime(2024, 5, 10, 23, 59, 59, 999, 999));
    });

    test('startOfMonth and endOfMonth', () {
      final dt = DateTime(2024, 2, 15);
      expect(dt.startOfMonth, DateTime(2024, 2, 1));
      expect(dt.endOfMonth, DateTime(2024, 2, 29, 23, 59, 59, 999, 999));
    });

    test('startOfWeek and endOfWeek', () {
      final wednesday = DateTime(2024, 3, 13);
      expect(wednesday.startOfWeek(), DateTime(2024, 3, 11)); // Monday
      expect(
        wednesday.endOfWeek(),
        DateTime(2024, 3, 17, 23, 59, 59, 999, 999),
      ); // Sunday
    });

    test('nextDay and previousDay', () {
      final dt = DateTime(2024, 3, 15);
      expect(dt.nextDay, DateTime(2024, 3, 16));
      expect(dt.previousDay, DateTime(2024, 3, 14));
    });

    test('age calculation', () {
      final birthday = DateTime(1990, 5, 20);
      final ref1 = DateTime(2024, 5, 19); // 33 years
      final ref2 = DateTime(2024, 5, 20); // 34 years

      expect(birthday.age(at: ref1), 33);
      expect(birthday.age(at: ref2), 34);
    });

    test('copyWith updates components', () {
      final dt = DateTime(2024, 1, 1, 10, 0);
      final updated = dt.copyWith(month: 5, day: 20, hour: 15);

      expect(updated, DateTime(2024, 5, 20, 15, 0));
    });
  });

  group('DateTimeNullableX', () {
    test('orNow returns date or now', () {
      DateTime? nullDate;
      expect(nullDate.orNow.isToday, isTrue);

      final dt = DateTime(2020, 1, 1);
      expect(dt.orNow, dt);
    });

    test('isSameDayAs safe null checking', () {
      DateTime? nullDate;
      final dt1 = DateTime(2024, 1, 1);
      final dt2 = DateTime(2024, 1, 1, 12, 0);

      expect(nullDate.isSameDayAs(dt1), isFalse);
      expect(dt1.isSameDayAs(nullDate), isFalse);
      expect(dt1.isSameDayAs(dt2), isTrue);
    });
  });
}
