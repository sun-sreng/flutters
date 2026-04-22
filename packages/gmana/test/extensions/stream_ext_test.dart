import 'dart:async';

import 'package:gmana/extensions/stream_ext.dart';
import 'package:test/test.dart';

void main() {
  group('StreamListX', () {
    test('filter', () async {
      final stream = Stream.value([1, 2, 3, 4]).filter((e) => e.isEven);
      expect(await stream.first, equals([2, 4]));
    });

    test('mapItems', () async {
      final stream = Stream.value([1, 2, 3]).mapItems((e) => e * 2);
      expect(await stream.first, equals([2, 4, 6]));
    });

    test('flatMapItems', () async {
      final stream = Stream.value([1, 2]).flatMapItems((e) => [e, e]);
      expect(await stream.first, equals([1, 1, 2, 2]));
    });

    test('whereNotEmpty', () async {
      final stream =
          Stream.fromIterable([
            [1],
            [],
            [2, 3],
          ]).whereNotEmpty;
      expect(
        await stream.toList(),
        equals([
          [1],
          [2, 3],
        ]),
      );
    });

    test('lengths', () async {
      final stream =
          Stream.fromIterable([
            [1],
            [],
            [2, 3],
          ]).lengths;
      expect(await stream.toList(), equals([1, 0, 2]));
    });

    test('flatten', () async {
      final stream =
          Stream.fromIterable([
            [1, 2],
            [3, 4],
          ]).flatten();
      expect(await stream.toList(), equals([1, 2, 3, 4]));
    });

    test('sortedBy', () async {
      final stream = Stream.value([3, 1, 2]).sortedBy((a, b) => a.compareTo(b));
      expect(await stream.first, equals([1, 2, 3]));
    });
  });

  group('StreamX', () {
    test('whereNotNull', () async {
      final stream = Stream.fromIterable([1, null, 2, null, 3]).whereNotNull();
      expect(await stream.toList(), equals([1, 2, 3]));
    });

    test('distinctUntilChanged', () async {
      final stream =
          Stream.fromIterable([1, 1, 2, 2, 3, 1]).distinctUntilChanged();
      expect(await stream.toList(), equals([1, 2, 3, 1]));

      final streamCustom = Stream.fromIterable([
        const MapEntry(1, 'a'),
        const MapEntry(1, 'b'),
        const MapEntry(2, 'c'),
      ]).distinctUntilChanged((a, b) => a.key == b.key);
      expect(
        (await streamCustom.toList()).map((e) => e.value),
        equals(['a', 'c']),
      );
    });

    test('skipUntil', () async {
      final stream = Stream.fromIterable([
        1,
        2,
        3,
        4,
        5,
      ]).skipUntil((e) => e == 3);
      expect(await stream.toList(), equals([3, 4, 5]));
    });

    test('takeWhileInclusive', () async {
      final stream = Stream.fromIterable([
        1,
        2,
        3,
        4,
        5,
      ]).takeWhileInclusive((e) => e < 3);
      expect(await stream.toList(), equals([1, 2, 3]));
    });

    test('debounce', () async {
      final controller = StreamController<int>();
      final stream = controller.stream.debounce(
        const Duration(milliseconds: 50),
      );

      final results = <int>[];
      stream.listen(results.add);

      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(3);

      await Future.delayed(const Duration(milliseconds: 100));
      controller.add(4);
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.close();
      expect(results, equals([3, 4]));
    });

    test('throttle', () async {
      final controller = StreamController<int>();
      final stream = controller.stream.throttle(
        const Duration(milliseconds: 50),
      );

      final results = <int>[];
      stream.listen(results.add);

      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(3);

      await Future.delayed(const Duration(milliseconds: 100));
      controller.add(4);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(5);
      await Future.delayed(const Duration(milliseconds: 100));

      await controller.close();
      expect(results, equals([1, 4]));
    });

    test('onErrorReturn', () async {
      final stream = Stream<int>.error(Exception('error')).onErrorReturn(42);
      expect(await stream.first, equals(42));
    });

    test('onErrorReturnWith', () async {
      final stream = Stream<int>.error(
        Exception('error'),
      ).onErrorReturnWith((e) => 42);
      expect(await stream.first, equals(42));
    });

    test('indexed', () async {
      final stream = Stream.fromIterable(['a', 'b', 'c']).indexed;
      expect(await stream.toList(), equals([(0, 'a'), (1, 'b'), (2, 'c')]));
    });

    test('pairwise', () async {
      final stream = Stream.fromIterable([1, 2, 3, 4]).pairwise;
      expect(await stream.toList(), equals([(1, 2), (2, 3), (3, 4)]));
    });

    test('scan', () async {
      final stream = Stream.fromIterable([
        1,
        2,
        3,
      ]).scan(0, (acc, n) => acc + n);
      expect(await stream.toList(), equals([1, 3, 6]));
    });

    test('lastOrNull', () async {
      expect(await Stream.fromIterable([1, 2, 3]).lastOrNull(), equals(3));
      expect(await Stream.empty().lastOrNull(), isNull);
    });
  });
}
