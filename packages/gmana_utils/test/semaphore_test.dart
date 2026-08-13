import 'dart:async';

import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Semaphore', () {
    test('never lets more than the permit count run at once', () async {
      final semaphore = Semaphore(2);
      var running = 0;
      var peak = 0;

      Future<void> task() => semaphore.withPermit(() async {
        running++;
        peak = running > peak ? running : peak;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        running--;
      });

      await Future.wait(List.generate(6, (_) => task()));

      expect(peak, 2);
      expect(running, 0);
    });

    test('hands permits to waiters in FIFO order', () async {
      final semaphore = Semaphore(1);
      final order = <int>[];

      await semaphore.acquire();

      final waiters = [
        for (var i = 0; i < 3; i++)
          semaphore.acquire().then((_) {
            order.add(i);
            semaphore.release();
          }),
      ];

      semaphore.release();
      await Future.wait(waiters);

      expect(order, [0, 1, 2]);
    });

    test('releases the permit when the action throws', () async {
      final semaphore = Semaphore(1);

      await expectLater(
        semaphore.withPermit<void>(() async => throw StateError('boom')),
        throwsStateError,
      );

      expect(semaphore.available, 1);
    });

    test('releases the permit when the action throws synchronously', () async {
      final semaphore = Semaphore(1);

      await expectLater(
        semaphore.withPermit<void>(() => throw StateError('boom')),
        throwsStateError,
      );

      expect(semaphore.available, 1);
    });

    test('reports available permits and queue length', () async {
      final semaphore = Semaphore(2);
      expect(semaphore.permits, 2);
      expect(semaphore.available, 2);
      expect(semaphore.queueLength, 0);

      await semaphore.acquire();
      await semaphore.acquire();
      expect(semaphore.available, 0);

      unawaited(semaphore.acquire());
      await Future<void>.delayed(Duration.zero);
      expect(semaphore.queueLength, 1);

      semaphore.release();
      await Future<void>.delayed(Duration.zero);
      expect(semaphore.queueLength, 0);
    });

    test('rejects a non-positive permit count', () {
      expect(() => Semaphore(0), throwsArgumentError);
      expect(() => Semaphore(-1), throwsArgumentError);
    });

    test('rejects a release that exceeds the permit count', () {
      final semaphore = Semaphore(1);
      expect(semaphore.release, throwsStateError);
    });
  });

  group('KeyedLock', () {
    test('serializes operations sharing a key', () async {
      final lock = KeyedLock<String>();
      final order = <String>[];

      Future<void> task(String label) =>
          lock.synchronized('shared', () async {
            order.add('$label-start');
            await Future<void>.delayed(const Duration(milliseconds: 20));
            order.add('$label-end');
          });

      await Future.wait([task('a'), task('b')]);

      expect(order, ['a-start', 'a-end', 'b-start', 'b-end']);
    });

    test('runs different keys concurrently', () async {
      final lock = KeyedLock<String>();
      var running = 0;
      var peak = 0;

      Future<void> task(String key) => lock.synchronized(key, () async {
        running++;
        peak = running > peak ? running : peak;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        running--;
      });

      await Future.wait([task('a'), task('b')]);

      expect(peak, 2);
    });

    test('releases the key when the action throws', () async {
      final lock = KeyedLock<String>();

      await expectLater(
        lock.synchronized<void>('k', () async => throw StateError('boom')),
        throwsStateError,
      );

      expect(lock.isLocked('k'), isFalse);
      expect(await lock.synchronized('k', () async => 'recovered'), 'recovered');
    });

    test('does not retain state for released keys', () async {
      final lock = KeyedLock<int>();
      await lock.synchronized(1, () async {});
      expect(lock.activeKeys, 0);
    });
  });

  group('mapConcurrent', () {
    test('preserves input order regardless of completion order', () async {
      final result = await mapConcurrent<int, int>([1, 2, 3, 4], (item) async {
        await Future<void>.delayed(Duration(milliseconds: (5 - item) * 10));
        return item * 10;
      }, concurrency: 4);

      expect(result, [10, 20, 30, 40]);
    });

    test('never exceeds the concurrency limit', () async {
      var running = 0;
      var peak = 0;

      await mapConcurrent<int, int>(List.generate(10, (i) => i), (item) async {
        running++;
        peak = running > peak ? running : peak;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        running--;
        return item;
      }, concurrency: 3);

      expect(peak, 3);
    });

    test('propagates the first error', () async {
      await expectLater(
        mapConcurrent<int, int>([1, 2, 3], (item) async {
          if (item == 2) throw StateError('bad item');
          return item;
        }, concurrency: 1),
        throwsStateError,
      );
    });

    test('returns an empty list for empty input', () async {
      expect(await mapConcurrent<int, int>([], (i) async => i), isEmpty);
    });

    test('rejects a non-positive concurrency', () {
      expect(
        () => mapConcurrent<int, int>([1], (i) async => i, concurrency: 0),
        throwsArgumentError,
      );
    });
  });

  group('forEachConcurrent', () {
    test('visits every item within the concurrency limit', () async {
      final seen = <int>[];
      var running = 0;
      var peak = 0;

      await forEachConcurrent<int>(List.generate(8, (i) => i), (item) async {
        running++;
        peak = running > peak ? running : peak;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        seen.add(item);
        running--;
      }, concurrency: 2);

      expect(seen..sort(), List.generate(8, (i) => i));
      expect(peak, 2);
    });
  });
}
