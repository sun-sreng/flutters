import 'dart:async';

import 'package:gmana/utilities.dart';
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

    test(
      'AsyncCache deduplicates concurrent requests for the same key',
      () async {
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
      },
    );

    test('AsyncCache invalidate and clear', () async {
      final cache = AsyncCache<String, int>();
      await cache.get('k1', ifAbsent: () async => 10);
      expect(cache.containsKey('k1'), isTrue);

      cache.invalidate('k1');
      expect(cache.containsKey('k1'), isFalse);
    });
  });

  group('AsyncCache with a fetch in flight', () {
    late AsyncCache<String, String> cache;
    late List<Completer<String>> loads;

    Future<String> load() {
      final completer = Completer<String>();
      loads.add(completer);
      return completer.future;
    }

    setUp(() {
      cache = AsyncCache<String, String>();
      loads = [];
    });

    test('invalidate drops the fetch so its result is not stored', () async {
      final stale = cache.get('k', ifAbsent: load);
      cache.invalidate('k');
      loads.single.complete('old');

      // The caller that started the fetch still gets its result.
      expect(await stale, 'old');
      expect(cache.getIfPresent('k'), isNull);

      final fresh = cache.get('k', ifAbsent: load);
      expect(loads, hasLength(2), reason: 'a get after invalidate refetches');
      loads.last.complete('new');
      expect(await fresh, 'new');
    });

    test('invalidateWhere drops matching fetches', () async {
      final stale = cache.get('k', ifAbsent: load);
      expect(cache.invalidateWhere((key) => key == 'k'), 0);
      loads.single.complete('old');

      await stale;
      expect(cache.getIfPresent('k'), isNull);
    });

    test('set wins over a fetch that finishes after it', () async {
      final stale = cache.get('k', ifAbsent: load);
      cache.set('k', 'explicit');
      loads.single.complete('old');

      await stale;
      expect(cache.getIfPresent('k'), 'explicit');
    });

    test('a fetch from before clear does not disturb a newer one', () async {
      final stale = cache.get('k', ifAbsent: load);
      cache.clear();
      final fresh = cache.get('k', ifAbsent: load);
      expect(loads, hasLength(2));

      loads.first.complete('old');
      await stale;

      // The newer fetch is still the one in flight, so this joins it.
      final joined = cache.get('k', ifAbsent: load);
      expect(loads, hasLength(2), reason: 'deduplication must survive');

      loads.last.complete('new');
      expect(await fresh, 'new');
      expect(await joined, 'new');
      expect(cache.getIfPresent('k'), 'new');
    });

    test('a failed stale fetch leaves the newer fetch in place', () async {
      final stale = cache.get('k', ifAbsent: load);
      cache.invalidate('k');
      final fresh = cache.get('k', ifAbsent: load);

      loads.first.completeError(StateError('boom'));
      await expectLater(stale, throwsStateError);

      final joined = cache.get('k', ifAbsent: load);
      expect(loads, hasLength(2));
      loads.last.complete('new');
      expect(await fresh, 'new');
      expect(await joined, 'new');
    });
  });
}
