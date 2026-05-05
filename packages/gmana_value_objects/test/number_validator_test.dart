import 'package:test/test.dart';
import 'package:gmana_value_objects/gmana_value_objects.dart';

void main() {
  group('NumberValidator', () {
    test('validates valid numbers', () {
      const validator = NumberValidator();
      expect(validator.validate('42').isRight(), true);
      expect(validator.validate('3.14').isRight(), true);
      expect(validator.validate('-10').isRight(), true);

      final rightVal = validator.validate('42');
      rightVal.fold((l) => fail('should be right'), (r) => expect(r, 42));
    });

    test('returns NumberEmpty for empty string', () {
      const validator = NumberValidator();
      final result = validator.validate('');
      expect(result.isLeft(), true);

      result.fold(
        (l) => expect(l, isA<NumberEmpty>()),
        (r) => fail('should be left'),
      );
    });

    test('returns NumberInvalidFormat for unparsable string', () {
      const validator = NumberValidator();
      for (final input in ['abc', 'NaN', 'Infinity', '-Infinity']) {
        validator
            .validate(input)
            .fold(
              (l) => expect(l, isA<NumberInvalidFormat>()),
              (r) => fail('should be left'),
            );
      }
    });

    test('respects min/max config', () {
      const validator = NumberValidator(
        NumberValidationConfig(min: 0, max: 100),
      );

      final minVal = validator.validate('-1');
      minVal.fold(
        (l) => expect(l, isA<NumberTooSmall>()),
        (r) => fail('should be left'),
      );

      final maxVal = validator.validate('101');
      maxVal.fold(
        (l) => expect(l, isA<NumberTooLarge>()),
        (r) => fail('should be left'),
      );

      expect(validator.validate('50').isRight(), true);
    });

    test('counts decimal places from decimal input', () {
      const validator = NumberValidator(
        NumberValidationConfig(maxDecimalPlaces: 2),
      );

      expect(validator.validate('1.23').isRight(), true);
      validator.validate('1.230').fold((l) {
        expect(l, isA<NumberDecimalPlacesExceeded>());
        final error = l as NumberDecimalPlacesExceeded;
        expect(error.currentPlaces, 3);
        expect(error.maxPlaces, 2);
      }, (r) => fail('should be left'));
    });

    test('validates percentage config correctly', () {
      final config = NumberValidationConfig.percentage();
      final validator = NumberValidator(config);

      expect(validator.validate('100').isRight(), true);
      expect(validator.validate('0').isRight(), true);
      expect(validator.validate('50.5').isRight(), true);

      validator
          .validate('-1')
          .fold(
            (l) => expect(l, isA<NumberNegativeNotAllowed>()),
            (r) => fail('should be left'),
          );

      validator
          .validate('101')
          .fold(
            (l) => expect(l, isA<NumberTooLarge>()),
            (r) => fail('should be left'),
          );
    });
  });
}
