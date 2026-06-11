import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('IntNullableX', () {
    test('orZero', () {
      expect((null as int?).orZero, equals(0));
      expect(5.orZero, equals(5));
    });

    test('orDefault', () {
      expect((null as int?).orDefault(10), equals(10));
      expect(5.orDefault(10), equals(5));
    });

    test('isNullOrZero', () {
      expect((null as int?).isNullOrZero, isTrue);
      expect(0.isNullOrZero, isTrue);
      expect(5.isNullOrZero, isFalse);
    });

    test('isNullOrNegative', () {
      expect((null as int?).isNullOrNegative, isTrue);
      expect((-1).isNullOrNegative, isTrue);
      expect(0.isNullOrNegative, isFalse);
      expect(1.isNullOrNegative, isFalse);
    });

    test('isNullOrPositive', () {
      expect((null as int?).isNullOrPositive, isTrue);
      expect(1.isNullOrPositive, isTrue);
      expect(0.isNullOrPositive, isFalse);
      expect((-1).isNullOrPositive, isFalse);
    });

    test('nonZeroOrNull', () {
      expect((null as int?).nonZeroOrNull, isNull);
      expect(0.nonZeroOrNull, isNull);
      expect(5.nonZeroOrNull, equals(5));
      expect((-5).nonZeroOrNull, equals(-5));
    });

    test('orEmptyString', () {
      expect((null as int?).orEmptyString, isEmpty);
      expect(5.orEmptyString, equals('5'));
      expect((-5).orEmptyString, equals('-5'));
    });

    test('orDefaultIfZero', () {
      expect((null as int?).orDefaultIfZero(10), equals(10));
      expect(0.orDefaultIfZero(10), equals(10));
      expect(5.orDefaultIfZero(10), equals(5));
    });

    test('mapNotNull', () {
      expect((null as int?).mapNotNull((value) => value * 2), isNull);
      expect(5.mapNotNull((value) => value * 2), equals(10));
    });
  });

  group('DoubleNullableX', () {
    test('orZero', () {
      expect((null as double?).orZero, equals(0.0));
      expect(5.5.orZero, equals(5.5));
    });

    test('orDefault', () {
      expect((null as double?).orDefault(10.5), equals(10.5));
      expect(5.5.orDefault(10.5), equals(5.5));
    });

    test('isNullOrZero', () {
      expect((null as double?).isNullOrZero, isTrue);
      expect(0.0.isNullOrZero, isTrue);
      expect(5.5.isNullOrZero, isFalse);
    });

    test('isNullOrNaN', () {
      expect((null as double?).isNullOrNaN, isTrue);
      expect(double.nan.isNullOrNaN, isTrue);
      expect(5.5.isNullOrNaN, isFalse);
    });

    test('isNullOrNotFinite', () {
      expect((null as double?).isNullOrNotFinite, isTrue);
      expect(double.nan.isNullOrNotFinite, isTrue);
      expect(double.infinity.isNullOrNotFinite, isTrue);
      expect(double.negativeInfinity.isNullOrNotFinite, isTrue);
      expect(5.5.isNullOrNotFinite, isFalse);
    });

    test('finiteOrNull', () {
      expect((null as double?).finiteOrNull, isNull);
      expect(double.nan.finiteOrNull, isNull);
      expect(double.infinity.finiteOrNull, isNull);
      expect(5.5.finiteOrNull, equals(5.5));
    });

    test('orNaN', () {
      expect((null as double?).orNaN.isNaN, isTrue);
      expect(5.5.orNaN, equals(5.5));
    });

    test('orDefaultIfNaN', () {
      expect((null as double?).orDefaultIfNaN(10.5), equals(10.5));
      expect(double.nan.orDefaultIfNaN(10.5), equals(10.5));
      expect(double.infinity.orDefaultIfNaN(10.5), equals(double.infinity));
      expect(5.5.orDefaultIfNaN(10.5), equals(5.5));
    });

    test('orDefaultIfNotFinite', () {
      expect((null as double?).orDefaultIfNotFinite(10.5), equals(10.5));
      expect(double.nan.orDefaultIfNotFinite(10.5), equals(10.5));
      expect(double.infinity.orDefaultIfNotFinite(10.5), equals(10.5));
      expect(double.negativeInfinity.orDefaultIfNotFinite(10.5), equals(10.5));
      expect(5.5.orDefaultIfNotFinite(10.5), equals(5.5));
    });

    test('mapNotNull', () {
      expect((null as double?).mapNotNull((value) => value.round()), isNull);
      expect(5.5.mapNotNull((value) => value.round()), equals(6));
    });
  });

  group('NumNullableX', () {
    test('orZero', () {
      expect((null as num?).orZero, equals(0));
      expect(5.orZero, equals(5));
      expect(5.5.orZero, equals(5.5));
    });

    test('orDefault', () {
      expect((null as num?).orDefault(10), equals(10));
      expect(5.orDefault(10), equals(5));
      expect(5.5.orDefault(10), equals(5.5));
    });

    test('isNullOrZero', () {
      expect((null as num?).isNullOrZero, isTrue);
      expect(0.isNullOrZero, isTrue);
      expect(0.0.isNullOrZero, isTrue);
      expect(5.isNullOrZero, isFalse);
    });

    test('isNullOrNegative', () {
      expect((null as num?).isNullOrNegative, isTrue);
      expect((-1).isNullOrNegative, isTrue);
      expect((-1.5).isNullOrNegative, isTrue);
      expect(0.isNullOrNegative, isFalse);
      expect(1.isNullOrNegative, isFalse);
    });

    test('isNullOrPositive', () {
      expect((null as num?).isNullOrPositive, isTrue);
      expect(1.isNullOrPositive, isTrue);
      expect(1.5.isNullOrPositive, isTrue);
      expect(0.isNullOrPositive, isFalse);
      expect((-1).isNullOrPositive, isFalse);
    });

    test('isNullOrNotFinite', () {
      expect((null as num?).isNullOrNotFinite, isTrue);
      expect(double.nan.isNullOrNotFinite, isTrue);
      expect(double.infinity.isNullOrNotFinite, isTrue);
      expect(double.negativeInfinity.isNullOrNotFinite, isTrue);
      expect(5.isNullOrNotFinite, isFalse);
      expect(5.5.isNullOrNotFinite, isFalse);
    });

    test('finiteOrNull', () {
      expect((null as num?).finiteOrNull, isNull);
      expect(double.nan.finiteOrNull, isNull);
      expect(double.infinity.finiteOrNull, isNull);
      expect(5.finiteOrNull, equals(5));
      expect(5.5.finiteOrNull, equals(5.5));
    });

    test('nonZeroOrNull', () {
      expect((null as num?).nonZeroOrNull, isNull);
      expect(0.nonZeroOrNull, isNull);
      expect(0.0.nonZeroOrNull, isNull);
      expect(5.nonZeroOrNull, equals(5));
      expect(5.5.nonZeroOrNull, equals(5.5));
    });

    test('orEmptyString', () {
      expect((null as num?).orEmptyString, isEmpty);
      expect(5.orEmptyString, equals('5'));
      expect(5.5.orEmptyString, equals('5.5'));
    });

    test('orDefaultIfNotFinite', () {
      expect((null as num?).orDefaultIfNotFinite(10), equals(10));
      expect(double.nan.orDefaultIfNotFinite(10), equals(10));
      expect(double.infinity.orDefaultIfNotFinite(10), equals(10));
      expect(double.negativeInfinity.orDefaultIfNotFinite(10), equals(10));
      expect(5.orDefaultIfNotFinite(10), equals(5));
      expect(5.5.orDefaultIfNotFinite(10), equals(5.5));
    });

    test('orDefaultIfZero', () {
      expect((null as num?).orDefaultIfZero(10), equals(10));
      expect(0.orDefaultIfZero(10), equals(10));
      expect(0.0.orDefaultIfZero(10), equals(10));
      expect(5.orDefaultIfZero(10), equals(5));
      expect(5.5.orDefaultIfZero(10), equals(5.5));
    });

    test('mapNotNull', () {
      expect((null as num?).mapNotNull((value) => value.toDouble()), isNull);
      expect(5.mapNotNull((value) => value * 2), equals(10));
      expect(5.5.mapNotNull((value) => value * 2), equals(11.0));
    });
  });

  group('BoolNullableX', () {
    test('orFalse', () {
      expect((null as bool?).orFalse, isFalse);
      expect(true.orFalse, isTrue);
      expect(false.orFalse, isFalse);
    });

    test('orTrue', () {
      expect((null as bool?).orTrue, isTrue);
      expect(true.orTrue, isTrue);
      expect(false.orTrue, isFalse);
    });

    test('isNullOrFalse', () {
      expect((null as bool?).isNullOrFalse, isTrue);
      expect(false.isNullOrFalse, isTrue);
      expect(true.isNullOrFalse, isFalse);
    });

    test('isNullOrTrue', () {
      expect((null as bool?).isNullOrTrue, isTrue);
      expect(true.isNullOrTrue, isTrue);
      expect(false.isNullOrTrue, isFalse);
    });

    test('isTrue / isFalse', () {
      expect((null as bool?).isTrue, isFalse);
      expect(true.isTrue, isTrue);
      expect(false.isTrue, isFalse);

      expect((null as bool?).isFalse, isFalse);
      expect(true.isFalse, isFalse);
      expect(false.isFalse, isTrue);
    });

    test('orDefault', () {
      expect((null as bool?).orDefault(fallback: true), isTrue);
      expect((null as bool?).orDefault(fallback: false), isFalse);
      expect(true.orDefault(fallback: false), isTrue);
      expect(false.orDefault(fallback: true), isFalse);
    });

    test('fold', () {
      String label({required bool? value}) => value.fold(
        whenTrue: () => 'true',
        whenFalse: () => 'false',
        whenNull: () => 'null',
      );

      expect(label(value: true), equals('true'));
      expect(label(value: false), equals('false'));
      expect(label(value: null), equals('null'));
    });

    test('whenTrue / whenFalse / whenNull', () {
      final calls = <String>[];

      true.whenTrue(() => calls.add('true'));
      true.whenFalse(() => calls.add('wrong'));
      true.whenNull(() => calls.add('wrong'));

      false.whenTrue(() => calls.add('wrong'));
      false.whenFalse(() => calls.add('false'));
      false.whenNull(() => calls.add('wrong'));

      (null as bool?).whenTrue(() => calls.add('wrong'));
      (null as bool?).whenFalse(() => calls.add('wrong'));
      (null as bool?).whenNull(() => calls.add('null'));

      expect(calls, equals(['true', 'false', 'null']));
    });
  });

  group('IntX', () {
    test('isEven / isOdd', () {
      expect(4.isEven, isTrue);
      expect(4.isOdd, isFalse);
      expect(5.isEven, isFalse);
      expect(5.isOdd, isTrue);
    });

    test('digitCount', () {
      expect(0.digitCount, equals(1));
      expect(5.digitCount, equals(1));
      expect(123.digitCount, equals(3));
      expect((-123).digitCount, equals(3));
    });

    test('digits', () {
      expect(1234.digits, equals([1, 2, 3, 4]));
      expect((-1234).digits, equals([1, 2, 3, 4]));
      expect(0.digits, equals([0]));
    });

    test('sign helpers', () {
      expect(5.isPositive, isTrue);
      expect(0.isPositive, isFalse);
      expect((-5).isPositive, isFalse);

      expect((-5).isNegative, isTrue);
      expect(0.isNegative, isFalse);
      expect(5.isNegative, isFalse);

      expect(0.isZero, isTrue);
      expect(5.isZero, isFalse);
    });

    test('nonNegative / nonPositive', () {
      expect(5.nonNegative, equals(5));
      expect(0.nonNegative, equals(0));
      expect((-5).nonNegative, equals(0));

      expect(5.nonPositive, equals(0));
      expect(0.nonPositive, equals(0));
      expect((-5).nonPositive, equals(-5));
    });

    test('isBetween', () {
      expect(5.isBetween(1, 10), isTrue);
      expect(5.isBetween(5, 10), isTrue);
      expect(5.isBetween(1, 5), isTrue);
      expect(5.isBetween(6, 10), isFalse);
    });

    test('isDivisibleBy / isMultipleOf', () {
      expect(10.isDivisibleBy(5), isTrue);
      expect(10.isDivisibleBy(3), isFalse);
      expect(10.isMultipleOf(5), isTrue);
      expect(10.isMultipleOf(3), isFalse);
      expect(() => 10.isDivisibleBy(0), throwsArgumentError);
      expect(() => 10.isMultipleOf(0), throwsArgumentError);
    });

    test('clampInt', () {
      expect(5.clampInt(1, 10), equals(5));
      expect((-5).clampInt(1, 10), equals(1));
      expect(15.clampInt(1, 10), equals(10));
      expect(() => 5.clampInt(10, 1), throwsArgumentError);
    });

    test('times', () {
      var count = 0;
      3.times(() => count++);
      expect(count, equals(3));

      var zeroCount = 0;
      0.times(() => zeroCount++);
      expect(zeroCount, equals(0));

      var negativeCount = 0;
      (-3).times(() => negativeCount++);
      expect(negativeCount, equals(0));
    });

    test('timesIndexed', () {
      final indexes = <int>[];
      3.timesIndexed(indexes.add);
      expect(indexes, equals([0, 1, 2]));

      final zeroIndexes = <int>[];
      0.timesIndexed(zeroIndexes.add);
      expect(zeroIndexes, isEmpty);

      final negativeIndexes = <int>[];
      (-3).timesIndexed(negativeIndexes.add);
      expect(negativeIndexes, isEmpty);
    });

    test('to', () {
      expect(1.to(5).toList(), equals([1, 2, 3, 4, 5]));
      expect(5.to(1).toList(), equals([5, 4, 3, 2, 1]));
      expect(1.to(5, step: 2).toList(), equals([1, 3, 5]));
      expect(5.to(1, step: 2).toList(), equals([5, 3, 1]));
      expect(() => 1.to(5, step: 0).toList(), throwsArgumentError);
      expect(() => 1.to(5, step: -1).toList(), throwsArgumentError);
    });
  });

  group('NumX', () {
    test('temperature conversions', () {
      expect(0.celsiusToFahrenheit, equals(32));
      expect(32.fahrenheitToCelsius, equals(0));
      expect(0.celsiusToKelvin, equals(273.15));
      expect(273.15.kelvinToCelsius, closeTo(0, 0.0001));
      expect(32.fahrenheitToKelvin, closeTo(273.15, 0.0001));
      expect(273.15.kelvinToFahrenheit, closeTo(32, 0.0001));
    });

    test('roundTo', () {
      expect(3.14159.roundTo(2), equals(3.14));
      expect(3.145.roundTo(2), equals(3.15));
      expect(3.145.roundTo(0), equals(3.0));
      expect(() => 3.145.roundTo(-1), throwsArgumentError);
    });

    test('roundToMultiple', () {
      expect(27.roundToMultiple(5), equals(25));
      expect(28.roundToMultiple(5), equals(30));
      expect(() => 28.roundToMultiple(0), throwsArgumentError);
    });

    test('floorToMultiple', () {
      expect(27.floorToMultiple(5), equals(25));
      expect(29.floorToMultiple(5), equals(25));
      expect(() => 29.floorToMultiple(0), throwsArgumentError);
    });

    test('ceilToMultiple', () {
      expect(21.ceilToMultiple(5), equals(25));
      expect(25.ceilToMultiple(5), equals(25));
      expect(() => 25.ceilToMultiple(0), throwsArgumentError);
    });

    test('normalized / normalizedClamped / safeNormalized', () {
      expect(5.normalized(0, 10), equals(0.5));
      expect(15.normalized(0, 10), equals(1.5));
      expect(15.normalizedClamped(0, 10), equals(1.0));
      expect((-5).normalizedClamped(0, 10), equals(0.0));
      expect(() => 5.normalized(10, 10), throwsArgumentError);

      expect(5.safeNormalized(10, 10, fallback: 0.5), equals(0.5));
    });

    test('isZero / isNotZero', () {
      expect(0.isZero, isTrue);
      expect(0.0.isZero, isTrue);
      expect(5.isZero, isFalse);

      expect(0.isNotZero, isFalse);
      expect(0.0.isNotZero, isFalse);
      expect(5.isNotZero, isTrue);
    });

    test('squared / cubed', () {
      expect(4.squared, equals(16));
      expect((-4).squared, equals(16));
      expect(2.5.squared, equals(6.25));

      expect(3.cubed, equals(27));
      expect((-3).cubed, equals(-27));
      expect(2.5.cubed, equals(15.625));
    });

    test('reciprocal', () {
      expect(4.reciprocal, equals(0.25));
      expect(0.5.reciprocal, equals(2.0));
      expect(() => 0.reciprocal, throwsArgumentError);
    });

    test('isBetween', () {
      expect(5.5.isBetween(1.0, 10.0), isTrue);
      expect(5.5.isBetween(5.5, 10.0), isTrue);
      expect(5.5.isBetween(1.0, 5.0), isFalse);
    });

    test('isCloseTo', () {
      expect(0.1 + 0.2, isNot(equals(0.3)));
      expect((0.1 + 0.2).isCloseTo(0.3), isTrue);
      expect(10.isCloseTo(10.2, tolerance: 0.1), isFalse);
      expect(10.isCloseTo(10.2, tolerance: 0.2), isTrue);
      expect(() => 10.isCloseTo(10, tolerance: -0.1), throwsArgumentError);
    });

    test('percentageOf / safePercentageOf', () {
      expect(25.percentageOf(100), equals(25.0));
      expect(1.percentageOf(4), equals(25.0));
      expect(() => 25.percentageOf(0), throwsArgumentError);

      expect(25.safePercentageOf(100), equals(25.0));
      expect(25.safePercentageOf(0), equals(0.0));
      expect(25.safePercentageOf(0, fallback: -1), equals(-1.0));
    });

    test('clampNum', () {
      expect(5.clampNum(1, 10), equals(5));
      expect((-5).clampNum(1, 10), equals(1));
      expect(15.clampNum(1, 10), equals(10));
      expect(5.5.clampNum(1.5, 5.0), equals(5.0));
      expect(() => 5.clampNum(10, 1), throwsArgumentError);
    });

    test('isWholeNumber', () {
      expect(5.isWholeNumber, isTrue);
      expect(5.0.isWholeNumber, isTrue);
      expect(5.5.isWholeNumber, isFalse);
    });

    test('lerp', () {
      expect(0.25.lerp(0, 100), equals(25.0));
      expect(0.5.lerp(10, 20), equals(15.0));
    });
  });
}
