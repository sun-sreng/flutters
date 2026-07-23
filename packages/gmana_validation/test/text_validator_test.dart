import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('TextValidator', () {
    test('allows empty values by default', () {
      final result = TextValidator().validate('');

      expect(result.rightOrNull(), '');
    });

    test('rejects empty values for required config', () {
      final result = TextValidator(
        TextValidationConfig.required(),
      ).validate('');

      expect(result.leftOrNull(), isA<TextEmptyIssue>());
    });

    test('rejects whitespace-only values when configured', () {
      final result = TextValidator(
        const TextValidationConfig(
          allowEmpty: false,
          allowOnlyWhitespace: false,
        ),
      ).validate('   ');

      expect(result.leftOrNull(), isA<TextOnlyWhitespaceIssue>());
    });

    test('applies trim, min, and max length rules', () {
      final validator = TextValidator(
        TextValidationConfig.required(
          trimWhitespace: true,
          minLength: 3,
          maxLength: 5,
        ),
      );

      expect(
        validator.validate('  ab ').leftOrNull(),
        isA<TextTooShortIssue>(),
      );
      expect(
        validator.validate('  abcdef ').leftOrNull(),
        isA<TextTooLongIssue>(),
      );
      expect(validator.validate('  abcd ').rightOrNull(), 'abcd');
    });

    test('applies pattern, allowed-characters, and blacklist rules', () {
      final patternResult = TextValidator(
        TextValidationConfig(pattern: RegExp(r'^[A-Z]+$')),
      ).validate('abc');
      final allowedCharactersResult = TextValidator(
        const TextValidationConfig(allowedCharacters: 'abc123'),
      ).validate('abc!');
      final blacklistResult = TextValidator(
        const TextValidationConfig(blacklistedWords: {'admin'}),
      ).validate('site-admin');

      expect(patternResult.leftOrNull(), isA<TextInvalidPatternIssue>());
      expect(
        allowedCharactersResult.leftOrNull(),
        isA<TextInvalidCharactersIssue>(),
      );
      expect(blacklistResult.leftOrNull(), isA<TextContainsBlacklistedIssue>());
    });
  });
}
