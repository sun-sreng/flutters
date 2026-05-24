import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('EmailValidator', () {
    test('validates valid email patterns', () {
      const validator = EmailValidator();
      expect(validator.validate('test@example.com').isRight(), true);
      expect(validator.validate('user.name+tag@domain.co.uk').isRight(), true);
      validator
          .validate(' USER@Example.COM ')
          .fold((l) => fail('should be right'), (email) => expect(email, 'user@example.com'));
    });

    test('returns EmailEmpty for empty string', () {
      const validator = EmailValidator();
      validator.validate('').fold((l) => expect(l, isA<EmailEmpty>()), (r) => fail('should be left'));
    });

    test('returns EmailInvalidFormat for invalid patterns', () {
      const validator = EmailValidator();
      validator
          .validate('invalid-email')
          .fold((l) => expect(l, isA<EmailInvalidFormat>()), (r) => fail('should be left'));
      validator
          .validate('@missingusername.com')
          .fold((l) => expect(l, isA<EmailInvalidFormat>()), (r) => fail('should be left'));
      validator.validate('user@.com').fold((l) => expect(l, isA<EmailInvalidFormat>()), (r) => fail('should be left'));
    });

    test('checks max lengths', () {
      const validator = EmailValidator(
        EmailValidationConfig(maxLength: 20, maxLocalPartLength: 10, maxDomainLength: 10),
      );

      // Local part too long > 10
      validator.validate('12345678901@a.com').fold((l) {
        expect(l, isA<EmailLocalPartTooLong>());
        final error = l as EmailLocalPartTooLong;
        expect(error.currentLength, 11);
        expect(error.maxLength, 10);
      }, (r) => fail('should be left'));

      // Domain too long > 10
      validator.validate('test@1234567890.com').fold((l) {
        expect(l, isA<EmailDomainTooLong>());
        final error = l as EmailDomainTooLong;
        expect(error.currentLength, 14);
        expect(error.maxLength, 10);
      }, (r) => fail('should be left'));

      // Total too long > 20 (9 + 1 + 11 = 21)
      validator.validate('123456789@1234567.com').fold((l) {
        expect(l, isA<EmailTooLong>());
        final error = l as EmailTooLong;
        expect(error.currentLength, 21);
        expect(error.maxLength, 20);
      }, (r) => fail('should be left'));
    });

    test('blocks disposable domains if not allowed', () {
      const strictValidator = EmailValidator(
        EmailValidationConfig(allowDisposable: false, disposableDomains: {' TempMail.com '}),
      );
      strictValidator
          .validate('test@tempmail.com')
          .fold((l) => expect(l, isA<EmailDisposableDomain>()), (r) => fail('should be left'));

      const lenientValidator = EmailValidator(EmailValidationConfig(allowDisposable: true));
      expect(lenientValidator.validate('test@tempmail.com').isRight(), true);
    });

    test('blocks custom blocklisted domains', () {
      const validator = EmailValidator(EmailValidationConfig(blockedDomains: {' BANNED.com '}));
      validator
          .validate('test@banned.com')
          .fold((l) => expect(l, isA<EmailBlockedDomain>()), (r) => fail('should be left'));
    });
  });

  group('Email Value Object', () {
    test('creates valid Email', () {
      final email = Email('test@example.com');
      expect(email.isValid, true);
      expect(email.valueOrNull, 'test@example.com');
      expect(email.errorOrNull, null);
      expect(email.toString(), 'Email(test@example.com)');
    });

    test('creates invalid Email', () {
      final email = Email('invalid');
      expect(email.isInvalid, true);
      expect(email.errorOrNull, isA<EmailInvalidFormat>());
      expect(email.errorOrNull?.code, 'email_invalid_format');
      expect(email.toString(), 'Email(invalid)');
    });

    test('creates Email from validated result', () {
      final validated = const EmailValidator().validate('test@example.com');
      final email = Email.validated(validated);

      expect(email.isValid, true);
      expect(email.valueOrNull, 'test@example.com');
    });
  });
}
