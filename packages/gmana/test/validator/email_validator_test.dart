import 'package:gmana/validator/email_field_validator.dart';
import 'package:test/test.dart';

void main() {
  group('EmailFieldValidator', () {
    test('rejects empty values', () {
      expect(
        const EmailFieldValidator().validate(null),
        'Please enter an email address',
      );
      expect(
        const EmailFieldValidator().validate(''),
        'Please enter an email address',
      );
    });

    test('rejects malformed emails', () {
      expect(
        const EmailFieldValidator().validate('invalid'),
        'Please enter a valid email address',
      );
    });

    test('accepts valid emails', () {
      expect(const EmailFieldValidator().validate('user@example.com'), isNull);
    });
  });
}
