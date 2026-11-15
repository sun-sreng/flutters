import 'package:gmana/validation.dart';
import 'package:test/test.dart';

void main() {
  group('NumberValidator', () {
    test('rejects empty values', () {
      final result = const NumberValidator().validate('');

      expect(result.leftOrNull(), isA<NumberEmptyIssue>());
    });

    test('trims and parses valid numbers', () {
      final result = const NumberValidator().validate(' 12.5 ');

      expect(result.rightOrNull(), 12.5);
    });

    test('rejects malformed values', () {
      final result = const NumberValidator().validate('abc');

      expect(result.leftOrNull(), isA<NumberInvalidFormatIssue>());
    });

    test('enforces integer-only validation', () {
      final result = const NumberValidator(
        NumberValidationConfig(integerOnly: true),
      ).validate('12.5');

      expect(result.leftOrNull(), isA<NumberNotIntegerIssue>());
    });

    test('enforces negativity and bounds', () {
      const validator = NumberValidator(
        NumberValidationConfig(allowNegative: false, min: 10, max: 20),
      );

      expect(
        validator.validate('-1').leftOrNull(),
        isA<NumberNegativeNotAllowedIssue>(),
      );
      expect(validator.validate('9').leftOrNull(), isA<NumberTooSmallIssue>());
      expect(validator.validate('21').leftOrNull(), isA<NumberTooLargeIssue>());
      expect(validator.validate('15').rightOrNull(), 15);
    });

    test('enforces decimal-place limits', () {
      final result = const NumberValidator(
        NumberValidationConfig(maxDecimalPlaces: 2),
      ).validate('1.234');

      expect(result.leftOrNull(), isA<NumberDecimalPlacesExceededIssue>());
    });

    group('accepts plain decimal notation only', () {
      final price = NumberValidator(NumberValidationConfig.price());

      test('rejects exponent notation', () {
        // 1e-5 has five decimal places, more than price() allows.
        expect(
          price.validate('1e-5').leftOrNull(),
          isA<NumberInvalidFormatIssue>(),
        );
        expect(
          const NumberValidator().validate('1.5E3').leftOrNull(),
          isA<NumberInvalidFormatIssue>(),
        );
      });

      test('rejects hexadecimal', () {
        expect(
          const NumberValidator().validate('0x1F').leftOrNull(),
          isA<NumberInvalidFormatIssue>(),
        );
      });

      test('still accepts signs and bare decimal points', () {
        const validator = NumberValidator();

        expect(validator.validate('+5').rightOrNull(), 5);
        expect(validator.validate('-2.50').rightOrNull(), -2.5);
        expect(validator.validate('.5').rightOrNull(), 0.5);
        expect(validator.validate('5.').rightOrNull(), 5);
        expect(price.validate('19.99').rightOrNull(), 19.99);
      });
    });
  });
}
