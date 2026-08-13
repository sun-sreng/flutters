import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Result combinators', () {
    test('fold collapses both branches to one type', () {
      expect(
        const Result<int, String>.success(2).fold(
          onSuccess: (value) => 'ok:$value',
          onFailure: (error) => 'err:$error',
        ),
        'ok:2',
      );
      expect(
        const Result<int, String>.failure('bad').fold(
          onSuccess: (value) => 'ok:$value',
          onFailure: (error) => 'err:$error',
        ),
        'err:bad',
      );
    });

    test('swap exchanges the success and failure branches', () {
      expect(
        const Result<int, String>.success(1).swap(),
        const Result<String, int>.failure(1),
      );
      expect(
        const Result<int, String>.failure('e').swap(),
        const Result<String, int>.success('e'),
      );
    });

    test('filter turns a success failing the predicate into a failure', () {
      final kept = const Result<int, String>.success(
        4,
      ).filter((v) => v.isEven, orElse: (v) => 'odd');
      final rejected = const Result<int, String>.success(
        3,
      ).filter((v) => v.isEven, orElse: (v) => 'odd');

      expect(kept, const Result<int, String>.success(4));
      expect(rejected, const Result<int, String>.failure('odd'));
    });

    test('filter leaves an existing failure untouched', () {
      const original = Result<int, String>.failure('boom');
      expect(original.filter((v) => v.isEven, orElse: (v) => 'odd'), original);
    });

    test('getOrThrow returns a success value', () {
      expect(const Result<int, String>.success(5).getOrThrow(), 5);
    });

    test('getOrThrow throws the error when it is throwable', () {
      final result = Result<int, Object>.failure(StateError('boom'));
      expect(result.getOrThrow, throwsStateError);
    });

    test('getOrThrow wraps a non-throwable error', () {
      const result = Result<int, String>.failure('plain message');
      expect(result.getOrThrow, throwsA(isA<StateError>()));
    });

    test('mapBoth transforms whichever branch is present', () {
      expect(
        const Result<int, String>.success(2).mapBoth(
          onSuccess: (v) => v * 2,
          onFailure: (e) => e.length,
        ),
        const Result<int, int>.success(4),
      );
      expect(
        const Result<int, String>.failure('abc').mapBoth(
          onSuccess: (v) => v * 2,
          onFailure: (e) => e.length,
        ),
        const Result<int, int>.failure(3),
      );
    });

    test('fromNullable maps null to a failure', () {
      expect(
        Result.fromNullable<int, String>(7, () => 'missing'),
        const Result<int, String>.success(7),
      );
      expect(
        Result.fromNullable<int, String>(null, () => 'missing'),
        const Result<int, String>.failure('missing'),
      );
    });

    test('captureWith preserves the stack trace that capture drops', () {
      StackTrace? seen;
      final result = Result.captureWith<int, String>(
        () => throw StateError('boom'),
        (error, stackTrace) {
          seen = stackTrace;
          return error.toString();
        },
      );

      expect(result.isFailure, isTrue);
      expect(seen, isNotNull);
    });

    test('captureAsyncWith preserves the stack trace', () async {
      StackTrace? seen;
      final result = await Result.captureAsyncWith<int, String>(
        () async => throw StateError('boom'),
        (error, stackTrace) {
          seen = stackTrace;
          return error.toString();
        },
      );

      expect(result.isFailure, isTrue);
      expect(seen, isNotNull);
    });
  });

  group('tryOr helpers', () {
    test('tryOrDefaultAsync returns the value on success', () async {
      expect(await tryOrDefaultAsync(() async => 3, 0), 3);
    });

    test('tryOrDefaultAsync returns the default on error', () async {
      expect(await tryOrDefaultAsync<int>(() async => throw Exception(), 9), 9);
    });

    test('tryOrElse passes the error and stack trace to the recovery', () {
      Object? seenError;
      StackTrace? seenTrace;

      final value = tryOrElse<int>(() => throw StateError('boom'), (e, st) {
        seenError = e;
        seenTrace = st;
        return -1;
      });

      expect(value, -1);
      expect(seenError, isA<StateError>());
      expect(seenTrace, isNotNull);
    });

    test('tryOrElseAsync recovers from a failed future', () async {
      final value = await tryOrElseAsync<int>(
        () async => throw StateError('boom'),
        (e, st) => -1,
      );
      expect(value, -1);
    });
  });

  group('retry options', () {
    test('caps the backoff delay at maxDelay', () {
      fakeAsync((async) {
        final gaps = <Duration>[];
        var last = Duration.zero;
        var attempts = 0;

        unawaited(
          retry<int>(
            () {
              gaps.add(async.elapsed - last);
              last = async.elapsed;
              attempts++;
              throw StateError('always fails');
            },
            maxAttempts: 8,
            delay: const Duration(seconds: 1),
            maxDelay: const Duration(seconds: 4),
          ).catchError((Object _) => -1),
        );

        async.elapse(const Duration(minutes: 5));

        expect(attempts, 8);
        // First attempt is immediate; later gaps double then hold at the cap.
        expect(gaps.skip(1), everyElement(lessThanOrEqualTo(const Duration(seconds: 4))));
        expect(gaps.last, const Duration(seconds: 4));
      });
    });

    test('rejects a non-positive maxDelay', () async {
      await expectLater(
        retry<int>(() => 1, maxDelay: Duration.zero),
        throwsArgumentError,
      );
    });

    test('reports each retry to onRetry', () async {
      final seen = <int>[];
      var attempts = 0;

      await retry<int>(
        () {
          attempts++;
          if (attempts < 3) throw StateError('not yet');
          return attempts;
        },
        maxAttempts: 3,
        delay: const Duration(milliseconds: 1),
        useExponentialBackoff: false,
        onRetry: (attempt, error, nextDelay) => seen.add(attempt),
      );

      expect(seen, [1, 2]);
    });

    test('jitter keeps the delay within the computed bound', () {
      fakeAsync((async) {
        var last = Duration.zero;
        final gaps = <Duration>[];

        unawaited(
          retry<int>(
            () {
              gaps.add(async.elapsed - last);
              last = async.elapsed;
              throw StateError('always fails');
            },
            maxAttempts: 6,
            delay: const Duration(seconds: 1),
            jitter: true,
          ).catchError((Object _) => -1),
        );

        async.elapse(const Duration(minutes: 5));

        // With full jitter each delay lands in [0, computedDelay].
        expect(gaps.skip(1), everyElement(lessThanOrEqualTo(const Duration(seconds: 32))));
      });
    });
  });

  group('IdGenerator.ulidMonotonic', () {
    test('sorts ascending within a single millisecond', () {
      final ids = List.generate(50, (_) => IdGenerator.ulidMonotonic());
      final sorted = [...ids]..sort();
      expect(ids, sorted);
    });

    test('produces distinct values', () {
      final ids = List.generate(50, (_) => IdGenerator.ulidMonotonic());
      expect(ids.toSet(), hasLength(50));
    });

    test('produces 26-character ids', () {
      expect(IdGenerator.ulidMonotonic(), hasLength(26));
    });

    test('SecureIdGenerator variant also sorts within a millisecond', () {
      final ids = List.generate(50, (_) => SecureIdGenerator.ulidMonotonic());
      final sorted = [...ids]..sort();
      expect(ids, sorted);
    });
  });

  group('Debouncer.runAsync', () {
    test('completes with the value of the action that finally runs', () async {
      final debouncer = Debouncer(milliseconds: 20);

      final first = debouncer.runAsync(() async => 'first');
      final second = debouncer.runAsync(() async => 'second');

      expect(await second, 'second');
      await expectLater(first, throwsA(isA<DebouncedException>()));

      debouncer.dispose();
    });

    test('propagates an error thrown by the action', () async {
      final debouncer = Debouncer(milliseconds: 10);

      await expectLater(
        debouncer.runAsync<int>(() async => throw StateError('boom')),
        throwsStateError,
      );

      debouncer.dispose();
    });

    test('rejects the pending action when disposed', () async {
      final debouncer = Debouncer(milliseconds: 50);
      final pending = debouncer.runAsync(() async => 'never');

      debouncer.dispose();

      await expectLater(pending, throwsA(isA<DebouncedException>()));
    });
  });

  group('Throttler trailing edge', () {
    test('runs the last suppressed action at the end of the window', () {
      fakeAsync((async) {
        final throttler = Throttler(milliseconds: 100, trailing: true);
        final seen = <String>[];

        throttler
          ..run(() => seen.add('a'))
          ..run(() => seen.add('b'))
          ..run(() => seen.add('c'));

        expect(seen, ['a']);
        async.elapse(const Duration(milliseconds: 150));
        expect(seen, ['a', 'c']);

        throttler.dispose();
      });
    });

    test('does not run a trailing action when nothing was suppressed', () {
      fakeAsync((async) {
        final throttler = Throttler(milliseconds: 100, trailing: true);
        final seen = <String>[];

        throttler.run(() => seen.add('a'));
        async.elapse(const Duration(milliseconds: 150));

        expect(seen, ['a']);
        throttler.dispose();
      });
    });

    test('leading-only remains the default', () {
      fakeAsync((async) {
        final throttler = Throttler(milliseconds: 100);
        final seen = <String>[];

        throttler
          ..run(() => seen.add('a'))
          ..run(() => seen.add('b'));
        async.elapse(const Duration(milliseconds: 150));

        expect(seen, ['a']);
        throttler.dispose();
      });
    });
  });

  group('AsyncCache additions', () {
    test('getIfPresent returns null for a missing key', () {
      final cache = AsyncCache<String, int>();
      expect(cache.getIfPresent('nope'), isNull);
    });

    test('set stores a value readable by getIfPresent', () {
      final cache = AsyncCache<String, int>();
      cache.set('k', 1);
      expect(cache.getIfPresent('k'), 1);
      expect(cache.length, 1);
      expect(cache.keys, ['k']);
    });

    test('getIfPresent ignores an expired entry', () {
      fakeAsync((async) {
        final cache = AsyncCache<String, int>(
          defaultTtl: const Duration(seconds: 5),
        )..set('k', 1);

        async.elapse(const Duration(seconds: 6));
        expect(cache.getIfPresent('k'), isNull);
      });
    });

    test('evictExpired drops only expired entries', () {
      fakeAsync((async) {
        final cache = AsyncCache<String, int>(
          defaultTtl: const Duration(seconds: 5),
        )..set('old', 1);

        async.elapse(const Duration(seconds: 3));
        cache.set('new', 2);
        async.elapse(const Duration(seconds: 3));

        expect(cache.evictExpired(), 1);
        expect(cache.keys, ['new']);
      });
    });

    test('invalidateWhere removes matching keys', () {
      final cache = AsyncCache<String, int>()
        ..set('user:1', 1)
        ..set('user:2', 2)
        ..set('post:1', 3);

      expect(cache.invalidateWhere((key) => key.startsWith('user:')), 2);
      expect(cache.keys, ['post:1']);
    });

    test('evicts the least recently used entry past maxEntries', () async {
      final cache = AsyncCache<String, int>(maxEntries: 2)
        ..set('a', 1)
        ..set('b', 2);

      // Touch 'a' so 'b' becomes least recently used.
      cache.getIfPresent('a');
      cache.set('c', 3);

      expect(cache.length, 2);
      expect(cache.getIfPresent('b'), isNull);
      expect(cache.getIfPresent('a'), 1);
      expect(cache.getIfPresent('c'), 3);
    });

    test('rejects a non-positive maxEntries', () {
      expect(() => AsyncCache<String, int>(maxEntries: 0), throwsArgumentError);
    });
  });

  group('CircuitBreaker observability', () {
    test('reports the consecutive failure count', () async {
      final breaker = CircuitBreaker(failureThreshold: 3);

      expect(breaker.failureCount, 0);
      await expectLater(
        breaker.run<int>(() async => throw StateError('x')),
        throwsStateError,
      );
      expect(breaker.failureCount, 1);
    });

    test('notifies onStateChange for each transition', () {
      fakeAsync((async) {
        final transitions = <CircuitState>[];
        final breaker = CircuitBreaker(
          failureThreshold: 1,
          resetTimeout: const Duration(seconds: 10),
          onStateChange: transitions.add,
        );

        unawaited(
          breaker
              .run<int>(() async => throw StateError('x'))
              .catchError((Object _) => -1),
        );
        async.flushMicrotasks();
        expect(transitions, [CircuitState.open]);

        async.elapse(const Duration(seconds: 11));
        expect(breaker.state, CircuitState.halfOpen);
        expect(transitions, [CircuitState.open, CircuitState.halfOpen]);

        unawaited(breaker.run<int>(() async => 1).catchError((Object _) => -1));
        async.elapse(const Duration(seconds: 1));
        expect(transitions, [
          CircuitState.open,
          CircuitState.halfOpen,
          CircuitState.closed,
        ]);
      });
    });
  });
}
