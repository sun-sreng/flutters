import 'package:gmana/extensions.dart';
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

      test('toDateTimeOrNull keeps local time unless a zone is given', () {
        expect('2024-03-15'.toDateTimeOrNull!.isUtc, isFalse);
        expect('2024-03-15T10:30:00'.toDateTimeOrNull!.isUtc, isFalse);
        expect(
          '2024-03-15T10:30:00Z'.toDateTimeOrNull,
          DateTime.utc(2024, 3, 15, 10, 30),
        );
      });

      test('toDateTimeOrNull accepts an offset that crosses midnight', () {
        expect(
          '2024-06-15T23:00:00-05:00'.toDateTimeOrNull,
          DateTime.utc(2024, 6, 16, 4),
        );
      });

      test('toDateTimeOrNull rejects a local time that overflows the day', () {
        expect('2024-06-15T24:00:00'.toDateTimeOrNull, isNull);
        expect('2024-13-01'.toDateTimeOrNull, isNull);
        expect('2023-02-29'.toDateTimeOrNull, isNull);
        expect('2024-02-29'.toDateTimeOrNull, isNotNull);
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
