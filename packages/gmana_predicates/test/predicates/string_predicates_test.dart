// ignore_for_file: deprecated_member_use

import 'package:gmana_predicates/gmana_predicates.dart' as predicates;
import 'package:test/test.dart';

void main() {
  group('character class predicates', () {
    test('isAlpha matches ASCII letters only', () {
      expect(predicates.isAlpha('abcXYZ'), isTrue);
      expect(predicates.isAlpha('abc123'), isFalse);
      expect(predicates.isAlpha(''), isFalse);
    });

    test('isAlphaNumeric matches ASCII letters and digits only', () {
      expect(predicates.isAlphaNumeric('abcXYZ123'), isTrue);
      expect(predicates.isAlphaNumeric('abc-123'), isFalse);
      expect(predicates.isAlphaNumeric(''), isFalse);
    });

    test('isAscii matches ASCII strings', () {
      expect(predicates.isAscii('Hello 123!'), isTrue);
      expect(predicates.isAscii('Hello\u4e2d'), isFalse);
      expect(predicates.isAscii(''), isFalse);
    });

    test('width and unicode predicates detect matching characters', () {
      expect(predicates.isFullWidth('\u4e2d'), isTrue);
      expect(predicates.isHalfWidth('abc123'), isTrue);
      expect(predicates.isMultiByte('abc\u4e2d'), isTrue);
      expect(predicates.isSurrogatePair('\uD83D\uDE00'), isTrue);
      expect(predicates.isVariableWidth('abc\u4e2d'), isTrue);
    });
  });

  group('encoded and formatted strings', () {
    test('isBase64 validates base64 input', () {
      expect(predicates.isBase64('SGVsbG8='), isTrue);
      expect(predicates.isBase64('SGVsbG8'), isFalse);
      expect(predicates.isBase64('not base64'), isFalse);
    });

    test('isEmail validates common email formats', () {
      expect(predicates.isEmail('USER.Name+tag@example.com'), isTrue);
      expect(predicates.isEmail('user@example'), isFalse);
      expect(predicates.isEmail('user@-example.com'), isFalse);
    });

    test('isHexadecimal validates hex strings', () {
      expect(predicates.isHexadecimal('00ffaa'), isTrue);
      expect(predicates.isHexadecimal('00ffxz'), isFalse);
      expect(predicates.isHexadecimal(''), isFalse);
    });

    test('isHexColor validates short and long hex colors', () {
      expect(predicates.isHexColor('#fff'), isTrue);
      expect(predicates.isHexColor('ffffff'), isTrue);
      expect(predicates.isHexColor('#ffff'), isFalse);
    });

    test('isJson validates decodable JSON values', () {
      expect(predicates.isJson('{"name":"gmana"}'), isTrue);
      expect(predicates.isJson('[1,2,3]'), isTrue);
      expect(predicates.isJson('{name:gmana}'), isFalse);
    });
  });

  group('numeric string predicates', () {
    test('isFloat validates decimal and exponent notation', () {
      expect(predicates.isFloat('1'), isTrue);
      expect(predicates.isFloat('-1.5'), isTrue);
      expect(predicates.isFloat('.5'), isTrue);
      expect(predicates.isFloat('1e3'), isTrue);
      expect(predicates.isFloat(''), isFalse);
      expect(predicates.isFloat('.'), isFalse);
      expect(predicates.isFloat('abc'), isFalse);
    });

    test('isInt validates signed integers without leading zeroes', () {
      expect(predicates.isInt('0'), isTrue);
      expect(predicates.isInt('-42'), isTrue);
      expect(predicates.isInt('042'), isFalse);
      expect(predicates.isInt('4.2'), isFalse);
    });

    test('isNumeric validates signed digit strings', () {
      expect(predicates.isNumeric('123'), isTrue);
      expect(predicates.isNumeric('-123'), isTrue);
      expect(predicates.isNumeric('12.3'), isFalse);
      expect(predicates.isNumeric(''), isFalse);
    });
  });

  group('case predicates', () {
    test('isLowerCase checks lowercase equality', () {
      expect(predicates.isLowerCase('abc'), isTrue);
      expect(predicates.isLowerCase('abc123'), isTrue);
      expect(predicates.isLowerCase('ABC'), isFalse);
    });

    test('isUpperCase checks uppercase equality', () {
      expect(predicates.isUpperCase('ABC'), isTrue);
      expect(predicates.isUpperCase('ABC123'), isTrue);
      expect(predicates.isUpperCase('abc'), isFalse);
    });
  });

  group('null and length predicates', () {
    test('isNull and isNullOrEmpty match null and empty strings', () {
      expect(predicates.isNull(null), isTrue);
      expect(predicates.isNull(''), isTrue);
      expect(predicates.isNull('value'), isFalse);
      expect(predicates.isNullOrEmpty(null), isTrue);
      expect(predicates.isNullOrEmpty(''), isTrue);
      expect(predicates.isNullOrEmpty('value'), isFalse);
    });

    test('isByteLength checks String.length bounds', () {
      expect(predicates.isByteLength('abc', 2), isTrue);
      expect(predicates.isByteLength('abc', 4), isFalse);
      expect(predicates.isByteLength('abc', 2, 3), isTrue);
      expect(predicates.isByteLength('abcd', 2, 3), isFalse);
    });

    test('isLength counts surrogate pairs as one character', () {
      expect(predicates.isLength('abc', 3, 3), isTrue);
      expect(predicates.isLength('\uD83D\uDE00', 1, 1), isTrue);
      expect(predicates.isLength('ab', 3), isFalse);
    });
  });

  group('comparison predicates', () {
    test('contains checks substring presence', () {
      expect(predicates.contains('gmana predicates', 'mana'), isTrue);
      expect(predicates.contains('gmana predicates', 'Mana'), isFalse);
    });

    test('containsIgnoreCase checks substring presence ignoring case', () {
      expect(predicates.containsIgnoreCase('gmana predicates', 'MANA'), isTrue);
      expect(
        predicates.containsIgnoreCase('gmana predicates', 'form'),
        isFalse,
      );
    });

    test('equals compares nullable string values', () {
      expect(predicates.equals('gmana', 'gmana'), isTrue);
      expect(predicates.equals(null, 'gmana'), isFalse);
      expect(predicates.equals('GMANA', 'gmana'), isFalse);
    });

    test('matches checks a regular expression pattern', () {
      expect(predicates.matches('hello123', r'^[a-z]+[0-9]+$'), isTrue);
      expect(predicates.matches('123hello', r'^[a-z]+[0-9]+$'), isFalse);
    });

    test('isSlug checks URL slug format', () {
      expect(predicates.isSlug('my-blog-post'), isTrue);
      expect(predicates.isSlug('article-123'), isTrue);
      expect(predicates.isSlug('My-Blog-Post'), isFalse);
      expect(predicates.isSlug('my_blog_post'), isFalse);
      expect(predicates.isSlug('-my-blog-'), isFalse);
    });

    test('isBlank and isNotBlank validate whitespace strings', () {
      expect(predicates.isBlank(null), isTrue);
      expect(predicates.isBlank(''), isTrue);
      expect(predicates.isBlank('   \t\n'), isTrue);
      expect(predicates.isBlank('hello'), isFalse);

      expect(predicates.isNotBlank('hello'), isTrue);
      expect(predicates.isNotBlank('   '), isFalse);
      expect(predicates.isNotBlank(null), isFalse);
    });

    test('isPalindrome checks forward and reverse equality', () {
      expect(predicates.isPalindrome('racecar'), isTrue);
      expect(predicates.isPalindrome('A man, a plan, a canal: Panama'), isTrue);
      expect(predicates.isPalindrome('hello'), isFalse);
      expect(predicates.isPalindrome(''), isFalse);
    });

    test('isCapitalized checks initial uppercase letter', () {
      expect(predicates.isCapitalized('Hello'), isTrue);
      expect(predicates.isCapitalized('hello'), isFalse);
      expect(predicates.isCapitalized('123'), isFalse);
      expect(predicates.isCapitalized(''), isFalse);
    });

    test('case format predicates check naming conventions', () {
      expect(predicates.isCamelCase('camelCaseStr'), isTrue);
      expect(predicates.isCamelCase('PascalCase'), isFalse);

      expect(predicates.isPascalCase('PascalCaseStr'), isTrue);
      expect(predicates.isPascalCase('camelCase'), isFalse);

      expect(predicates.isSnakeCase('snake_case_str'), isTrue);
      expect(predicates.isSnakeCase('snake-case'), isFalse);

      expect(predicates.isKebabCase('kebab-case-str'), isTrue);
      expect(predicates.isKebabCase('kebab_case'), isFalse);
    });

    test('isJwt, isMimeType, isHash validate specialized formats', () {
      expect(
        predicates.isJwt(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
        ),
        isTrue,
      );
      expect(predicates.isJwt('invalid.token'), isFalse);

      expect(predicates.isMimeType('application/json'), isTrue);
      expect(predicates.isMimeType('image/png'), isTrue);
      expect(predicates.isMimeType('not-a-mime'), isFalse);

      expect(
        predicates.isHash('5d41402abc4b2a76b9719d911017c592', 'md5'),
        isTrue,
      );
      expect(
        predicates.isHash('2fd4e1c67a2d28fced849ee1bb76e7391b93eb12', 'sha1'),
        isTrue,
      );
      expect(predicates.isHash('invalidhash', 'md5'), isFalse);
    });
  });
}
