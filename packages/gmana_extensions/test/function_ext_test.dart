import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('Function0X', () {
    test('memoize caches value on first execution', () {
      var count = 0;
      int compute() {
        count++;
        return 42;
      }

      final memoized = compute.memoize();
      expect(count, equals(0));

      expect(memoized(), equals(42));
      expect(count, equals(1));

      expect(memoized(), equals(42));
      expect(count, equals(1));
    });

    test('timed measures execution duration', () {
      int compute() => 100;
      final (res, elapsed) = compute.timed();

      expect(res, equals(100));
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(0));
    });
  });
}
