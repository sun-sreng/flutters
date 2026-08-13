import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncMemoizer', () {
    test('runs the computation exactly once for concurrent callers', () async {
      final memoizer = AsyncMemoizer<int>();
      var runs = 0;

      Future<int> compute() async {
        runs++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return 42;
      }

      final first = memoizer.runOnce(compute);
      final second = memoizer.runOnce(compute);

      expect(await first, 42);
      expect(await second, 42);
      expect(runs, 1);
    });

    test('propagates the same error to every concurrent caller', () async {
      final memoizer = AsyncMemoizer<int>();
      var runs = 0;

      Future<int> compute() async {
        runs++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        throw StateError('boom');
      }

      final first = memoizer.runOnce(compute);
      final second = memoizer.runOnce(compute);

      await expectLater(first, throwsStateError);
      await expectLater(second, throwsStateError);
      expect(runs, 1);
    });
  });

  group('CircuitBreaker', () {
    test('admits only one trial call while half-open', () {
      fakeAsync((async) {
        final breaker = CircuitBreaker(
          failureThreshold: 1,
          resetTimeout: const Duration(seconds: 10),
        );

        unawaited(
          breaker
              .run<int>(() async => throw StateError('down'))
              .catchError((Object _) => -1),
        );
        async.flushMicrotasks();
        expect(breaker.state, CircuitState.open);

        async.elapse(const Duration(seconds: 11));
        expect(breaker.state, CircuitState.halfOpen);

        var trials = 0;
        for (var i = 0; i < 5; i++) {
          unawaited(
            breaker
                .run<int>(() async {
                  trials++;
                  await Future<void>.delayed(const Duration(seconds: 1));
                  return 1;
                })
                .catchError((Object _) => -1),
          );
        }
        async.elapse(const Duration(seconds: 5));

        expect(trials, 1);
      });
    });

    test('rejects extra half-open callers with a zero remaining timeout', () {
      fakeAsync((async) {
        final breaker = CircuitBreaker(
          failureThreshold: 1,
          resetTimeout: const Duration(seconds: 10),
        );

        unawaited(
          breaker
              .run<int>(() async => throw StateError('down'))
              .catchError((Object _) => -1),
        );
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 11));

        unawaited(
          breaker
              .run<int>(() async {
                await Future<void>.delayed(const Duration(seconds: 1));
                return 1;
              })
              .catchError((Object _) => -1),
        );
        async.flushMicrotasks();

        Object? rejected;
        unawaited(
          breaker.run<int>(() async => 2).catchError((Object e) {
            rejected = e;
            return -1;
          }),
        );
        async.elapse(const Duration(seconds: 5));

        expect(rejected, isA<CircuitBreakerOpenException>());
        expect(
          (rejected! as CircuitBreakerOpenException).remainingTimeout,
          Duration.zero,
        );
      });
    });
  });

  group('Batcher', () {
    test('rejects add() after dispose instead of hanging forever', () async {
      final batcher = Batcher<int, int>(
        maxBatchSize: 10,
        maxDelay: const Duration(milliseconds: 50),
        handler: (items) async => items,
      );

      batcher.dispose();

      await expectLater(batcher.add(1), throwsStateError);
    });

  });

  group('AsyncCache', () {
    test('treats a zero TTL entry as immediately expired', () async {
      final cache = AsyncCache<String, int>(defaultTtl: Duration.zero);
      var calls = 0;

      final first = await cache.get('k', ifAbsent: () async => ++calls);
      final second = await cache.get('k', ifAbsent: () async => ++calls);

      expect(first, 1);
      expect(second, 2);
      expect(calls, 2);
      expect(cache.containsKey('k'), isFalse);
    });

    test('expires an entry exactly at the TTL boundary', () {
      fakeAsync((async) {
        final cache = AsyncCache<String, int>(
          defaultTtl: const Duration(seconds: 10),
        );
        var calls = 0;

        unawaited(cache.get('k', ifAbsent: () async => ++calls));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 10));
        expect(cache.containsKey('k'), isFalse);
      });
    });
  });
}
