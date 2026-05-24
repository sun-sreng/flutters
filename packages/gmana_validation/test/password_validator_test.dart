import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('PasswordValidator', () {
    test('rejects empty values', () {
      final result = const PasswordValidator().validate('');

      expect(result.leftOrNull(), isA<PasswordEmptyIssue>());
    });

    test('uses the strong preset by default', () {
      const validator = PasswordValidator();

      expect(validator.validate('weak').leftOrNull(), isA<PasswordTooShortIssue>());
      expect(validator.validate('alllowercase1!').leftOrNull(), isA<PasswordMissingUppercaseIssue>());
      expect(validator.validate('StrongP@ssw0rd').rightOrNull(), 'StrongP@ssw0rd');
    });

    test('rejects common passwords', () {
      final result = const PasswordValidator().validate('Password123!');

      expect(result.leftOrNull(), isA<PasswordTooCommonIssue>());
    });

    test('rejects repeated-character passwords', () {
      final result = const PasswordValidator(
        PasswordValidationConfig(
          requireUppercase: false,
          requireLowercase: false,
          requireDigit: false,
          requireSpecialCharacter: false,
        ),
      ).validate('aaaaaaaa');

      expect(result.leftOrNull(), isA<PasswordRepeatedCharacterIssue>());
    });

    test('rejects sequential passwords', () {
      final result = const PasswordValidator(
        PasswordValidationConfig(
          requireUppercase: false,
          requireLowercase: false,
          requireDigit: false,
          requireSpecialCharacter: false,
        ),
      ).validate('abcd1234');

      expect(result.leftOrNull(), isA<PasswordSequentialPatternIssue>());
    });

    test('supports lenient configs', () {
      final result = PasswordValidator(PasswordValidationConfig.lenient()).validate('abcd');

      expect(result.rightOrNull(), 'abcd');
    });
  });
}
