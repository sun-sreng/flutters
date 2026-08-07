import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('IdentifierValidator', () {
    test('validates UUIDs', () {
      const validator = IdentifierValidator(
        IdentifierValidationConfig(requiredType: IdentifierType.uuid),
      );

      final valid = validator.validate('f47ac10b-58cc-4372-a567-0e02b2c3d479');
      final invalid = validator.validate('not-a-uuid');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<IdentifierInvalidUuidIssue>());
      expect(
        resolveIdentifierValidationIssue(
          invalid.leftOrNull() as IdentifierValidationIssue,
        ),
        equals('Invalid UUID format'),
      );
    });

    test('validates ULIDs', () {
      const validator = IdentifierValidator(
        IdentifierValidationConfig(requiredType: IdentifierType.ulid),
      );

      final valid = validator.validate('01ARZ3NDEKTSV4RRFFQ69G5FAV');
      final invalid = validator.validate('short-ulid');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<IdentifierInvalidUlidIssue>());
    });

    test('validates Credit Cards', () {
      const validator = IdentifierValidator(
        IdentifierValidationConfig(requiredType: IdentifierType.creditCard),
      );

      final valid = validator.validate('4111111111111111');
      final invalid = validator.validate('1234567890123456');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<IdentifierInvalidCreditCardIssue>());
    });

    test('validates MongoId', () {
      const validator = IdentifierValidator(
        IdentifierValidationConfig(requiredType: IdentifierType.mongoId),
      );

      final valid = validator.validate('507f1f77bcf86cd799439011');
      final invalid = validator.validate('507f1f77bcf86cd79943901');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<IdentifierInvalidMongoIdIssue>());
    });

  });
}
