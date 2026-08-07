import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

void main() {
  group('Option.filter', () {
    test('keeps a Some whose value passes the test', () {
      expect(const Some(4).filter((n) => n.isEven), const Some(4));
    });

    test('drops a Some whose value fails the test', () {
      expect(const Some(3).filter((n) => n.isEven), const None<int>());
    });

    test('leaves a None alone without calling the test', () {
      var called = false;
      final result = const None<int>().filter((n) {
        called = true;
        return true;
      });

      expect(result, const None<int>());
      expect(called, isFalse);
    });

    test('filterNot is the inverse of filter', () {
      expect(const Some(3).filterNot((n) => n.isEven), const Some(3));
      expect(const Some(4).filterNot((n) => n.isEven), const None<int>());
    });
  });

  group('Option.orElse', () {
    test('keeps the present value and skips the fallback', () {
      var evaluated = false;
      final result = const Some(1).orElse(() {
        evaluated = true;
        return const Some(2);
      });

      expect(result, const Some(1));
      expect(evaluated, isFalse);
    });

    test('falls through to the alternative when absent', () {
      expect(const None<int>().orElse(() => const Some(2)), const Some(2));
    });

    test('chains through several absent sources', () {
      Option<String> lookup(Map<String, String> source, String key) =>
          Option.fromNullable(source[key]);

      final result = lookup(const {}, 'theme')
          .orElse(() => lookup(const {}, 'theme'))
          .orElse(() => lookup(const {'theme': 'dark'}, 'theme'));

      expect(result, const Some('dark'));
    });
  });

  group('Option.tap', () {
    test('observes a present value and passes the option through', () {
      final seen = <int>[];
      final result = const Some(7).tap(seen.add);

      expect(result, const Some(7));
      expect(seen, [7]);
    });

    test('tap does nothing for None', () {
      final seen = <int>[];

      expect(const None<int>().tap(seen.add), const None<int>());
      expect(seen, isEmpty);
    });

    test('tapNone fires only on the absent branch', () {
      var someMisses = 0;
      var noneMisses = 0;

      const Some(1).tapNone(() => someMisses++);
      const None<int>().tapNone(() => noneMisses++);

      expect(someMisses, 0);
      expect(noneMisses, 1);
    });
  });

  group('Option.isSomeAnd', () {
    test('is true only when present and the test passes', () {
      expect(const Some(4).isSomeAnd((n) => n.isEven), isTrue);
      expect(const Some(3).isSomeAnd((n) => n.isEven), isFalse);
    });

    test('is false for None without running the test', () {
      var called = false;
      final result = const None<int>().isSomeAnd((n) {
        called = true;
        return true;
      });

      expect(result, isFalse);
      expect(called, isFalse);
    });
  });

  group('Option combining', () {
    test('zip pairs two present values into a record', () {
      final result = const Some('a').zip(const Some(1));

      expect(result.isSome(), isTrue);
      expect(result.getOrElse(() => ('', 0)), ('a', 1));
    });

    test('zip is None when either side is absent', () {
      expect(const Some('a').zip(const None<int>()).isNone(), isTrue);
      expect(const None<String>().zip(const Some(1)).isNone(), isTrue);
    });

    test('zipWith combines through a function', () {
      final result = const Some(3).zipWith(const Some(4), (a, b) => a * b);

      expect(result, const Some(12));
    });

    test('zipWith skips the combiner when a side is absent', () {
      var combined = false;
      final result = const Some(3).zipWith(const None<int>(), (a, b) {
        combined = true;
        return a + b;
      });

      expect(result, const None<int>());
      expect(combined, isFalse);
    });
  });

  group('Option.toList', () {
    test('Some becomes a single-element list', () {
      expect(const Some(5).toList(), [5]);
    });

    test('None becomes an empty list', () {
      expect(const None<int>().toList(), isEmpty);
    });
  });

  group('IterableOptionX', () {
    test('sequence collects every value when all are present', () {
      final result = const [Some(1), Some(2), Some(3)].sequence();

      // Unwrapped, because `Some` equality delegates to the inner value and
      // two distinct lists are never `==`.
      expect(result.isSome(), isTrue);
      expect(result.getOrElse(() => []), [1, 2, 3]);
    });

    test('sequence short-circuits on the first absent value', () {
      final result = const [Some(1), None<int>(), Some(3)].sequence();

      expect(result, const None<List<int>>());
    });

    test('sequence on an empty collection is Some of an empty list', () {
      final result = const <Option<int>>[].sequence();

      expect(result.isSome(), isTrue);
      expect(result.getOrElse(() => [0]), isEmpty);
    });

    test('values keeps the present entries and drops the rest', () {
      const options = [Some(1), None<int>(), Some(3), None<int>()];

      expect(options.values, [1, 3]);
    });

    test('values is empty when nothing is present', () {
      expect(const [None<int>(), None<int>()].values, isEmpty);
    });

    test('firstSome returns the earliest present value', () {
      const options = [None<int>(), Some(2), Some(3)];

      expect(options.firstSome, const Some(2));
    });

    test('firstSome is None when every element is absent', () {
      expect(const [None<int>(), None<int>()].firstSome, const None<int>());
    });
  });

  group('NullableOptionX', () {
    test('lifts a non-null value into Some', () {
      // The extension is declared on `T?`, so it also resolves on a value
      // the analyzer already knows is non-null.
      const value = 'ready';

      expect(value.toOption(), const Some('ready'));
    });

    test('lifts null into None', () {
      const String? value = null;

      expect(value.toOption(), const None<String>());
    });

    test('bridges a nullable map lookup into the Option API', () {
      const config = {'retries': '3'};

      final retries = config['retries']
          .toOption()
          .map(int.parse)
          .filter((n) => n > 0)
          .getOrElse(() => 1);
      final timeout = config['timeout']
          .toOption()
          .map(int.parse)
          .getOrElse(() => 30);

      expect(retries, 3);
      expect(timeout, 30);
    });
  });
}
