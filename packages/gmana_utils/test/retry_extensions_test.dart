import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaRetryFunctionX', () {
    test('withRetry retries a synchronous operation until success', () async {
      var attempts = 0;

      int operation() {
        attempts++;
        if (attempts < 3) throw StateError('attempt $attempts');
        return 42;
      }

      final result = await operation.withRetry(
        maxAttempts: 3,
        delay: Duration.zero,
        useExponentialBackoff: false,
      );

      expect(result, 42);
      expect(attempts, 3);
    });

    test('withRetry retries an asynchronous operation until success', () async {
      var attempts = 0;

      Future<String> operation() async {
        attempts++;
        if (attempts < 2) throw StateError('attempt $attempts');
        return 'done';
      }

      final result = await operation.withRetry(
        maxAttempts: 2,
        delay: Duration.zero,
      );

      expect(result, 'done');
      expect(attempts, 2);
    });

    test('withRetry respects retryIf for synchronous errors', () async {
      var attempts = 0;

      int operation() {
        attempts++;
        throw ArgumentError('fatal');
      }

      await expectLater(
        operation.withRetry(
          maxAttempts: 3,
          delay: Duration.zero,
          retryIf: (error) => error is StateError,
        ),
        throwsArgumentError,
      );
      expect(attempts, 1);
    });

    test('withRetry respects retryIf for asynchronous errors', () async {
      var attempts = 0;

      Future<int> operation() async {
        attempts++;
        throw StateError('transient');
      }

      await expectLater(
        operation.withRetry(
          maxAttempts: 3,
          delay: Duration.zero,
          retryIf: (_) => false,
        ),
        throwsStateError,
      );
      expect(attempts, 1);
    });

    test('withRetry stops after maxAttempts', () async {
      var attempts = 0;

      Future<int> operation() async {
        attempts++;
        throw StateError('persistent');
      }

      await expectLater(
        operation.withRetry(
          maxAttempts: 2,
          delay: Duration.zero,
          useExponentialBackoff: false,
        ),
        throwsStateError,
      );
      expect(attempts, 2);
    });

    test('withRetry rejects maxAttempts below one without invoking', () async {
      var attempts = 0;

      int operation() {
        attempts++;
        return 1;
      }

      await expectLater(
        operation.withRetry(maxAttempts: 0),
        throwsArgumentError,
      );
      expect(attempts, 0);
    });
  });
}
