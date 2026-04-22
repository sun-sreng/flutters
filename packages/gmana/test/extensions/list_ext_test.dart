import 'package:test/test.dart';
import 'package:gmana/extensions/list_ext.dart';

void main() {
  group('List/Iterable Extensions', () {
    group('IterableNullableX (Null-safety utilities)', () {
      test('whereNotNull filters out null values', () {
        final list = [1, null, 2, null, 3];
        expect(list.whereNotNull.toList(), [1, 2, 3]);
      });

      test('compact removes nulls (shorthand)', () {
        final list = ['a', null, 'b'];
        expect(list.compact().toList(), ['a', 'b']);
      });

      test('compactMap transforms and filters out null results', () {
        final list = [1, 2, null, 3, 4];
        final result = list.compactMap(
          (e) => (e != null && e.isEven) ? 'even' : null,
        );

        expect(result.toList(), ['even', 'even']);
      });
    });

    group('IterableOfIterablesX (Flattening nested iterables)', () {
      test('flatten converts nested iterables to a single level', () {
        final nested = [
          [1, 2],
          [3],
          <int>[],
        ];
        expect(nested.flatten().toList(), [1, 2, 3]);
      });

      test('flattenToList returns a direct List', () {
        final nested = [
          [1, 2],
          [3, 4],
        ];
        expect(nested.flattenToList(), [1, 2, 3, 4]);
        expect(nested.flattenToList(), isA<List<int>>());
      });
    });

    group('IterableX (General mapping and chunking)', () {
      test('flatMap transforms and flattens', () {
        final list = [1, 2, 3];
        final result = list.flatMap((e) => [e, e * 10]);
        // Expects: 1, 10, 2, 20, 3, 30
        expect(result.toList(), [1, 10, 2, 20, 3, 30]);
      });

      test('flatMapNotNull transforms, flattens, and drops nulls', () {
        final list = ['hello', 'hi', 'world'];
        final result = list.flatMapNotNull(
          (s) => [s.startsWith('h') ? s.toUpperCase() : null],
        );

        expect(result.toList(), ['HELLO', 'HI']);
      });

      test('groupBy aggregates logically by key', () {
        final list = [1, 2, 3, 4, 5];
        final grouped = list.groupBy((e) => e.isEven ? 'even' : 'odd');

        expect(grouped, {
          'odd': [1, 3, 5],
          'even': [2, 4],
        });
      });

      test('distinctBy preserves first seen based on key', () {
        final list = [1, 2, 1, 3, 2];
        final result = list.distinctBy((e) => e);

        expect(result.toList(), [1, 2, 3]);

        // Using complex objects representing duplicate string lengths
        final strings = ['a', 'ab', 'b', 'abc'];
        final lengthResult = strings.distinctBy((e) => e.length);

        expect(lengthResult.toList(), ['a', 'ab', 'abc']);
      });

      test('chunked splits correctly into batches', () {
        final list = [1, 2, 3, 4, 5];

        final chunks = list.chunked(2).toList();
        expect(chunks.length, 3);
        expect(chunks[0], [1, 2]);
        expect(chunks[1], [3, 4]);
        expect(chunks[2], [5]);
      });

      test('chunked throws error on invalid size', () {
        final list = [1, 2];
        expect(() => list.chunked(0).toList(), throwsA(isA<AssertionError>()));
      });
    });
  });
}
