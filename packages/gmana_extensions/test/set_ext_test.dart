import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('SetX', () {
    test('toggle adds when absent and removes when present', () {
      final selected = <int>{1, 2};

      expect(selected.toggle(3), isTrue);
      expect(selected, {1, 2, 3});
      expect(selected.toggle(2), isFalse);
      expect(selected, {1, 3});
    });

    test('toggled leaves the original untouched', () {
      final original = <int>{1, 2};
      final next = original.toggled(3);

      expect(original, {1, 2});
      expect(next, {1, 2, 3});
    });

    test('subset and superset checks', () {
      expect({1, 2}.isSubsetOf({1, 2, 3}), isTrue);
      expect({1, 4}.isSubsetOf({1, 2, 3}), isFalse);
      expect({1, 2, 3}.isSupersetOf({1, 2}), isTrue);
      expect(<int>{}.isSubsetOf({1}), isTrue);
    });

    test('proper subset and superset exclude equality', () {
      expect({1, 2}.isProperSubsetOf({1, 2}), isFalse);
      expect({1, 2}.isProperSubsetOf({1, 2, 3}), isTrue);
      expect({1, 2}.isProperSupersetOf({1, 2}), isFalse);
      expect({1, 2, 3}.isProperSupersetOf({1, 2}), isTrue);
    });

    test('intersects and isDisjointFrom', () {
      expect({1, 2}.intersects([2, 5]), isTrue);
      expect({1, 2}.intersects([5, 6]), isFalse);
      expect({1, 2}.isDisjointFrom([5, 6]), isTrue);
    });

    test('symmetricDifference keeps elements unique to one side', () {
      expect({1, 2, 3}.symmetricDifference({3, 4}), {1, 2, 4});
      expect({1, 2}.symmetricDifference({1, 2}), isEmpty);
    });

    test('symmetricDifference does not mutate the receiver', () {
      final original = {1, 2, 3};
      original.symmetricDifference({3, 4});
      expect(original, {1, 2, 3});
    });

    test('addAllNew reports only the elements actually added', () {
      final set = <int>{1, 2};
      expect(set.addAllNew([2, 3, 4]), {3, 4});
      expect(set, {1, 2, 3, 4});
    });
  });

  group('SetNullableX', () {
    test('null-safe emptiness checks', () {
      const Set<int>? missing = null;
      final empty = <int>{};
      final filled = {1};

      expect(missing.isNullOrEmpty, isTrue);
      expect(empty.isNullOrEmpty, isTrue);
      expect(filled.isNullOrEmpty, isFalse);
      expect(missing.isNotNullOrEmpty, isFalse);
      expect(filled.isNotNullOrEmpty, isTrue);
    });

    test('orEmpty substitutes an empty set', () {
      const Set<String>? missing = null;
      expect(missing.orEmpty, isEmpty);
      expect({'a'}.orEmpty, {'a'});
    });
  });
}
