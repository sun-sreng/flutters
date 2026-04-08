import 'package:test/test.dart';
import 'package:value_objects/value_objects.dart';

void main() {
  group('NumberValidator', () {
    test('validates valid numbers', () {
      const validator = NumberValidator();
      expect(validator.validate('42').isRight(), true);
      expect(validator.validate('3.14').isRight(), true);
      expect(validator.validate('-10').isRight(), true);

      final rightVal = validator.validate('42');
      rightVal.match((l) => fail('should be right'), (r) => expect(r, 42));
    });

    test('returns NumberEmpty for empty string', () {
      const validator = NumberValidator();
      final result = validator.validate('');
      expect(result.isLeft(), true);

      result.match((l) => expect(l, isA<NumberEmpty>()), (r) => fail('should be left'));
    });

    test('returns NumberInvalidFormat for unparsable string', () {
      const validator = NumberValidator();
      final result = validator.validate('abc');

      result.match((l) => expect(l, isA<NumberInvalidFormat>()), (r) => fail('should be left'));
    });

    test('respects min/max config', () {
      const validator = NumberValidator(NumberValidationConfig(min: 0, max: 100));

      final minVal = validator.validate('-1');
      minVal.match((l) => expect(l, isA<NumberTooSmall>()), (r) => fail('should be left'));

      final maxVal = validator.validate('101');
      maxVal.match((l) => expect(l, isA<NumberTooLarge>()), (r) => fail('should be left'));

      expect(validator.validate('50').isRight(), true);
    });

    test('validates percentage config correctly', () {
      final config = NumberValidationConfig.percentage();
      final validator = NumberValidator(config);

      expect(validator.validate('100').isRight(), true);
      expect(validator.validate('0').isRight(), true);
      expect(validator.validate('50.5').isRight(), true);

      validator.validate('-1').match((l) => expect(l, isA<NumberNegativeNotAllowed>()), (r) => fail('should be left'));

      validator.validate('101').match((l) => expect(l, isA<NumberTooLarge>()), (r) => fail('should be left'));
    });
  });
}
