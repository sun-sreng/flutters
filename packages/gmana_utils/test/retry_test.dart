import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('retry', () {
    test('succeeds on first attempt', () async {
      final result = await retry(() async => 'success');
      expect(result, 'success');
    });

    test('retries on failure until success', () async {
      var attempts = 0;
      final result = await retry(
        () async {
          attempts++;
          if (attempts < 3) throw StateError('Failed attempt $attempts');
          return 'ok';
        },
        maxAttempts: 3,
        delay: const Duration(milliseconds: 5),
        useExponentialBackoff: false,
      );

      expect(result, 'ok');
      expect(attempts, 3);
    });

    test('rethrows exception when maxAttempts exceeded', () async {
      var attempts = 0;
      await expectLater(
        () => retry(
          () async {
            attempts++;
            throw Exception('Persistent error');
          },
          maxAttempts: 2,
          delay: const Duration(milliseconds: 5),
        ),
        throwsException,
      );
      expect(attempts, equals(2));
    });

    test('respects retryIf predicate', () async {
      var attempts = 0;
      expect(
        () => retry(
          () async {
            attempts++;
            throw ArgumentError('Fatal error');
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 5),
          retryIf: (error) => error is StateError, // ArgumentError is not retried
        ),
        throwsArgumentError,
      );

      expect(attempts, 1); // Failed immediately without retrying
    });
  });
}
