import 'package:test/test.dart';
import 'package:value_objects/value_objects.dart';

void main() {
  group('PasswordValidator', () {
    test('validates strong password', () {
      const validator = PasswordValidator();
      expect(validator.validate('StrongP@ssw0rd!').isRight(), true);
    });

    test('validates lenient factory', () {
      final validator = PasswordValidator(PasswordValidationConfig.lenient());
      // lenient needs min length 4, complexity 1
      expect(validator.validate('pass').isRight(), true); // Complexity 1: all lower
    });

    test('validates strict factory', () {
      final validator = PasswordValidator(PasswordValidationConfig.strict());
      // strict needs min length 12, complexity 4
      expect(validator.validate('Str0ngP@sswo').isRight(), true); // 12 chars, all 4 classes
      validator.validate('Str0ngPasswo').match((l) => expect(l, isA<PasswordComplexityRequired>()), (r) => fail('')); // only 3 classes
    });

    test('detects too short / too long', () {
      const validator = PasswordValidator(PasswordValidationConfig(minLength: 5, maxLength: 8));
      validator.validate('12ab').match((l) => expect(l, isA<PasswordTooShort>()), (r) => fail(''));
      validator.validate('1234abcd!').match((l) => expect(l, isA<PasswordTooLong>()), (r) => fail(''));
    });

    test('detects non-ascii', () {
      const validator = PasswordValidator();
      validator.validate('P@ssword😎').match((l) => expect(l, isA<PasswordNonAscii>()), (r) => fail(''));
    });

    test('detects common passwords and prefixes', () {
      const validator = PasswordValidator();
      validator.validate('password123').match((l) => expect(l, isA<PasswordTooCommon>()), (r) => fail(''));
      // A common prefix followed by a few characters
      validator.validate('qwerty12').match((l) => expect(l, isA<PasswordTooCommon>()), (r) => fail(''));
    });

    test('detects completely identical characters', () {
      const validator = PasswordValidator();
      validator.validate('aaaaaaaaa').match((l) => expect(l, isA<PasswordTooWeak>()), (r) => fail(''));
    });

    test('detects sequential runs', () {
      const validator = PasswordValidator();
      // Length 15, maxAllowedRun = floor(15 * 0.5) = 7, clamped to min 3 => 7.
      // So seq run of 7 should be rejected. 1234567
      validator.validate('abcd1234567!@#').match((l) => expect(l, isA<PasswordTooPredictable>()), (r) => fail(''));
    });
  });

  group('Password Value Object', () {
    test('creates valid Password', () {
      final pass = Password('StrongP@ssw0rd!');
      expect(pass.isValid, true);
      expect(pass.isSensitive, true);
      expect(pass.toString(), 'Password(valid)');
    });

    test('creates invalid Password', () {
      final pass = Password('short');
      expect(pass.isInvalid, true);
      expect(pass.toString(), 'Password(invalid)');
    });
  });
}
