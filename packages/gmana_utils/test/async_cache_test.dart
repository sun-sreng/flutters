import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncMemoizer & AsyncCache', () {
    test('AsyncMemoizer executes action only once', () async {
      final memoizer = AsyncMemoizer<int>();
      var callCount = 0;

      Future<int> compute() async {
        callCount++;
        return 42;
      }

      final r1 = await memoizer.runOnce(compute);
      final r2 = await memoizer.runOnce(compute);

      expect(r1, equals(42));
      expect(r2, equals(42));
      expect(callCount, equals(1));
    });

    test('AsyncCache caches value and respects TTL', () async {
      final cache = AsyncCache<String, String>(
        defaultTtl: const Duration(milliseconds: 100),
      );
      var loadCount = 0;

      Future<String> fetch(String key) async {
        loadCount++;
        return 'value_$key';
      }

      final v1 = await cache.get('k1', ifAbsent: () => fetch('k1'));
      final v2 = await cache.get('k1', ifAbsent: () => fetch('k1'));

      expect(v1, equals('value_k1'));
      expect(v2, equals('value_k1'));
      expect(loadCount, equals(1));

      // Wait for TTL expiration
      await Future<void>.delayed(const Duration(milliseconds: 120));

      final v3 = await cache.get('k1', ifAbsent: () => fetch('k1'));
      expect(v3, equals('value_k1'));
      expect(loadCount, equals(2));
    });

    test('AsyncCache deduplicates concurrent requests for the same key', () async {
      final cache = AsyncCache<String, int>();
      var loadCount = 0;

      Future<int> fetch() async {
        loadCount++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return 99;
      }

      final results = await Future.wait([
        cache.get('same_key', ifAbsent: fetch),
        cache.get('same_key', ifAbsent: fetch),
        cache.get('same_key', ifAbsent: fetch),
      ]);

      expect(results, equals([99, 99, 99]));
      expect(loadCount, equals(1));
    });

    test('AsyncCache invalidate and clear', () async {
      final cache = AsyncCache<String, int>();
      await cache.get('k1', ifAbsent: () async => 10);
      expect(cache.containsKey('k1'), isTrue);

      cache.invalidate('k1');
      expect(cache.containsKey('k1'), isFalse);
    });
  });
}
