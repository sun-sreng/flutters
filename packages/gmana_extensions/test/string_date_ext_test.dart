import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('StringDateX', () {
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

    group('date arithmetic', () {
      test('addDays and subtractDays return ISO date strings', () {
        expect('2024-02-28'.addDays(1), '2024-02-29');
        expect('2024-03-01'.subtractDays(1), '2024-02-29');
        expect('not-a-date'.addDays(1), isNull);
      });
    });
  });
}
