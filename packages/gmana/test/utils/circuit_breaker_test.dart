import 'dart:async';

import 'package:clock/clock.dart';
import 'package:gmana/utilities.dart';
import 'package:test/test.dart';

void main() {
  group('CircuitBreaker', () {
    test('remains closed during successful calls', () async {
      final cb = CircuitBreaker(failureThreshold: 2);

      expect(cb.isClosed, isTrue);
      final res = await cb.run(() async => 'ok');
      expect(res, equals('ok'));
      expect(cb.isClosed, isTrue);
    });

    test('trips open after reaching failure threshold', () async {
      final cb = CircuitBreaker(
        failureThreshold: 2,
        resetTimeout: const Duration(seconds: 10),
      );

      // Failure 1
      try {
        await cb.run(() async => throw Exception('error 1'));
      } catch (_) {}
      expect(cb.isClosed, isTrue);

      // Failure 2 -> trips open
      try {
        await cb.run(() async => throw Exception('error 2'));
      } catch (_) {}
      expect(cb.isOpen, isTrue);

      // Immediate subsequent call fails with CircuitBreakerOpenException
      expect(
        () => cb.run(() async => 'should fail'),
        throwsA(isA<CircuitBreakerOpenException>()),
      );
    });

    test(
      'transitions to half-open after reset timeout and closes on success',
      () async {
        final cb = CircuitBreaker(
          failureThreshold: 1,
          resetTimeout: const Duration(milliseconds: 100),
          halfOpenSuccessThreshold: 1,
        );

        // Trip open
        try {
          await cb.run(() async => throw Exception('fail'));
        } catch (_) {}
        expect(cb.isOpen, isTrue);

        // Wait for reset timeout
        await Future<void>.delayed(const Duration(milliseconds: 120));

        expect(cb.isHalfOpen, isTrue);

        // Successful trial call closes circuit
        final res = await cb.run(() async => 'trial success');
        expect(res, equals('trial success'));
        expect(cb.isClosed, isTrue);
      },
    );

    test('reset manually closes circuit', () async {
      final cb = CircuitBreaker(failureThreshold: 1);
      try {
        await cb.run(() async => throw Exception('fail'));
      } catch (_) {}
      expect(cb.isOpen, isTrue);

      cb.reset();
      expect(cb.isClosed, isTrue);
    });
  });

  group('CircuitBreaker with a call from an earlier state', () {
    late DateTime now;
    late CircuitBreaker cb;

    /// Runs [body] with a clock the test advances by assigning [now].
    Future<void> withTestClock(Future<void> Function() body) =>
        withClock(Clock(() => now), body);

    Future<void> tripOpen() => expectLater(
      cb.run<void>(() async => throw StateError('down')),
      throwsStateError,
    );

    void waitForHalfOpen() {
      now = now.add(const Duration(seconds: 2));
      expect(cb.state, CircuitState.halfOpen);
    }

    setUp(() {
      now = DateTime.utc(2024);
      cb = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(seconds: 1),
      );
    });

    test('its late success does not close the half-open circuit', () {
      return withTestClock(() async {
        final slow = Completer<String>();
        final stale = cb.run(() => slow.future);

        await tripOpen();
        waitForHalfOpen();

        slow.complete('late');
        expect(await stale, 'late', reason: 'the caller still gets its result');
        expect(cb.state, CircuitState.halfOpen);

        // The probe, not the stale call, decides.
        await cb.run(() async => 'probe');
        expect(cb.state, CircuitState.closed);
      });
    });

    test('its late failure does not re-open the half-open circuit', () {
      return withTestClock(() async {
        final slow = Completer<String>();
        final stale = cb.run(() => slow.future);

        await tripOpen();
        waitForHalfOpen();

        slow.completeError(StateError('late'));
        await expectLater(stale, throwsStateError);
        expect(cb.state, CircuitState.halfOpen);
      });
    });

    test('its late failure after a manual reset is not counted', () {
      return withTestClock(() async {
        cb = CircuitBreaker(failureThreshold: 2);
        await expectLater(
          cb.run<void>(() async => throw StateError('one')),
          throwsStateError,
        );

        final slow = Completer<String>();
        final stale = cb.run(() => slow.future);
        cb.reset();

        slow.completeError(StateError('late'));
        await expectLater(stale, throwsStateError);
        expect(cb.failureCount, 0);
      });
    });

    test('a finished old probe does not free the slot of a new one', () {
      return withTestClock(() async {
        await tripOpen();
        waitForHalfOpen();

        final oldProbe = Completer<String>();
        final first = cb.run(() => oldProbe.future);
        cb.reset();

        await tripOpen();
        waitForHalfOpen();
        final newProbe = Completer<String>();
        final second = cb.run(() => newProbe.future);

        oldProbe.complete('old');
        await first;

        await expectLater(
          cb.run(() async => 'third'),
          throwsA(isA<CircuitBreakerOpenException>()),
          reason: 'only one probe may run while half-open',
        );

        newProbe.complete('new');
        await second;
        expect(cb.state, CircuitState.closed);
      });
    });
  });
}
