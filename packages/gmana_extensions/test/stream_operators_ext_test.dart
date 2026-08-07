import 'dart:async';

import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('StreamX buffering', () {
    test('bufferCount groups events and flushes the remainder', () async {
      final result =
          await Stream.fromIterable([1, 2, 3, 4, 5]).bufferCount(2).toList();

      expect(result, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('bufferCount emits nothing for an empty stream', () async {
      expect(await const Stream<int>.empty().bufferCount(2).toList(), isEmpty);
    });

    test('bufferCount validates the count', () {
      expect(
        () => Stream.fromIterable([1]).bufferCount(0).toList(),
        throwsArgumentError,
      );
    });
  });

  group('StreamX prepending', () {
    test('startWith emits the seed first', () async {
      final result = await Stream.fromIterable([2, 3]).startWith(1).toList();
      expect(result, [1, 2, 3]);
    });

    test('startWithMany emits every seed in order', () async {
      final result =
          await Stream.fromIterable([3]).startWithMany([1, 2]).toList();
      expect(result, [1, 2, 3]);
    });
  });

  group('StreamX side effects', () {
    test('doOnData observes without altering the stream', () async {
      final seen = <int>[];
      final result =
          await Stream.fromIterable([1, 2]).doOnData(seen.add).toList();

      expect(result, [1, 2]);
      expect(seen, [1, 2]);
    });

    test('doOnError observes and re-emits the error', () async {
      final seen = <Object>[];
      final controller = StreamController<int>();
      final future =
          controller.stream
              .doOnError((error, _) => seen.add(error))
              .handleError((Object _) {})
              .toList();

      controller
        ..add(1)
        ..addError(StateError('boom'))
        ..add(2);
      await controller.close();

      expect(await future, [1, 2]);
      expect(seen, hasLength(1));
      expect(seen.single, isStateError);
    });

    test('doOnDone fires exactly once when the stream closes', () async {
      var doneCount = 0;
      await Stream.fromIterable([1, 2]).doOnDone(() => doneCount++).toList();

      expect(doneCount, 1);
    });
  });

  group('StreamX filtering', () {
    test('mapNotNull drops null results', () async {
      final result =
          await Stream.fromIterable([
            '1',
            'x',
            '3',
          ]).mapNotNull(int.tryParse).toList();

      expect(result, [1, 3]);
    });

    test('whereNot inverts the predicate', () async {
      final result =
          await Stream.fromIterable([
            1,
            2,
            3,
            4,
          ]).whereNot((n) => n.isEven).toList();

      expect(result, [1, 3]);
    });

    test('ignoreErrors drops errors and keeps data', () async {
      final controller = StreamController<int>();
      final future = controller.stream.ignoreErrors().toList();

      controller
        ..add(1)
        ..addError(Exception('ignored'))
        ..add(2);
      await controller.close();

      expect(await future, [1, 2]);
    });
  });

  group('StreamX firstOrNull', () {
    test('returns the first event', () async {
      expect(await Stream.fromIterable([7, 8]).firstOrNull(), 7);
    });

    test('returns null for an empty stream instead of throwing', () async {
      expect(await const Stream<int>.empty().firstOrNull(), isNull);
    });
  });

  group('StreamX mergeWith', () {
    test('interleaves sources and closes when all are done', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final future = a.stream.mergeWith([b.stream]).toList();

      a.add(1);
      b.add(2);
      a.add(3);
      await a.close();
      b.add(4);
      await b.close();

      expect(await future, [1, 2, 3, 4]);
    });

    test('forwards errors from every source', () async {
      final a = StreamController<int>();
      final b = StreamController<int>();
      final errors = <Object>[];
      final future =
          a.stream.mergeWith([b.stream]).handleError(errors.add).toList();

      a.add(1);
      b.addError(StateError('from b'));
      await a.close();
      await b.close();

      expect(await future, [1]);
      expect(errors.single, isStateError);
    });

    test('merging with nothing behaves like the source', () async {
      expect(await Stream.fromIterable([1, 2]).mergeWith(const []).toList(), [
        1,
        2,
      ]);
    });
  });
}
