import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('MapX', () {
    test('whereKeys filters by key predicate', () {
      final map = {'a': 1, 'b': 2, 'aa': 3};
      expect(map.whereKeys((k) => k.startsWith('a')), {'a': 1, 'aa': 3});
    });

    test('whereValues filters by value predicate', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      expect(map.whereValues((v) => v.isEven), {'b': 2});
    });

    test('where filters by key and value predicate', () {
      final map = {'a': 10, 'b': 20, 'c': 30};
      expect(map.where((k, v) => k == 'b' || v > 20), {'b': 20, 'c': 30});
    });

    test('mapKeys transforms keys', () {
      final map = {'a': 1, 'b': 2};
      expect(map.mapKeys((k, v) => k.toUpperCase()), {'A': 1, 'B': 2});
    });

    test('mapValues transforms values', () {
      final map = {'a': 1, 'b': 2};
      expect(map.mapValues((k, v) => v * 10), {'a': 10, 'b': 20});
    });

    test('invert swaps keys and values', () {
      final map = {'a': 1, 'b': 2};
      expect(map.invert(), {1: 'a', 2: 'b'});
    });

    test('merge merges maps with collision handling', () {
      final m1 = {'a': 1, 'b': 2};
      final m2 = {'b': 20, 'c': 3};

      expect(m1.merge(m2), {'a': 1, 'b': 20, 'c': 3});
      expect(m1.merge(m2, combine: (oldV, newV) => oldV + newV), {
        'a': 1,
        'b': 22,
        'c': 3,
      });
    });

    test('whereNotNullValues / compact removes null values', () {
      final map = <String, int?>{'a': 1, 'b': null, 'c': 3};
      expect(map.whereNotNullValues, {'a': 1, 'c': 3});
      expect(map.compact(), {'a': 1, 'c': 3});
    });
  });

  group('MapNullableX', () {
    test('isNullOrEmpty and isNotNullOrEmpty', () {
      Map<String, int>? nullMap;
      final emptyMap = <String, int>{};
      final nonEmpyMap = {'a': 1};

      expect(nullMap.isNullOrEmpty, isTrue);
      expect(nullMap.isNotNullOrEmpty, isFalse);

      expect(emptyMap.isNullOrEmpty, isTrue);
      expect(emptyMap.isNotNullOrEmpty, isFalse);

      expect(nonEmpyMap.isNullOrEmpty, isFalse);
      expect(nonEmpyMap.isNotNullOrEmpty, isTrue);
    });

    test('orEmpty fallback', () {
      Map<String, int>? nullMap;
      expect(nullMap.orEmpty, isEmpty);

      final map = {'a': 1};
      expect(map.orEmpty, {'a': 1});
    });
  });
}
