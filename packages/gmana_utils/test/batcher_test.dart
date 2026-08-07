import 'package:gmana_utils/gmana_utils.dart';
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
  });
}
