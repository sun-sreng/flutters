import 'package:test/test.dart';
import 'package:gmana/gmana.dart';

void main() {
  group('PasswordValidator with PasswordValidationConfig.balanced', () {
    test('returns PasswordEmptyIssue for empty string', () {
      const validator = PasswordValidator(PasswordValidationConfig.balanced);
      validator
          .validate('')
          .fold((l) => expect(l, isA<PasswordEmptyIssue>()), (r) => fail(''));
    });

    test('validates strong password', () {
      const validator = PasswordValidator(PasswordValidationConfig.balanced);
      expect(validator.validate('StrongP@ssw0rd!').isRight(), true);
    });

    test('validates lenient factory', () {
      final validator = PasswordValidator(
        PasswordValidationConfig.balanced.copyWith(
          minLength: 4,
          minCharacterClasses: 1,
        ),
      );
      // lenient needs min length 4, complexity 1
      expect(
        validator.validate('pass').isRight(),
        true,
      ); // Complexity 1: all lower
    });

    test('validates strict factory', () {
      final validator = PasswordValidator(
        PasswordValidationConfig.balanced.copyWith(
          minLength: 12,
          minCharacterClasses: 4,
        ),
      );
      // strict needs min length 12, complexity 4
      expect(
        validator.validate('Str0ngP@sswo').isRight(),
        true,
      ); // 12 chars, all 4 classes
      validator
          .validate('Str0ngPasswo')
          .fold(
            (l) => expect(l, isA<PasswordTooFewCharacterClassesIssue>()),
            (r) => fail(''),
          ); // only 3 classes
    });

    test('detects too short / too long', () {
      final validator = PasswordValidator(
        PasswordValidationConfig.balanced.copyWith(minLength: 5, maxLength: 8),
      );
      validator.validate('12ab').fold((l) {
        expect(l, isA<PasswordTooShortIssue>());
        final error = l as PasswordTooShortIssue;
        expect(error.currentLength, 4);
        expect(error.minLength, 5);
      }, (r) => fail(''));
      validator.validate('1234abcd!').fold((l) {
        expect(l, isA<PasswordTooLongIssue>());
        final error = l as PasswordTooLongIssue;
        expect(error.currentLength, 9);
        expect(error.maxLength, 8);
      }, (r) => fail(''));
    });

    test('detects non-ascii', () {
      const validator = PasswordValidator(PasswordValidationConfig.balanced);
      validator
          .validate('P@ssword😎')
          .fold(
            (l) => expect(l, isA<PasswordDisallowedCharacterIssue>()),
            (r) => fail(''),
          );
    });

    test('detects common passwords and prefixes', () {
      const validator = PasswordValidator(PasswordValidationConfig.balanced);
      validator
          .validate('password123')
          .fold(
            (l) => expect(l, isA<PasswordTooCommonIssue>()),
            (r) => fail(''),
          );
      // A common prefix followed by a few characters
      validator
          .validate('qwerty12')
          .fold(
            (l) => expect(l, isA<PasswordTooCommonIssue>()),
            (r) => fail(''),
          );
    });

    test('detects completely identical characters', () {
      const validator = PasswordValidator(PasswordValidationConfig.balanced);
      validator
          .validate('aaaaaaaaa')
          .fold(
            (l) => expect(l, isA<PasswordRepeatedCharacterIssue>()),
            (r) => fail(''),
          );
    });

    test('detects sequential runs', () {
      const validator = PasswordValidator(PasswordValidationConfig.balanced);
      // Length 15, maxAllowedRun = floor(15 * 0.5) = 7, clamped to min 3 => 7.
      // So seq run of 7 should be rejected. 1234567
      validator
          .validate('abcd1234567!@#')
          .fold(
            (l) => expect(l, isA<PasswordSequentialPatternIssue>()),
            (r) => fail(''),
          );
    });

    test('returns complexity score details', () {
      final validator = PasswordValidator(
        PasswordValidationConfig.balanced.copyWith(minCharacterClasses: 4),
      );

      validator.validate('lowercase1').fold((l) {
        expect(l, isA<PasswordTooFewCharacterClassesIssue>());
        final error = l as PasswordTooFewCharacterClassesIssue;
        expect(error.currentClasses, 2);
        expect(error.requiredClasses, 4);
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
        (error) => expect(error, isA<PasswordTooShortIssue>()),
        (r) => fail('should be left'),
      );
    });

    test('constructor builds trusted values and throws otherwise', () {
      expect(Password('StrongP@ssw0rd!').value, 'StrongP@ssw0rd!');
      expect(() => Password('short'), throwsA(isA<ValueObjectException>()));
    });
  });
}
