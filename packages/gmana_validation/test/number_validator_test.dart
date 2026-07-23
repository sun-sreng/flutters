import 'package:gmana_validation/gmana_validation.dart';
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
  });
}
