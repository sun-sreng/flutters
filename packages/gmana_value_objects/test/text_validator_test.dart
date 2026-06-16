import 'package:test/test.dart';
import 'package:gmana_value_objects/gmana_value_objects.dart';

void main() {
  group('TextValidator', () {
    test('validates basic text', () {
      const validator = TextValidator();
      expect(validator.validate('hello').isRight(), true);
    });

    test('trims whitespace if configured', () {
      const validator = TextValidator(
        TextValidationConfig(trimWhitespace: true),
      );
      validator
          .validate('  hello  ')
          .fold((l) => fail('should be right'), (r) => expect(r, 'hello'));

      const noTrimValidator = TextValidator(
        TextValidationConfig(trimWhitespace: false),
      );
      noTrimValidator
          .validate('  hello  ')
          .fold((l) => fail('should be right'), (r) => expect(r, '  hello  '));
    });

    test('allowEmpty and allowOnlyWhitespace', () {
      const v1 = TextValidator(
        TextValidationConfig(
          allowEmpty: false,
          allowOnlyWhitespace: false,
          trimWhitespace: false,
        ),
      );
      v1.validate('').fold((l) => expect(l, isA<TextEmpty>()), (r) => fail(''));
      v1
          .validate('   ')
          .fold((l) => expect(l, isA<TextOnlyWhitespace>()), (r) => fail(''));

      const v2 = TextValidator(
        TextValidationConfig(
          allowEmpty: true,
          allowOnlyWhitespace: true,
          trimWhitespace: false,
        ),
      );
      expect(v2.validate('').isRight(), true);
      expect(v2.validate('   ').isRight(), true);
    });

    test('validates length', () {
      const validator = TextValidator(
        TextValidationConfig(minLength: 3, maxLength: 5),
      );
      validator.validate('hi').fold((l) {
        expect(l, isA<TextTooShort>());
        final error = l as TextTooShort;
        expect(error.currentLength, 2);
        expect(error.minLength, 3);
      }, (r) => fail(''));
      validator.validate('hello!').fold((l) {
        expect(l, isA<TextTooLong>());
        final error = l as TextTooLong;
        expect(error.currentLength, 6);
        expect(error.maxLength, 5);
      }, (r) => fail(''));
      expect(validator.validate('hey').isRight(), true);
    });

    test('validates pattern', () {
      const validator = TextValidator(
        TextValidationConfig(pattern: r'^[0-9]+$'),
      );
      expect(validator.validate('12345').isRight(), true);
      validator.validate('123a').fold((l) {
        expect(l, isA<TextInvalidPattern>());
        expect((l as TextInvalidPattern).pattern, r'^[0-9]+$');
      }, (r) => fail(''));
    });

    test('validates allowedCharacters', () {
      const validator = TextValidator(
        TextValidationConfig(allowedCharacters: 'abc'),
      );
      expect(validator.validate('abcba').isRight(), true);
      validator.validate('abcd').fold((l) {
        expect(l, isA<TextInvalidCharacters>());
        expect((l as TextInvalidCharacters).invalidChars, 'd');
      }, (r) => fail(''));
    });

    test('validates blacklistedWords', () {
      const validator = TextValidator(
        TextValidationConfig(blacklistedWords: {'bad', 'ugly'}),
      );
      validator.validate('this is a bAd word').fold((l) {
        expect(l, isA<TextContainsBlacklisted>());
        expect((l as TextContainsBlacklisted).foundWords, ['bad']);
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
          .fold((l) => expect(l, isA<TextInvalidPattern>()), (r) => fail(''));
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
      TextValue.tryParse('  hello  ').fold(
        (l) => fail('should be right'),
        (text) {
          expect(text.value, 'hello');
          expect(text.toString(), 'TextValue(hello)');
        },
      );
    });

    test('tryParse returns the error for invalid input', () {
      TextValue.tryParse(
        '',
        config: const TextValidationConfig(allowEmpty: false),
      ).fold(
        (error) => expect(error, isA<TextEmpty>()),
        (r) => fail('should be left'),
      );
    });

    test('constructor builds trusted values and throws otherwise', () {
      expect(TextValue('hello').value, 'hello');
      expect(
        () => TextValue('', config: const TextValidationConfig()),
        throwsA(isA<ValueObjectException>()),
      );
    });
  });
}
