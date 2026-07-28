import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

void main() {
  group('date_predicates', () {
    test('isDate parses ISO dates', () {
      expect(isDate('2026-07-28T00:00:00Z'), isTrue);
      expect(isDate('2026-07-28T12:00:00Z'), isTrue);
      expect(isDate('not-a-date'), isFalse);
    });

    test('isToday checks current UTC date', () {
      final nowIso = DateTime.now().toUtc().toIso8601String();
      expect(isToday(nowIso), isTrue);
      expect(isToday('2000-01-01T00:00:00Z'), isFalse);
    });

    test('isLeapYear checks leap years', () {
      expect(isLeapYear('2024-02-29T00:00:00Z'), isTrue);
      expect(isLeapYear('2025-01-01T00:00:00Z'), isFalse);
    });

    test('isWeekend and isWeekday', () {
      // 2026-07-26T00:00:00Z is a Sunday
      expect(isWeekend('2026-07-26T00:00:00Z'), isTrue);
      expect(isWeekday('2026-07-26T00:00:00Z'), isFalse);

      // 2026-07-27T00:00:00Z is a Monday
      expect(isWeekday('2026-07-27T00:00:00Z'), isTrue);
      expect(isWeekend('2026-07-27T00:00:00Z'), isFalse);
    });
  });
}
