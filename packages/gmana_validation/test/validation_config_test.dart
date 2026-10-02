import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('config equality', () {
    test('value-equal configs are equal and share a hash code', () {
      const phoneA = PhoneValidationConfig(minDigits: 9);
      const phoneB = PhoneValidationConfig(minDigits: 9);
      expect(phoneA, phoneB);
      expect(phoneA.hashCode, phoneB.hashCode);

      const urlA = UrlValidationConfig(allowedSchemes: {'https', 'wss'});
      const urlB = UrlValidationConfig(allowedSchemes: {'wss', 'https'});
      expect(urlA, urlB);
      expect(urlA.hashCode, urlB.hashCode);

      const emailA = EmailValidationConfig(blockedDomains: {'a.com', 'b.com'});
      const emailB = EmailValidationConfig(blockedDomains: {'b.com', 'a.com'});
      expect(emailA, emailB);
      expect(emailA.hashCode, emailB.hashCode);

      expect(
        const IdentifierValidationConfig(uuidVersion: '4'),
        const IdentifierValidationConfig(uuidVersion: '4'),
      );
      expect(
        const NetworkValidationConfig(ipVersion: 6),
        const NetworkValidationConfig(ipVersion: 6),
      );
      expect(
        const NumberValidationConfig(min: 1, max: 5),
        const NumberValidationConfig(min: 1, max: 5),
      );
    });

    test('different configs are not equal', () {
      expect(
        const PhoneValidationConfig(minDigits: 9),
        isNot(const PhoneValidationConfig(minDigits: 10)),
      );
      expect(
        const EmailValidationConfig(rejectDisposable: true),
        isNot(const EmailValidationConfig()),
      );
      expect(
        const NumberValidationConfig(integerOnly: true),
        isNot(const NumberValidationConfig()),
      );
    });
  });

  group('config copyWith', () {
    test('replaces only the provided fields', () {
      const phone = PhoneValidationConfig(requirePlusPrefix: true);
      final changed = phone.copyWith(minDigits: 10);

      expect(changed.requirePlusPrefix, isTrue);
      expect(changed.minDigits, 10);
      expect(changed.maxDigits, phone.maxDigits);
      expect(phone.copyWith(), phone);
    });

    test('email keeps the domain lists unless replaced', () {
      const email = EmailValidationConfig(blockedDomains: {'blocked.com'});
      final changed = email.copyWith(
        rejectDisposable: true,
        matchSubdomains: false,
      );

      expect(changed.rejectDisposable, isTrue);
      expect(changed.matchSubdomains, isFalse);
      expect(changed.blockedDomains, {'blocked.com'});
      expect(changed.disposableDomains, email.disposableDomains);
    });

    test('passing null clears a nullable field', () {
      const identifier = IdentifierValidationConfig(
        uuidVersion: '4',
        eanVersion: '13',
      );
      expect(identifier.copyWith(uuidVersion: null).uuidVersion, isNull);
      expect(identifier.copyWith(uuidVersion: null).eanVersion, '13');

      const network = NetworkValidationConfig(ipVersion: 4);
      expect(network.copyWith(ipVersion: null).ipVersion, isNull);
      expect(network.copyWith().ipVersion, 4);

      const number = NumberValidationConfig(min: 1, max: 9);
      expect(number.copyWith(max: null).max, isNull);
      expect(number.copyWith(max: null).min, 1);
    });
  });

  group('number presets', () {
    test('positiveInteger accepts zero and rejects negatives', () {
      final validator = NumberValidator(
        NumberValidationConfig.positiveInteger(),
      );

      expect(validator.validate('0').isRight(), isTrue);
      expect(
        validator.validate('-1').leftOrNull(),
        isA<NumberNegativeNotAllowedIssue>(),
      );
      expect(
        validator.validate('1.5').leftOrNull(),
        isA<NumberNotIntegerIssue>(),
      );
    });

    test('positiveInteger still takes explicit bounds', () {
      final config = NumberValidationConfig.positiveInteger(min: 13, max: 120);

      expect(config.min, 13);
      expect(config.max, 120);
    });

    test('naturalNumber, percentage, price, age and rating apply bounds', () {
      expect(
        NumberValidator(
          NumberValidationConfig.naturalNumber(),
        ).validate('0').leftOrNull(),
        isA<NumberTooSmallIssue>(),
      );
      expect(
        NumberValidator(
          NumberValidationConfig.percentage(),
        ).validate('101').leftOrNull(),
        isA<NumberTooLargeIssue>(),
      );
      expect(
        NumberValidator(
          NumberValidationConfig.price(),
        ).validate('9.999').leftOrNull(),
        isA<NumberDecimalPlacesExceededIssue>(),
      );
      expect(
        NumberValidator(
          NumberValidationConfig.age(),
        ).validate('151').leftOrNull(),
        isA<NumberTooLargeIssue>(),
      );
      expect(
        NumberValidator(
          NumberValidationConfig.rating(),
        ).validate('5').isRight(),
        isTrue,
      );
    });
  });
}
