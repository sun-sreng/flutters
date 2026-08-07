import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('IdentifierValue', () {
    test('parses valid UUID successfully', () {
      const config = IdentifierValidationConfig(requiredType: IdentifierType.uuid);
      final result = IdentifierValue.tryParse(
        'f47ac10b-58cc-4372-a567-0e02b2c3d479',
        config: config,
      );

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull()?.value, equals('f47ac10b-58cc-4372-a567-0e02b2c3d479'));
    });

    test('rejects invalid UUID format', () {
      const config = IdentifierValidationConfig(requiredType: IdentifierType.uuid);
      final result = IdentifierValue.tryParse('invalid-uuid', config: config);

      expect(result.isLeft(), isTrue);
      expect(result.leftOrNull(), isA<IdentifierInvalidUuid>());
    });

    test('constructor succeeds for valid input and throws for invalid input', () {
      expect(
        () => IdentifierValue('01ARZ3NDEKTSV4RRFFQ69G5FAV', config: const IdentifierValidationConfig(requiredType: IdentifierType.ulid)),
        returnsNormally,
      );

      expect(
        () => IdentifierValue('short', config: const IdentifierValidationConfig(requiredType: IdentifierType.ulid)),
        throwsA(isA<ValueObjectException>()),
      );
    });
  });
}
