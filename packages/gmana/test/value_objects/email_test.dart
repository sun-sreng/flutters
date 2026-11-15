import 'package:gmana/gmana.dart';
import 'package:test/test.dart';

void main() {
  group('EmailValidator', () {});

  group('Email value object', () {
    test('tryParse returns a normalized Email for valid input', () {
      Email.tryParse(' Test@Example.COM ').fold(
        (l) => fail('should be right'),
        (email) {
          expect(email.value, 'test@example.com');
          expect(email.toString(), 'Email(test@example.com)');
        },
      );
    });

    test('tryParse returns the error for invalid input', () {
      Email.tryParse('invalid').fold((error) {
        expect(error, isA<EmailInvalidFormatIssue>());
        expect(error.code, 'email.invalidFormat');
      }, (r) => fail('should be left'));
    });

    test('constructor builds trusted values and throws otherwise', () {
      expect(Email('test@example.com').value, 'test@example.com');
      expect(() => Email('invalid'), throwsA(isA<ValueObjectException>()));
    });

    test('honors a custom config', () {
      Email.tryParse(
        'user@tempmail.com',
        config: EmailValidationConfig.strict(),
      ).fold(
        (error) => expect(error, isA<EmailDisposableDomainIssue>()),
        (r) => fail('should be left'),
      );
    });
  });
}
