import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart' hide isPositive, isNegative, isZero;

void main() {
  group('numeric_predicates', () {
    test('isDivisibleBy checks divisibility', () {
      expect(isDivisibleBy('10', '2'), isTrue);
      expect(isDivisibleBy('10', '3'), isFalse);
      expect(isDivisibleBy('10', '0'), isFalse);
      expect(isDivisibleBy('abc', '2'), isFalse);
    });

    test('isEven and isOdd check integer parity', () {
      expect(isEven('42'), isTrue);
      expect(isEven('-4'), isTrue);
      expect(isEven('7'), isFalse);

      expect(isOdd('7'), isTrue);
      expect(isOdd('-3'), isTrue);
      expect(isOdd('42'), isFalse);
    });

    test('isPositive, isNegative, and isZero check number signs', () {
      expect(isPositive('15.5'), isTrue);
      expect(isPositive('0'), isFalse);
      expect(isPositive('-10'), isFalse);

      expect(isNegative('-15.5'), isTrue);
      expect(isNegative('0'), isFalse);
      expect(isNegative('10'), isFalse);

      expect(isZero('0'), isTrue);
      expect(isZero('0.0'), isTrue);
      expect(isZero('-0.0'), isTrue);
      expect(isZero('0.1'), isFalse);
    });

    test('isInRange checks numeric bounds', () {
      expect(isInRange('5', 1, 10), isTrue);
      expect(isInRange('1.0', 1, 10), isTrue);
      expect(isInRange('10.0', 1, 10), isTrue);
      expect(isInRange('0.99', 1, 10), isFalse);
      expect(isInRange('10.01', 1, 10), isFalse);
    });

    test('isPrime and isPrimeString check primality', () {
      expect(isPrime(2), isTrue);
      expect(isPrime(3), isTrue);
      expect(isPrime(7), isTrue);
      expect(isPrime(13), isTrue);
      expect(isPrime(29), isTrue);

      expect(isPrime(1), isFalse);
      expect(isPrime(4), isFalse);
      expect(isPrime(9), isFalse);

      expect(isPrimeString('29'), isTrue);
      expect(isPrimeString('30'), isFalse);
      expect(isPrimeString('invalid'), isFalse);
    });
  });
}
