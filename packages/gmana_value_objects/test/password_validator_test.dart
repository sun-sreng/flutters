import 'package:test/test.dart';
import 'package:gmana_value_objects/gmana_value_objects.dart';

void main() {
  group('PasswordValidator', () {
    test('returns PasswordEmpty for empty string', () {
      const validator = PasswordValidator();
      validator
          .validate('')
          .fold((l) => expect(l, isA<PasswordEmpty>()), (r) => fail(''));
    });

    test('validates strong password', () {
      const validator = PasswordValidator();
      expect(validator.validate('StrongP@ssw0rd!').isRight(), true);
    });

    test('validates lenient factory', () {
      final validator = PasswordValidator(PasswordValidationConfig.lenient());
      // lenient needs min length 4, complexity 1
      expect(
        validator.validate('pass').isRight(),
        true,
      ); // Complexity 1: all lower
    });

    test('validates strict factory', () {
      final validator = PasswordValidator(PasswordValidationConfig.strict());
      // strict needs min length 12, complexity 4
      expect(
        validator.validate('Str0ngP@sswo').isRight(),
        true,
      ); // 12 chars, all 4 classes
      validator
          .validate('Str0ngPasswo')
          .fold(
            (l) => expect(l, isA<PasswordComplexityRequired>()),
            (r) => fail(''),
          ); // only 3 classes
    });

    test('detects too short / too long', () {
      const validator = PasswordValidator(
        PasswordValidationConfig(minLength: 5, maxLength: 8),
      );
      validator.validate('12ab').fold((l) {
        expect(l, isA<PasswordTooShort>());
        final error = l as PasswordTooShort;
        expect(error.currentLength, 4);
        expect(error.minLength, 5);
      }, (r) => fail(''));
      validator.validate('1234abcd!').fold((l) {
        expect(l, isA<PasswordTooLong>());
        final error = l as PasswordTooLong;
        expect(error.currentLength, 9);
        expect(error.maxLength, 8);
      }, (r) => fail(''));
    });

    test('detects non-ascii', () {
      const validator = PasswordValidator();
      validator
          .validate('P@ssword😎')
          .fold((l) => expect(l, isA<PasswordNonAscii>()), (r) => fail(''));
    });

    test('detects common passwords and prefixes', () {
      const validator = PasswordValidator();
      validator
          .validate('password123')
          .fold((l) => expect(l, isA<PasswordTooCommon>()), (r) => fail(''));
      // A common prefix followed by a few characters
      validator
          .validate('qwerty12')
          .fold((l) => expect(l, isA<PasswordTooCommon>()), (r) => fail(''));
    });

    test('detects completely identical characters', () {
      const validator = PasswordValidator();
      validator
          .validate('aaaaaaaaa')
          .fold((l) => expect(l, isA<PasswordTooWeak>()), (r) => fail(''));
    });

    test('detects sequential runs', () {
      const validator = PasswordValidator();
      // Length 15, maxAllowedRun = floor(15 * 0.5) = 7, clamped to min 3 => 7.
      // So seq run of 7 should be rejected. 1234567
      validator
          .validate('abcd1234567!@#')
          .fold(
            (l) => expect(l, isA<PasswordTooPredictable>()),
            (r) => fail(''),
          );
    });

    test('returns complexity score details', () {
      const validator = PasswordValidator(
        PasswordValidationConfig(minComplexityScore: 4),
      );

      validator.validate('lowercase1').fold((l) {
        expect(l, isA<PasswordComplexityRequired>());
        final error = l as PasswordComplexityRequired;
        expect(error.currentScore, 2);
        expect(error.requiredScore, 4);
      }, (r) => fail(''));
    });
  });

  group('Password value object', () {
    test('tryParse returns a sensitive, masked Password for valid input', () {
      Password.tryParse('StrongP@ssw0rd!').fold(
        (l) => fail('should be right'),
        (pass) {
          expect(pass.value, 'StrongP@ssw0rd!');
          expect(pass.isSensitive, true);
          expect(pass.toString(), 'Password(***)');
        },
      );
    });

    test('tryParse returns the error for invalid input', () {
      Password.tryParse('short').fold(
        (error) => expect(error, isA<PasswordTooShort>()),
        (r) => fail('should be left'),
      );
    });

    test('constructor builds trusted values and throws otherwise', () {
      expect(Password('StrongP@ssw0rd!').value, 'StrongP@ssw0rd!');
      expect(() => Password('short'), throwsA(isA<ValueObjectException>()));
    });
  });
}
