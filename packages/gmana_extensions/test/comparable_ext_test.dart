import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('ComparableX on String', () {
    test('comparison operators', () {
      expect('a' < 'b', isTrue);
      expect('b' < 'a', isFalse);
      expect('a' <= 'a', isTrue);
      expect('c' > 'b', isTrue);
      expect('c' >= 'd', isFalse);
    });

    test('coerceIn clamps to the range', () {
      expect('m'.coerceIn('a', 'f'), 'f');
      expect('A'.coerceIn('a', 'f'), 'a');
      expect('c'.coerceIn('a', 'f'), 'c');
    });

    test('coerceIn rejects an inverted range', () {
      expect(() => 'c'.coerceIn('f', 'a'), throwsArgumentError);
    });

    test('coerceAtLeast and coerceAtMost', () {
      expect('a'.coerceAtLeast('c'), 'c');
      expect('e'.coerceAtLeast('c'), 'e');
      expect('e'.coerceAtMost('c'), 'c');
      expect('a'.coerceAtMost('c'), 'a');
    });

    test('isInRange is inclusive, isInRangeExclusive is not', () {
      expect('a'.isInRange('a', 'c'), isTrue);
      expect('d'.isInRange('a', 'c'), isFalse);
      expect('a'.isInRangeExclusive('a', 'c'), isFalse);
      expect('b'.isInRangeExclusive('a', 'c'), isTrue);
    });

    test('isBetween still resolves to the date-string extension', () {
      // StringDateExtension is more specific than ComparableX on String.
      expect('2024-06-15'.isBetween('2024-01-01', '2024-12-31'), isTrue);
    });

    test('coerceMin and coerceMax pick an extreme', () {
      expect('a'.coerceMax('b'), 'b');
      expect('a'.coerceMin('b'), 'a');
    });
  });

  group('ComparableX on DateTime', () {
    final early = DateTime(2024, 1, 1);
    final middle = DateTime(2024, 6, 1);
    final late_ = DateTime(2024, 12, 1);

    test('operators order chronologically', () {
      expect(early < middle, isTrue);
      expect(late_ > middle, isTrue);
      expect(early >= early, isTrue);
      expect(early <= early, isTrue);
    });

    test('coerceIn clamps a date to a window', () {
      expect(DateTime(2023, 1, 1).coerceIn(early, late_), early);
      expect(DateTime(2025, 1, 1).coerceIn(early, late_), late_);
      expect(middle.coerceIn(early, late_), middle);
    });

    test('isInRange covers the boundaries', () {
      expect(middle.isInRange(early, late_), isTrue);
      expect(early.isInRange(early, late_), isTrue);
      expect(late_.isInRange(early, late_), isTrue);
      expect(DateTime(2025, 1, 1).isInRange(early, late_), isFalse);
    });
  });
}
