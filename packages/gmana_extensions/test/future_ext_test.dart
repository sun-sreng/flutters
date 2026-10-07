import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

Future<T> _slow<T>(T value, Duration delay) =>
    Future<T>.delayed(delay, () => value);

void main() {
  group('FutureX timeouts', () {
    test('timeoutOrNull returns null when the future is too slow', () async {
      final result = await _slow(
        1,
        const Duration(milliseconds: 60),
      ).timeoutOrNull(const Duration(milliseconds: 5));

      expect(result, isNull);
    });

    test('timeoutOrNull passes a value through in time', () async {
      final result = await Future.value(
        1,
      ).timeoutOrNull(const Duration(seconds: 5));
      expect(result, 1);
    });

    test('timeoutOrNull still propagates real errors', () {
      expect(
        Future<int>.error(
          StateError('boom'),
        ).timeoutOrNull(const Duration(seconds: 5)),
        throwsStateError,
      );
    });

    test('timeoutWith substitutes a fallback', () async {
      final result = await _slow(
        1,
        const Duration(milliseconds: 60),
      ).timeoutWith(const Duration(milliseconds: 5), -1);

      expect(result, -1);
    });
  });

  group('FutureX error recovery', () {
    test('orNull swallows the error', () async {
      expect(await Future<int>.error(StateError('x')).orNull(), isNull);
      expect(await Future.value(3).orNull(), 3);
    });

    test('onErrorReturn substitutes a fallback', () async {
      expect(await Future<int>.error(Exception()).onErrorReturn(7), 7);
      expect(await Future.value(3).onErrorReturn(7), 3);
    });

    test('onErrorReturnWith sees the error', () async {
      final result = await Future<String>.error(
        StateError('bad'),
      ).onErrorReturnWith((error, _) => error.toString());

      expect(result, contains('bad'));
    });

    test('settled reports success and failure as data', () async {
      final ok = await Future.value(5).settled();
      expect(ok.$1, 5);
      expect(ok.$2, isNull);

      final failed = await Future<int>.error(StateError('nope')).settled();
      expect(failed.$1, isNull);
      expect(failed.$2, isStateError);
    });
  });

  group('FutureX chaining', () {
    test('thenMap transforms the value', () async {
      expect(await Future.value(3).thenMap((v) => v * 2), 6);
    });

    test('tap observes without changing the value', () async {
      final seen = <int>[];
      expect(await Future.value(3).tap(seen.add), 3);
      expect(seen, [3]);
    });

    test('delayedBy postpones completion', () {
      fakeAsync((async) {
        int? result;
        unawaited(
          Future.value(1)
              .delayedBy(const Duration(milliseconds: 30))
              .then((value) => result = value),
        );

        async.elapse(const Duration(milliseconds: 29));
        expect(result, isNull);
        async.elapse(const Duration(milliseconds: 1));
        expect(result, 1);
      });
    });
  });

  group('IterableFutureX', () {
    test('mapSequential preserves order and never overlaps', () async {
      var inFlight = 0;
      var maxInFlight = 0;

      final result = await [1, 2, 3].mapSequential((n) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        inFlight--;
        return n * 2;
      });

      expect(result, [2, 4, 6]);
      expect(maxInFlight, 1);
    });

    test('mapParallel preserves order while running concurrently', () async {
      var inFlight = 0;
      var maxInFlight = 0;

      final result = await [1, 2, 3].mapParallel((n) async {
        inFlight++;
        maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        inFlight--;
        return n * 2;
      });

      expect(result, [2, 4, 6]);
      expect(maxInFlight, 3);
    });

    test('whereAsync keeps the matching elements in order', () async {
      final result = await [1, 2, 3, 4].whereAsync((n) async => n.isEven);
      expect(result, [2, 4]);
    });
  });
}
