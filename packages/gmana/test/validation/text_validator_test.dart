import 'package:gmana/validation.dart';
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

    group('allowedCharacters is a literal set', () {
      test('a hyphen is an allowed character, not a range', () {
        final validator = TextValidator(
          const TextValidationConfig(allowedCharacters: 'a_-.'),
        );

        expect(validator.validate('a-_.a').isRight(), isTrue);
        expect(
          (validator.validate('a,b').leftOrNull()
                  as TextInvalidCharactersIssue?)
              ?.invalidCharacters,
          ',b',
        );
      });

      test('characters between two allowed ones are not allowed', () {
        // As a regex class, '+-.' is the range '+' to '.', which includes ','.
        final validator = TextValidator(
          const TextValidationConfig(allowedCharacters: '+-.0123456789'),
        );

        expect(validator.validate('-1.5').isRight(), isTrue);
        expect(
          validator.validate('1,5').leftOrNull(),
          isA<TextInvalidCharactersIssue>(),
        );
      });

      test('a-z lists three characters', () {
        final validator = TextValidator(
          const TextValidationConfig(allowedCharacters: 'a-z'),
        );

        expect(validator.validate('a-z').isRight(), isTrue);
        expect(validator.validate('m').isLeft(), isTrue);
      });

      test('an emoji counts as one character', () {
        final validator = TextValidator(
          const TextValidationConfig(allowedCharacters: 'ab😀'),
        );

        expect(validator.validate('a😀b').isRight(), isTrue);
        expect(
          (validator.validate('a😎').leftOrNull()
                  as TextInvalidCharactersIssue?)
              ?.invalidCharacters,
          '😎',
        );
      });
    });

    group('whole-word blacklist', () {
      final validator = TextValidator(
        const TextValidationConfig(blacklistedWords: {'ass'}),
      );

      test('finds a whole word after a partial match', () {
        expect(
          validator.validate('class ass').leftOrNull(),
          isA<TextContainsBlacklistedIssue>(),
        );
        expect(
          validator.validate('class, ass.').leftOrNull(),
          isA<TextContainsBlacklistedIssue>(),
        );
      });

      test('still ignores the word inside other words', () {
        expect(validator.validate('class assess bass').isRight(), isTrue);
      });
    });
  });
}
