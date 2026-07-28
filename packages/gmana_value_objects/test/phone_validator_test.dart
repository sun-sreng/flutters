import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('PhoneValue and PhoneValidator', () {
    test('PhoneValue constructs trusted values and throws on error', () {
      final phone = PhoneValue('+1 (415) 555-2671');
      expect(phone.value, '+14155552671');
      expect(phone.toString(), 'PhoneValue(+14155552671)');

      expect(() => PhoneValue(''), throwsA(isA<ValueObjectException>()));
    });

    test('PhoneValue.tryParse returns Either', () {
      final res1 = PhoneValue.tryParse('+14155552671');
      expect(res1.isRight(), isTrue);

      final res2 = PhoneValue.tryParse('');
      expect(res2.isLeft(), isTrue);
      expect(res2.fold((e) => e, (_) => null), isA<PhoneEmpty>());
    });

    test('PhoneValidator respects E.164 configuration', () {
      final validator = PhoneValidator(PhoneValidationConfig.e164());

      final res1 = validator.validate('14155552671');
      expect(res1.isLeft(), isTrue);
      expect(res1.fold((e) => e, (_) => null), isA<PhoneMissingPlus>());

      final res2 = validator.validate('+14155552671');
      expect(res2.isRight(), isTrue);
    });
  });
}
