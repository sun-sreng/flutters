import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

void main() {
  group('numeric_predicates', () {
    test('isDivisibleBy checks divisibility', () {
      expect(isDivisibleBy('10', '2'), isTrue);
      expect(isDivisibleBy('10', '3'), isFalse);
      expect(isDivisibleBy('10', '0'), isFalse);
      expect(isDivisibleBy('abc', '2'), isFalse);
    });
  });
}
