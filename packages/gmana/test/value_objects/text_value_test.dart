import 'package:test/test.dart';
import 'package:gmana/gmana.dart';

void main() {
  group('TextValidator with TextValue.defaultConfig', () {
    test('validates basic text', () {
      final validator = TextValidator(TextValue.defaultConfig);
      expect(validator.validate('hello').isRight(), true);
    });

    test('trims whitespace if configured', () {
      final validator = TextValidator(
        TextValue.defaultConfig.copyWith(trimWhitespace: true),
      );
      validator
          .validate('  hello  ')
          .fold((l) => fail('should be right'), (r) => expect(r, 'hello'));

      final noTrimValidator = TextValidator(
        TextValue.defaultConfig.copyWith(trimWhitespace: false),
      );
      noTrimValidator
          .validate('  hello  ')
          .fold((l) => fail('should be right'), (r) => expect(r, '  hello  '));
    });

    test('allowEmpty and allowOnlyWhitespace', () {
      final v1 = TextValidator(
        TextValue.defaultConfig.copyWith(
          allowEmpty: false,
          allowOnlyWhitespace: false,
          trimWhitespace: false,
        ),
      );
      v1
          .validate('')
          .fold((l) => expect(l, isA<TextEmptyIssue>()), (r) => fail(''));
      v1
          .validate('   ')
          .fold(
            (l) => expect(l, isA<TextOnlyWhitespaceIssue>()),
            (r) => fail(''),
          );

      final v2 = TextValidator(
        TextValue.defaultConfig.copyWith(
          allowEmpty: true,
          allowOnlyWhitespace: true,
          trimWhitespace: false,
        ),
      );
      expect(v2.validate('').isRight(), true);
      expect(v2.validate('   ').isRight(), true);
    });

    test('validates length', () {
      final validator = TextValidator(
        TextValue.defaultConfig.copyWith(minLength: 3, maxLength: 5),
      );
      validator.validate('hi').fold((l) {
        expect(l, isA<TextTooShortIssue>());
        final error = l as TextTooShortIssue;
        expect(error.currentLength, 2);
        expect(error.minLength, 3);
      }, (r) => fail(''));
      validator.validate('hello!').fold((l) {
        expect(l, isA<TextTooLongIssue>());
        final error = l as TextTooLongIssue;
        expect(error.currentLength, 6);
        expect(error.maxLength, 5);
      }, (r) => fail(''));
      expect(validator.validate('hey').isRight(), true);
    });

    test('validates pattern', () {
      final validator = TextValidator(
        TextValue.defaultConfig.copyWith(pattern: RegExp(r'^[0-9]+$')),
      );
      expect(validator.validate('12345').isRight(), true);
      validator.validate('123a').fold((l) {
        expect(l, isA<TextInvalidPatternIssue>());
      }, (r) => fail(''));
    });

    test('validates allowedCharacters', () {
      final validator = TextValidator(
        TextValue.defaultConfig.copyWith(allowedCharacters: 'abc'),
      );
      expect(validator.validate('abcba').isRight(), true);
      validator.validate('abcd').fold((l) {
        expect(l, isA<TextInvalidCharactersIssue>());
        expect((l as TextInvalidCharactersIssue).invalidCharacters, 'd');
      }, (r) => fail(''));
    });

    test('validates blacklistedWords', () {
      final validator = TextValidator(
        TextValue.defaultConfig.copyWith(blacklistedWords: {'bad', 'ugly'}),
      );
      validator.validate('this is a bAd word').fold((l) {
        expect(l, isA<TextContainsBlacklistedIssue>());
        expect((l as TextContainsBlacklistedIssue).foundWords, ['bad']);
      }, (r) => fail(''));
      expect(validator.validate('good words only').isRight(), true);
    });

    test('validates factories', () {
      expect(
        TextValidator(
          TextValidationConfig.username(),
        ).validate('user_123').isRight(),
        true,
      );
      TextValidator(TextValidationConfig.username())
          .validate('user@123')
          .fold(
            (l) => expect(l, isA<TextInvalidPatternIssue>()),
            (r) => fail(''),
          );
      expect(
        TextValidator(
          TextValidationConfig.name(),
        ).validate('John Doe').isRight(),
        true,
      );
      expect(
        TextValidator(
          TextValidationConfig.alphanumeric(),
        ).validate('abc123').isRight(),
        true,
      );
      expect(
        TextValidator(
          TextValidationConfig.shortText(),
        ).validate('Short title').isRight(),
        true,
      );
      expect(
        TextValidator(
          TextValidationConfig.mediumText(),
        ).validate('A medium description').isRight(),
        true,
      );
      expect(
        TextValidator(
          TextValidationConfig.longText(),
        ).validate('A long body of text').isRight(),
        true,
      );
    });
  });

  group('TextValue value object', () {
    test('tryParse returns the trimmed value for valid input', () {
      TextValue.tryParse('  hello  ').fold((l) => fail('should be right'), (
        text,
      ) {
        expect(text.value, 'hello');
        expect(text.toString(), 'TextValue(hello)');
      });
    });

    test('tryParse returns the error for invalid input', () {
      TextValue.tryParse('', config: TextValue.defaultConfig).fold(
        (error) => expect(error, isA<TextEmptyIssue>()),
        (r) => fail('should be left'),
      );
    });

    test('constructor builds trusted values and throws otherwise', () {
      expect(TextValue('hello').value, 'hello');
      expect(
        () => TextValue('', config: TextValue.defaultConfig),
        throwsA(isA<ValueObjectException>()),
      );
    });
  });

  group('TextValue.defaultConfig blacklist matching', () {
    test('matches inside longer words by default', () {
      final config = TextValue.defaultConfig.copyWith(
        blacklistedWords: {'bad'},
      );

      expect(
        TextValidator(config).validate('badminton').leftOrNull(),
        isA<TextContainsBlacklistedIssue>(),
      );
    });

    test('wholeWordBlacklist limits matches to whole words', () {
      final config = TextValue.defaultConfig.copyWith(
        blacklistedWords: {'bad'},
        wholeWordBlacklist: true,
      );

      expect(TextValidator(config).validate('badminton').isRight(), isTrue);
      expect(
        TextValidator(config).validate('a bad idea').leftOrNull(),
        isA<TextContainsBlacklistedIssue>(),
      );
    });
  });
}
