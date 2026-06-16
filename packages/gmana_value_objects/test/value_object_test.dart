import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('ValueObject equality', () {
    test('same type and value are equal and share a hash code', () {
      expect(Email('a@b.com'), Email('a@b.com'));
      expect(Email('a@b.com').hashCode, Email('a@b.com').hashCode);
      expect({Email('a@b.com'), Email('a@b.com')}, hasLength(1));
    });

    test('same type with different values are not equal', () {
      expect(Email('a@b.com'), isNot(Email('c@d.com')));
    });

    test('different types with the same value are not equal', () {
      expect(Email('a@b.com'), isNot(equals(TextValue('a@b.com'))));
    });
  });

  group('ValueObject toString', () {
    test('non-sensitive values are shown', () {
      expect(Email('a@b.com').toString(), 'Email(a@b.com)');
      expect(TextValue('hello').toString(), 'TextValue(hello)');
      expect(NumberValue('42').toString(), 'NumberValue(42)');
    });

    test('sensitive values are masked', () {
      final password = Password('StrongP@ssw0rd!');
      expect(password.isSensitive, true);
      expect(password.toString(), 'Password(***)');
      expect(password.toString(), isNot(contains('StrongP@ssw0rd!')));
    });
  });

  group('ValueObjectException', () {
    test('wraps the validation error and exposes its code', () {
      try {
        Email('invalid');
        fail('should have thrown');
      } on ValueObjectException catch (e) {
        expect(e.error, isA<EmailInvalidFormat>());
        expect(e.toString(), 'ValueObjectException(email_invalid_format)');
      }
    });
  });
}
