import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('DateRangeValue', () {
    final start = DateTime.utc(2026, 1, 1);
    final end = DateTime.utc(2026, 12, 31);

    test('parses valid date range', () {
      final result = DateRangeValue.tryParse(start, end);

      expect(result.isRight(), isTrue);
      final range = result.rightOrNull()!.value;
      expect(range.start, equals(start));
      expect(range.end, equals(end));
      expect(range.contains(DateTime.utc(2026, 6, 15)), isTrue);
    });

    test('rejects invalid order when start is after end', () {
      final result = DateRangeValue.tryParse(end, start);

      expect(result.isLeft(), isTrue);
      expect(result.leftOrNull(), isA<DateRangeInvalidOrder>());
    });

    test('constructor throws ValueObjectException on invalid order', () {
      expect(
        () => DateRangeValue(end, start),
        throwsA(isA<ValueObjectException>()),
      );
    });
  });
}
