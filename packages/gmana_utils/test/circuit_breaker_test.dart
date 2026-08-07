import 'package:gmana_utils/gmana_utils.dart';
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
      final cb = CircuitBreaker(failureThreshold: 2, resetTimeout: const Duration(seconds: 10));

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

    test('transitions to half-open after reset timeout and closes on success', () async {
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
    });

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
}
