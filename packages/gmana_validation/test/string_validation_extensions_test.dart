import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('GmanaValidationStringX defaults', () {
    test('validateDate returns a parsed UTC DateTime', () {
      final ValidationResult<DateValidationIssue, DateTime?> result =
          '2026-08-07T12:30:00Z'.validateDate();

      expect(result.rightOrNull(), DateTime.utc(2026, 8, 7, 12, 30));
    });

    test('validateEmail returns the normalized address', () {
      final ValidationResult<EmailValidationIssue, String> result =
          ' User@Example.COM '.validateEmail();

      expect(result.rightOrNull(), 'user@example.com');
    });

    test('validateIdentifier trims and returns the identifier', () {
      final ValidationResult<IdentifierValidationIssue, String> result =
          ' customer-42 '.validateIdentifier();

      expect(result.rightOrNull(), 'customer-42');
    });

    test('validateNetwork trims and returns the network value', () {
      final ValidationResult<NetworkValidationIssue, String> result =
          ' 192.168.1.1 '.validateNetwork();

      expect(result.rightOrNull(), '192.168.1.1');
    });

    test('validateNumber returns the parsed number', () {
      final ValidationResult<NumberValidationIssue, num> result =
          ' 12.5 '.validateNumber();

      expect(result.rightOrNull(), 12.5);
    });

    test('validatePassword returns the original password', () {
      final ValidationResult<PasswordValidationIssue, String> result =
          'StrongP@ssw0rd'.validatePassword();

      expect(result.rightOrNull(), 'StrongP@ssw0rd');
    });

    test('validatePhone returns the normalized phone number', () {
      final ValidationResult<PhoneValidationIssue, String> result =
          '+1 (415) 555-2671'.validatePhone();

      expect(result.rightOrNull(), '+14155552671');
    });

    test('validateText preserves text with the default config', () {
      final ValidationResult<TextValidationIssue, String> result =
          '  hello  '.validateText();

      expect(result.rightOrNull(), '  hello  ');
    });

    test('validateUrl returns a parsed Uri', () {
      final ValidationResult<UrlValidationIssue, Uri> result =
          ' https://example.com/path '.validateUrl();

      expect(result.rightOrNull(), Uri.parse('https://example.com/path'));
    });

    test('is exported as a named extension', () {
      final result = GmanaValidationStringX('user@example.com').validateEmail();

      expect(result.isRight(), isTrue);
    });
  });

  group('GmanaValidationStringX config forwarding', () {
    test('validateDate forwards time-only validation', () {
      final ValidationResult<DateValidationIssue, DateTime?> result = '14:30'
          .validateDate(const DateValidationConfig(mustBeTime: true));

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull(), isNull);
    });

    test('validateEmail forwards domain policy', () {
      final result = 'user@example.com'.validateEmail(
        const EmailValidationConfig(blockedDomains: {'example.com'}),
      );

      final issue = result.leftOrNull();
      expect(issue, isA<EmailBlockedDomainIssue>());
      expect((issue as EmailBlockedDomainIssue).domain, 'example.com');
    });

    test('validateIdentifier forwards the required type and UUID version', () {
      final result = 'not-a-uuid'.validateIdentifier(
        const IdentifierValidationConfig(
          requiredType: IdentifierType.uuid,
          uuidVersion: '4',
        ),
      );

      final issue = result.leftOrNull();
      expect(issue, isA<IdentifierInvalidUuidIssue>());
      expect((issue as IdentifierInvalidUuidIssue).version, '4');
    });

    test('validateNetwork forwards the required network type', () {
      final result = '70000'.validateNetwork(
        const NetworkValidationConfig(requiredType: NetworkAddressType.port),
      );

      expect(result.leftOrNull(), isA<NetworkInvalidPortIssue>());
    });

    test('validateNumber forwards numeric constraints', () {
      final result = '-1'.validateNumber(
        NumberValidationConfig.positiveInteger(),
      );

      expect(result.leftOrNull(), isA<NumberNegativeNotAllowedIssue>());
    });

    test('validatePassword forwards a lenient password policy', () {
      final result = 'abcd'.validatePassword(
        PasswordValidationConfig.lenient(),
      );

      expect(result.rightOrNull(), 'abcd');
    });

    test('validatePhone forwards E.164 requirements', () {
      final result = '14155552671'.validatePhone(PhoneValidationConfig.e164());

      expect(result.leftOrNull(), isA<PhoneMissingPlusIssue>());
    });

    test('validateText forwards normalization and length rules', () {
      final result = '  abc  '.validateText(
        TextValidationConfig.required(
          minLength: 3,
          maxLength: 3,
          trimWhitespace: true,
        ),
      );

      expect(result.rightOrNull(), 'abc');
    });

    test('validateUrl forwards allowed schemes', () {
      final result = 'http://example.com'.validateUrl(
        const UrlValidationConfig(allowedSchemes: {'https'}),
      );

      final issue = result.leftOrNull();
      expect(issue, isA<UrlDisallowedSchemeIssue>());
      expect((issue as UrlDisallowedSchemeIssue).scheme, 'http');
    });
  });
}
