import 'package:gmana_validation/gmana_validation.dart' as v;
import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('Validation to ValueObject Adapters', () {
    test('EmailValidationAdapterX adapts valid and invalid email results', () {
      const validator = v.EmailValidator();

      final validResult = validator.validate('user@example.com');
      final emailVo = validResult.toEmailValueObject();
      expect(emailVo.isRight(), isTrue);
      expect(emailVo.getRight().value, equals('user@example.com'));

      final domainResult = validResult.toEmailDomainResult();
      expect(domainResult.isRight(), isTrue);
      expect(domainResult.getRight().value, equals('user@example.com'));

      final emptyResult = validator.validate('');
      final emptyDomain = emptyResult.toEmailDomainResult();
      expect(emptyDomain.isLeft(), isTrue);
      expect(emptyDomain.getLeft(), isA<EmailEmpty>());
    });

    test('PasswordValidationAdapterX adapts password results', () {
      const validator = v.PasswordValidator();

      final validResult = validator.validate('SecureP@ssw0rd123');
      final passVo = validResult.toPasswordValueObject();
      expect(passVo.isRight(), isTrue);
      expect(passVo.getRight().value, equals('SecureP@ssw0rd123'));

      final shortResult = validator.validate('123');
      final shortDomain = shortResult.toPasswordDomainResult();
      expect(shortDomain.isLeft(), isTrue);
      expect(shortDomain.getLeft(), isA<PasswordTooShort>());
    });

    test('PhoneValidationAdapterX adapts phone results', () {
      const validator = v.PhoneValidator(
        v.PhoneValidationConfig(requirePlusPrefix: true),
      );

      final validResult = validator.validate('+14155552671');
      final phoneVo = validResult.toPhoneValueObject();
      expect(phoneVo.isRight(), isTrue);
      expect(phoneVo.getRight().value, equals('+14155552671'));

      final invalidResult = validator.validate('1234567890');
      final invalidDomain = invalidResult.toPhoneDomainResult();
      expect(invalidDomain.isLeft(), isTrue);
      expect(invalidDomain.getLeft(), isA<PhoneMissingPlus>());
    });

    test('UrlValidationAdapterX adapts URL results', () {
      const validator = v.UrlValidator();

      final validResult = validator.validate('https://example.com/api');
      final urlVo = validResult.toUrlValueObject();
      expect(urlVo.isRight(), isTrue);
      expect(
        urlVo.getRight().value.toString(),
        equals('https://example.com/api'),
      );

      final invalidResult = validator.validate('ftp://example.com');
      final invalidDomain = invalidResult.toUrlDomainResult();
      expect(invalidDomain.isLeft(), isTrue);
      expect(invalidDomain.getLeft(), isA<UrlDisallowedScheme>());
    });

    test('TextValidationAdapterX adapts text results', () {
      final validator = v.TextValidator(
        const v.TextValidationConfig(allowEmpty: false),
      );

      final validResult = validator.validate('Hello World');
      final textVo = validResult.toTextValueObject();
      expect(textVo.isRight(), isTrue);
      expect(textVo.getRight().value, equals('Hello World'));

      final emptyResult = validator.validate('');
      final emptyDomain = emptyResult.toTextDomainResult();
      expect(emptyDomain.isLeft(), isTrue);
      expect(emptyDomain.getLeft(), isA<TextEmpty>());
    });

    test('NumberValidationAdapterX adapts number results', () {
      const validator = v.NumberValidator(
        v.NumberValidationConfig(allowNegative: false),
      );

      final validResult = validator.validate('42');
      final numVo = validResult.toNumberValueObject();
      expect(numVo.isRight(), isTrue);
      expect(numVo.getRight().value, equals(42));

      final negativeResult = validator.validate('-5');
      final negDomain = negativeResult.toNumberDomainResult();
      expect(negDomain.isLeft(), isTrue);
      expect(negDomain.getLeft(), isA<NumberNegativeNotAllowed>());
    });
  });
}
