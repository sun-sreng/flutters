import 'package:test/test.dart';
import 'package:value_objects/value_objects.dart';

void main() {
  group('TextValidator', () {
    test('validates basic text', () {
      const validator = TextValidator();
      expect(validator.validate('hello').isRight(), true);
    });

    test('trims whitespace if configured', () {
      const validator = TextValidator(TextValidationConfig(trimWhitespace: true));
      validator.validate('  hello  ').match(
        (l) => fail('should be right'),
        (r) => expect(r, 'hello'),
      );
      
      const noTrimValidator = TextValidator(TextValidationConfig(trimWhitespace: false));
      noTrimValidator.validate('  hello  ').match(
        (l) => fail('should be right'),
        (r) => expect(r, '  hello  '),
      );
    });

    test('allowEmpty and allowOnlyWhitespace', () {
      const v1 = TextValidator(TextValidationConfig(allowEmpty: false, allowOnlyWhitespace: false, trimWhitespace: false));
      v1.validate('').match((l) => expect(l, isA<TextEmpty>()), (r) => fail(''));
      v1.validate('   ').match((l) => expect(l, isA<TextOnlyWhitespace>()), (r) => fail(''));

      const v2 = TextValidator(TextValidationConfig(allowEmpty: true, allowOnlyWhitespace: true, trimWhitespace: false));
      expect(v2.validate('').isRight(), true);
      expect(v2.validate('   ').isRight(), true);
    });

    test('validates length', () {
      const validator = TextValidator(TextValidationConfig(minLength: 3, maxLength: 5));
      validator.validate('hi').match((l) => expect(l, isA<TextTooShort>()), (r) => fail(''));
      validator.validate('hello!').match((l) => expect(l, isA<TextTooLong>()), (r) => fail(''));
      expect(validator.validate('hey').isRight(), true);
    });

    test('validates pattern', () {
      const validator = TextValidator(TextValidationConfig(pattern: r'^[0-9]+$'));
      expect(validator.validate('12345').isRight(), true);
      validator.validate('123a').match((l) => expect(l, isA<TextInvalidPattern>()), (r) => fail(''));
    });

    test('validates allowedCharacters', () {
      const validator = TextValidator(TextValidationConfig(allowedCharacters: 'abc'));
      expect(validator.validate('abcba').isRight(), true);
      validator.validate('abcd').match((l) {
        expect(l, isA<TextInvalidCharacters>());
        expect((l as TextInvalidCharacters).invalidChars, 'd');
      }, (r) => fail(''));
    });

    test('validates blacklistedWords', () {
      const validator = TextValidator(TextValidationConfig(blacklistedWords: {'bad', 'ugly'}));
      validator.validate('this is a bAd word').match((l) => expect(l, isA<TextContainsBlacklisted>()), (r) => fail(''));
      expect(validator.validate('good words only').isRight(), true);
    });
    
    test('validates factories', () {
      expect(TextValidator(TextValidationConfig.username()).validate('user_123').isRight(), true);
      TextValidator(TextValidationConfig.username()).validate('user@123').match((l) => expect(l, isA<TextInvalidPattern>()), (r) => fail(''));
      expect(TextValidator(TextValidationConfig.name()).validate('John Doe').isRight(), true);
      expect(TextValidator(TextValidationConfig.alphanumeric()).validate('abc123').isRight(), true);
    });
  });

  group('TextValue', () {
    test('creates valid TextValue', () {
      final text = TextValue('hello');
      expect(text.isValid, true);
      expect(text.valueOrNull, 'hello');
      expect(text.toString(), 'TextValue(hello)');
    });

    test('creates invalid TextValue', () {
      final text = TextValue('', config: const TextValidationConfig(allowEmpty: false));
      expect(text.isInvalid, true);
      expect(text.errorOrNull, isA<TextEmpty>());
      expect(text.toString(), 'TextValue(invalid)');
    });
  });
}
