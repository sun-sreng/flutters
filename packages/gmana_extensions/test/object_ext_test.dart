import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

/// Keeps the static type nullable so the nullable extensions are exercised.
String? _maybe(String? value) => value;

void main() {
  group('ScopeFunctionsX', () {
    test('let transforms the receiver', () {
      expect('hello'.let((s) => s.length), 5);
      expect(21.let((n) => n * 2), 42);
    });

    test('also runs a side effect and returns the receiver', () {
      final seen = <int>[];
      final result = 7.also(seen.add);

      expect(result, 7);
      expect(seen, [7]);
    });

    test('takeIf keeps the value only when the predicate holds', () {
      expect('admin'.takeIf((s) => s.isNotEmpty), 'admin');
      expect(''.takeIf((s) => s.isNotEmpty), isNull);
    });

    test('takeUnless is the inverse of takeIf', () {
      expect(''.takeUnless((s) => s.isEmpty), isNull);
      expect('x'.takeUnless((s) => s.isEmpty), 'x');
    });

    test('asOrNull casts safely', () {
      const Object value = 'text';
      expect(value.asOrNull<String>(), 'text');
      expect(value.asOrNull<int>(), isNull);
    });

    test('asOrNull works through supertypes', () {
      const Object numbers = <int>[1, 2];
      expect(numbers.asOrNull<List<int>>(), [1, 2]);
      expect(numbers.asOrNull<Map<String, int>>(), isNull);
    });
  });

  group('ObjectNullableX', () {
    test('isNull and isNotNull', () {
      const String? missing = null;
      final present = _maybe('a');

      expect(missing.isNull, isTrue);
      expect(missing.isNotNull, isFalse);
      expect(present.isNull, isFalse);
      expect(present.isNotNull, isTrue);
    });

    test('letOrNull only runs for non-null values', () {
      const String? missing = null;
      final present = _maybe('abc');

      expect(missing.letOrNull((s) => s.length), isNull);
      expect(present.letOrNull((s) => s.length), 3);
    });

    test('alsoNotNull runs the side effect only when present', () {
      final seen = <String>[];
      const String? missing = null;
      final present = _maybe('ok');

      expect(missing.alsoNotNull(seen.add), isNull);
      expect(present.alsoNotNull(seen.add), 'ok');
      expect(seen, ['ok']);
    });

    test('orElseGet computes the fallback lazily', () {
      var calls = 0;
      String fallback() {
        calls++;
        return 'default';
      }

      final present = _maybe('value');
      const String? missing = null;

      expect(present.orElseGet(fallback), 'value');
      expect(calls, 0);
      expect(missing.orElseGet(fallback), 'default');
      expect(calls, 1);
    });

    test('does not shadow the more specific nullable extensions', () {
      const int? number = null;
      const bool? flag = null;

      expect(number.orZero, 0);
      expect(number.orDefault(9), 9);
      expect(flag.orDefault(fallback: true), isTrue);
    });
  });
}
