import 'dart:math' as math;

import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

class _Person {
  const _Person(this.name, this.age);

  final String name;
  final int age;

  @override
  String toString() => name;
}

const _people = [_Person('Ada', 36), _Person('Grace', 45), _Person('Alan', 41)];

void main() {
  group('IterableX safe access', () {
    test('firstOrNull and lastOrNull', () {
      expect([1, 2, 3].firstOrNull, 1);
      expect([1, 2, 3].lastOrNull, 3);
      expect(<int>[].firstOrNull, isNull);
      expect(<int>[].lastOrNull, isNull);
    });

    test('firstOrNull works on lazy iterables', () {
      expect([1, 2, 3].where((e) => e > 2).firstOrNull, 3);
      expect([1, 2, 3].where((e) => e > 9).firstOrNull, isNull);
    });

    test('elementAtOrNull returns null instead of throwing', () {
      expect([1, 2, 3].elementAtOrNull(1), 2);
      expect([1, 2, 3].elementAtOrNull(5), isNull);
      expect([1, 2, 3].elementAtOrNull(-1), isNull);
    });
  });

  group('IterableX predicates', () {
    test('none is the inverse of any', () {
      expect([1, 2, 3].none((e) => e > 5), isTrue);
      expect([1, 2, 3].none((e) => e > 2), isFalse);
      expect(<int>[].none((e) => true), isTrue);
    });

    test('countWhere counts matches', () {
      expect([1, 2, 3, 4].countWhere((e) => e.isEven), 2);
      expect(<int>[].countWhere((e) => true), 0);
    });

    test('whereNot inverts the filter', () {
      expect([1, 2, 3, 4].whereNot((e) => e.isEven).toList(), [1, 3]);
    });

    test('mapNotNull drops null results', () {
      expect(['1', 'x', '3'].mapNotNull(int.tryParse).toList(), [1, 3]);
    });
  });

  group('IterableX indexed variants', () {
    test('mapIndexed exposes the index', () {
      expect(['a', 'b'].mapIndexed((i, e) => '$i:$e').toList(), ['0:a', '1:b']);
    });

    test('whereIndexed filters on the index', () {
      expect([10, 20, 30, 40].whereIndexed((i, _) => i.isEven).toList(), [
        10,
        30,
      ]);
    });

    test('forEachIndexed visits every element with its index', () {
      final seen = <String>[];
      ['a', 'b'].forEachIndexed((i, e) => seen.add('$i$e'));
      expect(seen, ['0a', '1b']);
    });

    test('foldIndexed threads the index through', () {
      final result = [10, 20, 30].foldIndexed<int>(
        0,
        (index, previous, element) => previous + index * element,
      );
      expect(result, 0 * 10 + 1 * 20 + 2 * 30);
    });
  });

  group('IterableX zipping', () {
    test('zip stops at the shorter iterable', () {
      expect([1, 2, 3].zip(['a', 'b']).toList(), [(1, 'a'), (2, 'b')]);
      expect(<int>[].zip(['a']).toList(), isEmpty);
    });

    test('zipWith combines the pairs', () {
      expect([1, 2].zipWith(['a', 'b'], (n, s) => '$s$n').toList(), [
        'a1',
        'b2',
      ]);
    });
  });

  group('IterableX ordering', () {
    test('sortedBy leaves the source untouched', () {
      final source = [3, 1, 2];
      expect(source.sortedBy((e) => e), [1, 2, 3]);
      expect(source, [3, 1, 2]);
    });

    test('sortedByDescending reverses the order', () {
      expect(_people.sortedByDescending((p) => p.age).first.name, 'Grace');
    });

    test('sortedBy works on string keys', () {
      expect(_people.sortedBy((p) => p.name).map((p) => p.name).toList(), [
        'Ada',
        'Alan',
        'Grace',
      ]);
    });

    test('sortedWith takes a comparator', () {
      expect([3, 1, 2].sortedWith((a, b) => b.compareTo(a)), [3, 2, 1]);
    });

    test('maxBy and minBy select the extreme element', () {
      expect(_people.maxBy((p) => p.age)?.name, 'Grace');
      expect(_people.minBy((p) => p.age)?.name, 'Ada');
      expect(<_Person>[].maxBy((p) => p.age), isNull);
    });

    test('maxBy keeps the first of equal keys', () {
      const tie = [_Person('First', 40), _Person('Second', 40)];
      expect(tie.maxBy((p) => p.age)?.name, 'First');
      expect(tie.minBy((p) => p.age)?.name, 'First');
    });
  });

  group('IterableX aggregation', () {
    test('sumBy totals a projection', () {
      expect(_people.sumBy((p) => p.age), 122);
      expect(<_Person>[].sumBy((p) => p.age), 0);
    });

    test('averageBy returns null for an empty iterable', () {
      expect(_people.averageBy((p) => p.age), closeTo(40.666, 0.001));
      expect(<_Person>[].averageBy((p) => p.age), isNull);
    });
  });

  group('IterableX joinToString', () {
    test('applies prefix, suffix, and separator', () {
      expect(
        [1, 2, 3].joinToString(prefix: '[', suffix: ']', separator: ' | '),
        '[1 | 2 | 3]',
      );
    });

    test('applies the transform', () {
      expect([1, 2].joinToString(transform: (e) => 'n$e'), 'n1, n2');
    });

    test('truncates at the limit', () {
      expect(
        [1, 2, 3, 4].joinToString(prefix: '[', suffix: ']', limit: 2),
        '[1, 2, ...]',
      );
    });

    test('does not truncate when the limit is not reached', () {
      expect([1, 2].joinToString(limit: 5), '1, 2');
    });

    test('rejects a negative limit', () {
      expect(() => [1].joinToString(limit: -1), throwsArgumentError);
    });
  });

  group('IterableX splitWhen and randomOrNull', () {
    test('splitWhen starts a new run on a gap', () {
      expect([1, 2, 5, 6, 10].splitWhen((a, b) => b - a > 1).toList(), [
        [1, 2],
        [5, 6],
        [10],
      ]);
    });

    test('splitWhen returns nothing for an empty iterable', () {
      expect(<int>[].splitWhen((a, b) => true).toList(), isEmpty);
    });

    test('randomOrNull is deterministic with a seeded Random', () {
      final picked = [1, 2, 3, 4, 5].randomOrNull(math.Random(42));
      expect(picked, [1, 2, 3, 4, 5].randomOrNull(math.Random(42)));
      expect(picked, isIn([1, 2, 3, 4, 5]));
    });

    test('randomOrNull returns null when empty', () {
      expect(<int>[].randomOrNull(), isNull);
    });
  });

  group('ListX index-safe access', () {
    test('isValidIndex, getOrNull, and getOrElse', () {
      final list = [1, 2, 3];

      expect(list.isValidIndex(2), isTrue);
      expect(list.isValidIndex(3), isFalse);
      expect(list.getOrNull(1), 2);
      expect(list.getOrNull(9), isNull);
      expect(list.getOrElse(9, (i) => -i), -9);
    });
  });

  group('ListX reordering', () {
    test('swap mutates in place', () {
      final list = [1, 2, 3];
      list.swap(0, 2);
      expect(list, [3, 2, 1]);
    });

    test('swap validates its indices', () {
      expect(() => [1, 2].swap(0, 5), throwsRangeError);
    });

    test('swapped leaves the source untouched', () {
      final source = [1, 2, 3];
      expect(source.swapped(0, 2), [3, 2, 1]);
      expect(source, [1, 2, 3]);
    });

    test('moved relocates an element', () {
      expect(['a', 'b', 'c'].moved(0, 2), ['b', 'c', 'a']);
      expect(['a', 'b', 'c'].moved(2, 0), ['c', 'a', 'b']);
    });

    test('rotated shifts left for positive and right for negative', () {
      expect([1, 2, 3, 4].rotated(1), [2, 3, 4, 1]);
      expect([1, 2, 3, 4].rotated(-1), [4, 1, 2, 3]);
      expect([1, 2, 3, 4].rotated(4), [1, 2, 3, 4]);
      expect(<int>[].rotated(2), isEmpty);
    });

    test('shuffled is deterministic with a seeded Random', () {
      final source = [1, 2, 3, 4, 5];
      expect(source.shuffled(math.Random(7)), source.shuffled(math.Random(7)));
      expect(source, [1, 2, 3, 4, 5]);
    });
  });

  group('ListX transformation', () {
    test('replaceWhere rewrites only the matches', () {
      expect([1, 2, 3, 4].replaceWhere((e) => e.isEven, (e) => e * 10), [
        1,
        20,
        3,
        40,
      ]);
    });

    test('distinct preserves first-seen order', () {
      expect([3, 1, 3, 2, 1].distinct(), [3, 1, 2]);
    });

    test('takeLast and dropLast', () {
      final list = [1, 2, 3, 4];

      expect(list.takeLast(2), [3, 4]);
      expect(list.takeLast(9), [1, 2, 3, 4]);
      expect(list.takeLast(0), isEmpty);
      expect(list.dropLast(2), [1, 2]);
      expect(list.dropLast(9), isEmpty);
    });

    test('takeLast and dropLast reject negative counts', () {
      expect(() => [1].takeLast(-1), throwsArgumentError);
      expect(() => [1].dropLast(-1), throwsArgumentError);
    });
  });

  group('ListNullableX', () {
    test('null-safe helpers', () {
      const List<int>? missing = null;

      expect(missing.isNullOrEmpty, isTrue);
      expect(<int>[].isNullOrEmpty, isTrue);
      expect([1].isNotNullOrEmpty, isTrue);
      expect(missing.orEmpty, isEmpty);
    });
  });
}
