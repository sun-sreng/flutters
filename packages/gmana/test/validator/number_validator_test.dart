import 'package:gmana/validator/number_field_validator.dart';
import 'package:test/test.dart';

void main() {
  group('NumberFieldValidator', () {
    test('rejects empty values', () {
      expect(
        const NumberFieldValidator().validate(null),
        'Please enter a number',
      );
      expect(
        const NumberFieldValidator().validate(''),
        'Please enter a number',
      );
    });

    test('rejects non-numeric values', () {
      expect(
        const NumberFieldValidator().validate('abc'),
        'Please enter a valid number',
      );
    });

    test('validates bounds', () {
      const validator = NumberFieldValidator(minValue: 10, maxValue: 20);
      expect(validator.validate('9'), 'Number must be at least 10');
      expect(validator.validate('21'), 'Number must be at most 20');
      expect(validator.validate('15'), isNull);
    });
  });
}
