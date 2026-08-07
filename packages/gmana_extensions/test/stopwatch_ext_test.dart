import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('StopwatchX', () {
    test('measure measures sync execution duration', () {
      final (res, elapsed) = StopwatchX.measure(() => 123);
      expect(res, equals(123));
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(0));
    });

    test('measureAsync measures async execution duration', () async {
      final (res, elapsed) = await StopwatchX.measureAsync(
        () async => 'done',
      );
      expect(res, equals('done'));
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(0));
    });
  });
}
