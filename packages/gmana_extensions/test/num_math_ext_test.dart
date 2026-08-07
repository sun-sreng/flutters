import 'dart:math' as math;

import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('IntX number theory', () {
    test('isPrime', () {
      expect(97.isPrime, isTrue);
      expect(2.isPrime, isTrue);
      expect(3.isPrime, isTrue);
      expect(1.isPrime, isFalse);
      expect(0.isPrime, isFalse);
      expect((-7).isPrime, isFalse);
      expect(9.isPrime, isFalse);
      expect(7919.isPrime, isTrue);
      expect(7920.isPrime, isFalse);
    });

    test('isPowerOfTwo', () {
      expect(1.isPowerOfTwo, isTrue);
      expect(1024.isPowerOfTwo, isTrue);
      expect(0.isPowerOfTwo, isFalse);
      expect(6.isPowerOfTwo, isFalse);
      expect((-8).isPowerOfTwo, isFalse);
    });

    test('lcm complements the built-in gcd', () {
      expect(4.lcm(6), 12);
      expect(21.lcm(6), 42);
      expect(0.lcm(5), 0);
      expect((-4).lcm(6), 12);
    });

    test('factorial', () {
      expect(0.factorial, 1);
      expect(1.factorial, 1);
      expect(5.factorial, 120);
      expect(20.factorial, 2432902008176640000);
    });

    test('factorial rejects unsupported inputs', () {
      expect(() => (-1).factorial, throwsArgumentError);
      expect(() => 21.factorial, throwsArgumentError);
    });
  });

  group('NumX angles and powers', () {
    test('toRadians and toDegrees round-trip', () {
      expect(180.toRadians, closeTo(math.pi, 1e-12));
      expect(math.pi.toDegrees, closeTo(180, 1e-12));
      expect(90.toRadians.toDegrees, closeTo(90, 1e-12));
    });

    test('raisedTo', () {
      expect(2.raisedTo(10), 1024.0);
      expect(9.raisedTo(0.5), 3.0);
    });

    test('squareRoot', () {
      expect(16.squareRoot, 4.0);
      expect(2.squareRoot, closeTo(1.41421356, 1e-8));
      expect(() => (-1).squareRoot, throwsArgumentError);
    });

    test('orFinite replaces NaN and infinity', () {
      expect((0 / 0).orFinite(), 0);
      expect((1 / 0).orFinite(-1), -1);
      expect(3.5.orFinite(), 3.5);
    });
  });
}
