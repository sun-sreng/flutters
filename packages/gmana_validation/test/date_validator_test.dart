import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('DateValidator', () {
    test('validates ISO date format and parses DateTime', () {
      const validator = DateValidator();

      final valid = validator.validate('2026-08-07T00:00:00Z');
      final invalid = validator.validate('invalid-date');

      expect(valid.isRight(), isTrue);
      expect(valid.rightOrNull(), isA<DateTime>());
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<DateInvalidFormatIssue>());
    });

    test('validates past and future date constraints', () {
      const pastValidator = DateValidator(
        DateValidationConfig(mustBePast: true),
      );

      final validPast = pastValidator.validate('2000-01-01T00:00:00Z');
      final invalidPast = pastValidator.validate('2099-01-01T00:00:00Z');

      expect(validPast.isRight(), isTrue);
      expect(invalidPast.isLeft(), isTrue);
      expect(invalidPast.leftOrNull(), isA<DateNotPastIssue>());
    });

    test('validates time format (24-hour)', () {
      const timeValidator = DateValidator(
        DateValidationConfig(mustBeTime: true),
      );

      final valid = timeValidator.validate('14:30:00');
      final invalid = timeValidator.validate('25:00:00');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<DateInvalidTimeIssue>());
    });

  });
}
