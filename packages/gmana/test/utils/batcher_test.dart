import 'dart:async';

import 'package:gmana/utilities.dart';
import 'package:test/test.dart';

void main() {
  group('Batcher', () {
    test('flushes when maxBatchSize is reached', () async {
      var batchCallCount = 0;

      final batcher = Batcher<int, String>(
        maxBatchSize: 3,
        maxDelay: const Duration(seconds: 10),
        handler: (items) async {
          batchCallCount++;
          return items.map((i) => 'res_$i').toList();
        },
      );

      final f1 = batcher.add(1);
      final f2 = batcher.add(2);
      expect(batchCallCount, equals(0));

      final f3 = batcher.add(3); // Reaches maxBatchSize=3 -> flushes
      final results = await Future.wait([f1, f2, f3]);

      expect(results, equals(['res_1', 'res_2', 'res_3']));
      expect(batchCallCount, equals(1));
    });

    test('flushes after maxDelay when batch is not full', () async {
      var batchCallCount = 0;

      final batcher = Batcher<int, String>(
        maxBatchSize: 10,
        maxDelay: const Duration(milliseconds: 50),
        handler: (items) async {
          batchCallCount++;
          return items.map((i) => 'item_$i').toList();
        },
      );

      final f1 = batcher.add(100);
      final f2 = batcher.add(200);

      final results = await Future.wait([f1, f2]);
      expect(results, equals(['item_100', 'item_200']));
      expect(batchCallCount, equals(1));
    });

    group('while a batch is processing', () {
      late Completer<void> gate;
      late List<int> sizes;
      late Batcher<int, int> batcher;

      setUp(() {
        gate = Completer<void>();
        sizes = [];
        batcher = Batcher<int, int>(
          maxBatchSize: 10,
          maxDelay: const Duration(seconds: 10),
          handler: (items) async {
            sizes.add(items.length);
            if (sizes.length == 1) await gate.future;
            return items;
          },
        );
      });

      test('items added meanwhile go out in batches of maxBatchSize', () async {
        final futures = [for (var i = 0; i < 35; i++) batcher.add(i)];
        expect(sizes, [10], reason: 'the first full batch starts at once');

        gate.complete();
        final results = await Future.wait(futures);

        expect(sizes, [10, 10, 10, 5]);
        expect(results, [for (var i = 0; i < 35; i++) i]);
      });

      test('flush completes only once every queued item is sent', () async {
        final futures = [for (var i = 0; i < 13; i++) batcher.add(i)];
        var flushed = false;
        unawaited(batcher.flush().then((_) => flushed = true));

        await pumpEventQueue();
        expect(flushed, isFalse, reason: 'the first batch is still running');

        gate.complete();
        await pumpEventQueue();
        expect(flushed, isTrue);
        expect(sizes, [10, 3]);
        expect(await Future.wait(futures), hasLength(13));
        expect(batcher.pendingCount, 0);
      });
    });

    test('flush sends a partial batch without waiting for maxDelay', () async {
      final sizes = <int>[];
      final batcher = Batcher<int, int>(
        maxBatchSize: 10,
        maxDelay: const Duration(hours: 1),
        handler: (items) async {
          sizes.add(items.length);
          return items;
        },
      );

      final future = batcher.add(1);
      await batcher.flush();

      expect(sizes, [1]);
      expect(await future, 1);
    });
  });
}
