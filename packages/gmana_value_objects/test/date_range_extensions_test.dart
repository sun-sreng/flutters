import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaDateRangeX', () {
    final first = DateRange(
      start: DateTime.utc(2026, 1, 1),
      end: DateTime.utc(2026, 1, 10),
    );
    final overlapping = DateRange(
      start: DateTime.utc(2026, 1, 5),
      end: DateTime.utc(2026, 1, 15),
    );
    final touching = DateRange(
      start: DateTime.utc(2026, 1, 10),
      end: DateTime.utc(2026, 1, 20),
    );
    final disjoint = DateRange(
      start: DateTime.utc(2026, 2, 1),
      end: DateTime.utc(2026, 2, 5),
    );

    test(
      'detects overlapping, touching, and disjoint ranges symmetrically',
      () {
        expect(first.overlaps(overlapping), isTrue);
        expect(overlapping.overlaps(first), isTrue);
        expect(first.overlaps(touching), isTrue);
        expect(touching.overlaps(first), isTrue);
        expect(first.overlaps(disjoint), isFalse);
        expect(disjoint.overlaps(first), isFalse);
      },
    );

    test('detects contained and equal ranges', () {
      final inner = DateRange(
        start: DateTime.utc(2026, 1, 2),
        end: DateTime.utc(2026, 1, 9),
      );

      expect(first.containsRange(inner), isTrue);
      expect(first.containsRange(first), isTrue);
      expect(inner.containsRange(first), isFalse);
      expect(first.containsRange(overlapping), isFalse);
    });

    test('returns the inclusive intersection or null when disjoint', () {
      expect(
        first.intersection(overlapping),
        DateRange(
          start: DateTime.utc(2026, 1, 5),
          end: DateTime.utc(2026, 1, 10),
        ),
      );
      expect(
        first.intersection(touching),
        DateRange(
          start: DateTime.utc(2026, 1, 10),
          end: DateTime.utc(2026, 1, 10),
        ),
      );
      expect(first.intersection(disjoint), isNull);
    });

    test('spans ranges regardless of their order or separation', () {
      final expected = DateRange(
        start: DateTime.utc(2026, 1, 1),
        end: DateTime.utc(2026, 2, 5),
      );

      expect(first.span(disjoint), expected);
      expect(disjoint.span(first), expected);
      expect(first.span(first), first);
    });

    test('is exported as a named extension', () {
      expect(GmanaDateRangeX(first).overlaps(overlapping), isTrue);
    });
  });
}
