import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('PhoneValidator', () {
    const validator = PhoneValidator();

    test('validates and normalizes valid phone numbers', () {
      final res = validator.validate('+1 (415) 555-2671');
      expect(res.isRight(), isTrue);
      expect(res.getOrElse((_) => ''), '+14155552671');
    });

    test('rejects empty input', () {
      final res = validator.validate('');
      expect(res.isLeft(), isTrue);
      expect(res.fold((issue) => issue, (_) => null), isA<PhoneEmptyIssue>());
    });

    test('enforces requirePlusPrefix when configured', () {
      final e164Validator = PhoneValidator(PhoneValidationConfig.e164());

      final res1 = e164Validator.validate('14155552671');
      expect(res1.isLeft(), isTrue);
      expect(
        res1.fold((issue) => issue, (_) => null),
        isA<PhoneMissingPlusIssue>(),
      );

      final res2 = e164Validator.validate('+14155552671');
      expect(res2.isRight(), isTrue);
    });

    test('enforces min and max digit constraints', () {
      const minValidator = PhoneValidator(
        PhoneValidationConfig(minDigits: 10, maxDigits: 12),
      );

      final tooShort = minValidator.validate('12345');
      expect(tooShort.isLeft(), isTrue);
      expect(
        tooShort.fold((issue) => issue, (_) => null),
        isA<PhoneTooShortIssue>(),
      );

      final tooLong = minValidator.validate('123456789012345');
      expect(tooLong.isLeft(), isTrue);
      expect(
        tooLong.fold((issue) => issue, (_) => null),
        isA<PhoneTooLongIssue>(),
      );
    });
  });
}
