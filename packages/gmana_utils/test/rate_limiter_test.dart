import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('RateLimiter', () {
    test('allows up to maxRequests within duration window', () {
      final limiter = RateLimiter(
        maxRequests: 2,
        duration: const Duration(milliseconds: 100),
      );

      var count = 0;
      expect(limiter.tryRun(() => count++), isTrue);
      expect(limiter.tryRun(() => count++), isTrue);
      expect(limiter.tryRun(() => count++), isFalse); // Limited!

      expect(count, 2);
    });

    test('reset clears historical timestamps', () {
      final limiter = RateLimiter(
        maxRequests: 1,
        duration: const Duration(seconds: 10),
      );

      var count = 0;
      expect(limiter.tryRun(() => count++), isTrue);
      expect(limiter.tryRun(() => count++), isFalse);

      limiter.reset();
      expect(limiter.tryRun(() => count++), isTrue);
      expect(count, 2);
    });

    test('validates arguments', () {
      expect(
        () => RateLimiter(maxRequests: 0, duration: const Duration(seconds: 1)),
        throwsArgumentError,
      );
      expect(
        () => RateLimiter(maxRequests: 5, duration: Duration.zero),
        throwsArgumentError,
      );
    });
  });
}
