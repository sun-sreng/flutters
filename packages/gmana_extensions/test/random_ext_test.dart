import 'dart:math';

import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('RandomX', () {
    final random = Random(42);

    test('nextIntInRange', () {
      final val = random.nextIntInRange(10, 20);
      expect(val >= 10 && val <= 20, isTrue);
    });

    test('nextDoubleInRange', () {
      final val = random.nextDoubleInRange(1.0, 5.0);
      expect(val >= 1.0 && val < 5.0, isTrue);
    });

    test('nextElement', () {
      final items = ['a', 'b', 'c'];
      final picked = random.nextElement(items);
      expect(items.contains(picked), isTrue);
    });
  });
}
