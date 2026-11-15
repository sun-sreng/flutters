import 'package:gmana/validation.dart';
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

    group('minDate and maxDate', () {
      // Local bounds: the calendar day as written must not depend on the
      // timezone the test runs in.
      final validator = DateValidator(
        DateValidationConfig(
          minDate: DateTime(2024, 1, 1),
          maxDate: DateTime(2024, 1, 31),
        ),
      );

      test('a date-only input on either bound is accepted', () {
        expect(validator.validate('2024-01-01').isRight(), isTrue);
        expect(validator.validate('2024-01-31').isRight(), isTrue);
        expect(validator.validate('20240131').isRight(), isTrue);
      });

      test('a date-only input outside the bounds is rejected', () {
        expect(
          validator.validate('2023-12-31').leftOrNull(),
          isA<DateBeforeMinIssue>(),
        );
        expect(
          validator.validate('2024-02-01').leftOrNull(),
          isA<DateAfterMaxIssue>(),
        );
      });

      test('UTC bounds compare by their UTC calendar day', () {
        final utcValidator = DateValidator(
          DateValidationConfig(maxDate: DateTime.utc(2024, 1, 31, 23)),
        );

        expect(utcValidator.validate('2024-01-31').isRight(), isTrue);
        expect(utcValidator.validate('2024-02-01').isLeft(), isTrue);
      });

      test('an input with a time is compared as an instant', () {
        final instantValidator = DateValidator(
          DateValidationConfig(minDate: DateTime.utc(2024, 1, 1, 12)),
        );

        expect(
          instantValidator.validate('2024-01-01T11:59:59Z').leftOrNull(),
          isA<DateBeforeMinIssue>(),
        );
        expect(
          instantValidator.validate('2024-01-01T12:00:00Z').isRight(),
          isTrue,
        );
      });
    });
  });
}
