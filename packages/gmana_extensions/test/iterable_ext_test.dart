import 'package:test/test.dart';
import 'package:gmana_extensions/gmana_extensions.dart';

void main() {
  group('IterableNumX Extension', () {
    group('Aggregates', () {
      test('sum calculates correct total', () {
        expect([1, 2, 3].sum(), 6);
        expect([1.5, 2.5, 3.0].sum(), 7.0);
        expect(<int>[].sum(), 0); // default identity
        expect(<double>[].sum(), 0.0);
        expect(<int>[].sum(identity: 10), 10);
      });

      test('product calculates correct multiplication', () {
        expect([2, 3, 4].product(), 24);
        expect([2.0, 3.5, 2.0].product(), 14.0);
        expect(<int>[].product(), 1); // default identity
        expect(<double>[].product(), 1.0);
        expect(<int>[].product(identity: 5), 5);
      });

      test('average calculates mean correctly', () {
        expect([1, 2, 3, 4, 5].average, 3.0);
        expect([1.5, 2.5].average, 2.0);
        expect(<int>[].average, isNull);
      });

      test('averageOrThrow throws on empty', () {
        expect([2, 4].averageOrThrow, 3.0);
        expect(() => <int>[].averageOrThrow, throwsStateError);
      });
    });

    group('Min / Max', () {
      test('minOrNull and maxOrNull return correct values', () {
        expect([3, 1, 4, 2].minOrNull, 1);
        expect([3.5, 1.2, 4.8].maxOrNull, 4.8);
        expect(<int>[].minOrNull, isNull);
        expect(<int>[].maxOrNull, isNull);
      });

      test('minOrThrow and maxOrThrow throw on empty', () {
        expect([3, 1, 4, 2].minOrThrow, 1);
        expect([3, 1, 4, 2].maxOrThrow, 4);
        expect(() => <int>[].minOrThrow, throwsStateError);
        expect(() => <double>[].maxOrThrow, throwsStateError);
      });

      test('clampAll limits values to specified range', () {
        expect([1, 5, 10, 15].clampAll(5, 10).toList(), [5, 5, 10, 10]);
        expect([1.0, 5.0, 10.0].clampAll(5.0, 8.0).toList(), [5.0, 5.0, 8.0]);
      });
    });

    group('Statistics', () {
      test('range calculates max - min', () {
        expect([1, 5, 10].range, 9);
        expect([2.5, 5.0, 10.0].range, 7.5);
        expect(<int>[].range, isNull);
      });

      test('variance calculates population variance', () {
        // [2, 4, 4, 4, 5, 5, 7, 9] -> mean 5, variance -> 4
        expect([2, 4, 4, 4, 5, 5, 7, 9].variance, 4.0);
        expect(<int>[].variance, isNull);
      });

      test('stdDev calculates population standard deviation', () {
        expect([2, 4, 4, 4, 5, 5, 7, 9].stdDev, 2.0);
        expect(<int>[].stdDev, isNull);
      });

      test('sampleVariance and sampleStdDev use sample denominator', () {
        expect(
          [2, 4, 4, 4, 5, 5, 7, 9].sampleVariance,
          closeTo(4.571428571, 0.000001),
        );
        expect(
          [2, 4, 4, 4, 5, 5, 7, 9].sampleStdDev,
          closeTo(2.138089935, 0.000001),
        );
        expect([1].sampleVariance, isNull);
        expect(<int>[].sampleStdDev, isNull);
      });

      test('median calculates median value', () {
        expect([1, 3, 2].median, 2.0); // odd length
        expect([1, 2, 3, 4].median, 2.5); // even length
        expect([4, 1, 3, 2].median, 2.5); // unsorted even
        expect(<int>[].median, isNull);
      });

      test('percentile calculates interpolated percentile', () {
        expect([15, 20, 35, 40, 50].percentile(40), 29.0);
        expect([1, 2, 3, 4].percentile(50), 2.5);
        expect([1, 2, 3].percentile(0), 1.0);
        expect([1, 2, 3].percentile(100), 3.0);
        expect(<int>[].percentile(50), isNull);
        expect(() => [1, 2, 3].percentile(-1), throwsArgumentError);
        expect(() => [1, 2, 3].percentile(101), throwsArgumentError);
      });

      test('modes and frequencyMap count repeated values', () {
        expect([1, 2, 2, 3, 3].modes, [2, 3]);
        expect([3, 1, 3, 2, 1, 3].modes, [3]);
        expect(<int>[].modes, isEmpty);
        expect([1, 2, 2, 3].frequencyMap(), {1: 1, 2: 2, 3: 1});
      });
    });

    group('Predicates', () {
      test('allPositive', () {
        expect([1, 2, 3].allPositive, isTrue);
        expect([0, 1, 2].allPositive, isFalse);
        expect([-1, 1, 2].allPositive, isFalse);
        expect(<int>[].allPositive, isTrue); // Vacuously true
      });

      test('allNegative', () {
        expect([-1, -2, -3].allNegative, isTrue);
        expect([0, -1, -2].allNegative, isFalse);
        expect([1, -1, -2].allNegative, isFalse);
      });

      test('allNonNegative', () {
        expect([1, 2, 3].allNonNegative, isTrue);
        expect([0, 1, 2].allNonNegative, isTrue);
        expect([-1, 0, 1].allNonNegative, isFalse);
      });

      test('zero and sign predicates', () {
        expect([0, 0].allZero, isTrue);
        expect([0, 1].allZero, isFalse);
        expect([0, 1].anyZero, isTrue);
        expect([0, 1].anyPositive, isTrue);
        expect([0, -1].anyNegative, isTrue);
        expect(<int>[].anyZero, isFalse);
      });
    });

    group('Transforms', () {
      test('normalize scales values between 0 and 1', () {
        expect([0, 5, 10].normalize(), [0.0, 0.5, 1.0]);
        // When min == max, returns empty list
        expect([5, 5, 5].normalize(), isEmpty);
        expect(<int>[].normalize(), isEmpty);
      });

      test('normalizeTo scales values between custom bounds', () {
        expect([0, 5, 10].normalizeTo(10, 20), [10.0, 15.0, 20.0]);
        expect([0, 5, 10].normalizeTo(1, -1), [1.0, 0.0, -1.0]);
        expect([5, 5, 5].normalizeTo(10, 20), isEmpty);
      });

      test('deltas returns differences between adjacent values', () {
        expect([3, 5, 10, 9].deltas().toList(), [2, 5, -1]);
        expect([1].deltas().toList(), isEmpty);
        expect(<int>[].deltas().toList(), isEmpty);
      });

      test('runningSum calculates prefix sums', () {
        expect([1, 2, 3, 4].runningSum().toList(), [1, 3, 6, 10]);
        expect([1.5, 2.5].runningSum().toList(), [1.5, 4.0]);
        expect(<int>[].runningSum().toList(), isEmpty);
      });

      test('runningProduct calculates prefix products', () {
        expect([1, 2, 3, 4].runningProduct().toList(), [1, 2, 6, 24]);
        expect([1.5, 2.0].runningProduct().toList(), [1.5, 3.0]);
        expect(<int>[].runningProduct().toList(), isEmpty);
      });

      test('runningAverage calculates prefix averages', () {
        expect([2, 4, 6, 8].runningAverage().toList(), [2.0, 3.0, 4.0, 5.0]);
        expect([1.5, 2.5].runningAverage().toList(), [1.5, 2.0]);
        expect(<int>[].runningAverage().toList(), isEmpty);
      });

      test('top returns largest elements', () {
        expect([1, 5, 2, 10, 4].top(3), [10, 5, 4]);
        expect([1, 2].top(5), [2, 1]); // handles larger n
        expect(<int>[].top(2), isEmpty);
        expect(() => [1, 2].top(-1), throwsArgumentError);
      });

      test('bottom returns smallest elements', () {
        expect([1, 5, 2, 10, 4].bottom(3), [1, 2, 4]);
        expect([3, 2].bottom(5), [2, 3]); // handles larger n
        expect(<int>[].bottom(2), isEmpty);
        expect(() => [1, 2].bottom(-1), throwsArgumentError);
      });
    });
  });
}
