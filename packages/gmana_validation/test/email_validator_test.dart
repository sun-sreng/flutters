import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('EmailValidator', () {
    test('rejects empty values', () {
      final result = const EmailValidator().validate('');

      expect(result.leftOrNull(), isA<EmailEmptyIssue>());
    });

    test('normalizes valid emails by trimming and lowercasing', () {
      final result = const EmailValidator().validate(' User@Example.COM ');

      expect(result.rightOrNull(), 'user@example.com');
    });

    test('rejects malformed emails', () {
      final result = const EmailValidator().validate('invalid');

      expect(result.leftOrNull(), isA<EmailInvalidFormatIssue>());
    });

    test('rejects invalid dot placement in the local part', () {
      const validator = EmailValidator();

      expect(
        validator.validate('.user@example.com').leftOrNull(),
        isA<EmailInvalidFormatIssue>(),
      );
      expect(
        validator.validate('user.@example.com').leftOrNull(),
        isA<EmailInvalidFormatIssue>(),
      );
      expect(
        validator.validate('user..name@example.com').leftOrNull(),
        isA<EmailInvalidFormatIssue>(),
      );
    });

    test('rejects disposable domains in strict mode', () {
      final result = EmailValidator(
        EmailValidationConfig.strict(),
      ).validate('user@mailinator.com');

      expect(result.leftOrNull(), isA<EmailDisposableDomainIssue>());
    });

    test('rejects expanded default disposable domains in strict mode', () {
      final result = EmailValidator(
        EmailValidationConfig.strict(),
      ).validate('user@getnada.com');

      expect(result.leftOrNull(), isA<EmailDisposableDomainIssue>());
    });

    test('normalizes configured disposable domains before matching', () {
      final result = const EmailValidator(
        EmailValidationConfig(
          disposableDomains: {' Mailinator.COM '},
          rejectDisposable: true,
        ),
      ).validate('user@mailinator.com');

      expect(result.leftOrNull(), isA<EmailDisposableDomainIssue>());
    });

    test('rejects blocked domains', () {
      final result = const EmailValidator(
        EmailValidationConfig(blockedDomains: {'blocked.com'}),
      ).validate('user@blocked.com');

      expect(result.leftOrNull(), isA<EmailBlockedDomainIssue>());
    });

    test('normalizes configured blocked domains before matching', () {
      final result = const EmailValidator(
        EmailValidationConfig(blockedDomains: {' Blocked.COM '}),
      ).validate('user@blocked.com');

      expect(result.leftOrNull(), isA<EmailBlockedDomainIssue>());
    });

    test('rejects matching subdomains by default', () {
      final result = const EmailValidator(
        EmailValidationConfig(blockedDomains: {'blocked.com'}),
      ).validate('user@mail.blocked.com');

      expect(result.leftOrNull(), isA<EmailBlockedDomainIssue>());
    });

    test('can limit domain policies to exact matches', () {
      final result = const EmailValidator(
        EmailValidationConfig(
          blockedDomains: {'blocked.com'},
          matchSubdomains: false,
        ),
      ).validate('user@mail.blocked.com');

      expect(result.rightOrNull(), 'user@mail.blocked.com');
    });

    test('rejects values longer than the configured maximum', () {
      final result = const EmailValidator(
        EmailValidationConfig(maxLength: 10),
      ).validate('user@example.com');

      expect(result.leftOrNull(), isA<EmailTooLongIssue>());
    });

    test('exposes default issue messages through the resolver', () {
      expect(
        resolveEmailValidationIssue(const EmailEmptyIssue()),
        'Please enter an email address',
      );
    });
  });
}
