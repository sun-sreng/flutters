import 'package:test/test.dart';
import 'package:gmana_value_objects/gmana_value_objects.dart';

void main() {
  group('EmailValidator', () {
    test('validates valid email patterns', () {
      const validator = EmailValidator();
      expect(validator.validate('test@example.com').isRight(), true);
      expect(validator.validate('user.name+tag@domain.co.uk').isRight(), true);
    });

    test('returns EmailEmpty for empty string', () {
      const validator = EmailValidator();
      validator
          .validate('')
          .fold(
            (l) => expect(l, isA<EmailEmpty>()),
            (r) => fail('should be left'),
          );
    });

    test('returns EmailInvalidFormat for invalid patterns', () {
      const validator = EmailValidator();
      validator
          .validate('invalid-email')
          .fold(
            (l) => expect(l, isA<EmailInvalidFormat>()),
            (r) => fail('should be left'),
          );
      validator
          .validate('@missingusername.com')
          .fold(
            (l) => expect(l, isA<EmailInvalidFormat>()),
            (r) => fail('should be left'),
          );
      validator
          .validate('user@.com')
          .fold(
            (l) => expect(l, isA<EmailInvalidFormat>()),
            (r) => fail('should be left'),
          );
    });

    test('checks max lengths', () {
      const validator = EmailValidator(
        EmailValidationConfig(
          maxLength: 20,
          maxLocalPartLength: 10,
          maxDomainLength: 10,
        ),
      );

      // Local part too long > 10
      validator
          .validate('12345678901@a.com')
          .fold(
            (l) => expect(l, isA<EmailLocalPartTooLong>()),
            (r) => fail('should be left'),
          );

      // Domain too long > 10
      validator
          .validate('test@1234567890.com')
          .fold(
            (l) => expect(l, isA<EmailDomainTooLong>()),
            (r) => fail('should be left'),
          );

      // Total too long > 20 (9 + 1 + 11 = 21)
      validator
          .validate('123456789@1234567.com')
          .fold(
            (l) => expect(l, isA<EmailTooLong>()),
            (r) => fail('should be left'),
          );
    });

    test('blocks disposable domains if not allowed', () {
      final strictValidator = EmailValidator(EmailValidationConfig.strict());
      strictValidator
          .validate('test@tempmail.com')
          .fold(
            (l) => expect(l, isA<EmailDisposableDomain>()),
            (r) => fail('should be left'),
          );

      const lenientValidator = EmailValidator(
        EmailValidationConfig(allowDisposable: true),
      );
      expect(lenientValidator.validate('test@tempmail.com').isRight(), true);
    });

    test('blocks custom blocklisted domains', () {
      const validator = EmailValidator(
        EmailValidationConfig(blockedDomains: {' BANNED.com '}),
      );
      validator
          .validate('test@banned.com')
          .fold(
            (l) => expect(l, isA<EmailBlockedDomain>()),
            (r) => fail('should be left'),
          );
    });
  });

  group('Email Value Object', () {
    test('creates valid Email', () {
      final email = Email('test@example.com');
      expect(email.isValid, true);
      expect(email.valueOrNull, 'test@example.com');
      expect(email.toString(), 'Email(test@example.com)');
    });

    test('creates invalid Email', () {
      final email = Email('invalid');
      expect(email.isInvalid, true);
      expect(email.errorOrNull, isA<EmailInvalidFormat>());
      expect(email.errorOrNull?.code, 'email_invalid_format');
      expect(email.toString(), 'Email(invalid)');
    });
  });
}
