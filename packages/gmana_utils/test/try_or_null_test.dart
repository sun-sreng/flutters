import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('tryOrNull and tryOrDefault', () {
    test('tryOrNull returns value on success and null on error', () {
      expect(tryOrNull(() => 10 + 5), 15);
      expect(tryOrNull<int>(() => throw Exception('error')), isNull);
    });

    test('tryOrNullAsync returns value on success and null on error', () async {
      final success = await tryOrNullAsync(() async => 'hello');
      final failure = await tryOrNullAsync<String>(
        () async => throw Exception('error'),
      );

      expect(success, 'hello');
      expect(failure, isNull);
    });

    test('tryOrDefault returns value on success and default on error', () {
      expect(tryOrDefault(() => 42, 0), 42);
      expect(tryOrDefault<int>(() => throw Exception('error'), 99), 99);
    });
  });
}
