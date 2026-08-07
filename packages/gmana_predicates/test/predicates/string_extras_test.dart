import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

void main() {
  group('isScreamingSnakeCase', () {
    test('accepts uppercase words joined by underscores', () {
      expect(isScreamingSnakeCase('FOO'), isTrue);
      expect(isScreamingSnakeCase('FOO_BAR'), isTrue);
      expect(isScreamingSnakeCase('HTTP_2_PROXY'), isTrue);
    });

    test('rejects lowercase, leading or doubled underscores', () {
      expect(isScreamingSnakeCase('foo_bar'), isFalse);
      expect(isScreamingSnakeCase('FOO_bar'), isFalse);
      expect(isScreamingSnakeCase('_FOO'), isFalse);
      expect(isScreamingSnakeCase('FOO__BAR'), isFalse);
      expect(isScreamingSnakeCase(''), isFalse);
    });
  });

  group('isTitleCase', () {
    test('accepts capitalized words separated by single spaces', () {
      expect(isTitleCase('Foo'), isTrue);
      expect(isTitleCase('Foo Bar Baz'), isTrue);
      expect(isTitleCase('Chapter 2'), isFalse);
    });

    test('rejects all-caps words and irregular spacing', () {
      expect(isTitleCase('Foo BAR'), isFalse);
      expect(isTitleCase('foo Bar'), isFalse);
      expect(isTitleCase('Foo  Bar'), isFalse);
    });
  });

  group('isBinary and isOctal', () {
    test('accept only digits from their base', () {
      expect(isBinary('01101'), isTrue);
      expect(isBinary('012'), isFalse);
      expect(isOctal('0755'), isTrue);
      expect(isOctal('0758'), isFalse);
    });

    test('reject the empty string', () {
      expect(isBinary(''), isFalse);
      expect(isOctal(''), isFalse);
    });

    test('binary digits are also valid octal', () {
      expect(isOctal('0110'), isTrue);
    });
  });

  group('isBase32', () {
    test('accepts RFC 4648 uppercase output with padding', () {
      expect(isBase32('MZXW6==='), isTrue);
      expect(isBase32('MZXW6YTB'), isTrue);
    });

    test('rejects lowercase, bad padding, and the empty string', () {
      expect(isBase32('mzxw6==='), isFalse);
      expect(isBase32('MZXW6=='), isFalse);
      expect(isBase32('MZXW018'), isFalse);
      expect(isBase32(''), isFalse);
    });
  });

  group('isRgbColor', () {
    test('accepts rgb and rgba with channels in range', () {
      expect(isRgbColor('rgb(255, 0, 128)'), isTrue);
      expect(isRgbColor('rgb(0,0,0)'), isTrue);
      expect(isRgbColor('rgba(12, 34, 56, 0.5)'), isTrue);
      expect(isRgbColor('RGB(1,2,3)'), isTrue);
    });

    test('rejects an out-of-range channel', () {
      expect(isRgbColor('rgb(256, 0, 0)'), isFalse);
      expect(isRgbColor('rgb(0, 999, 0)'), isFalse);
    });

    test('rejects malformed input', () {
      expect(isRgbColor('rgb(1, 2)'), isFalse);
      expect(isRgbColor('#ff0000'), isFalse);
      expect(isRgbColor('rgb(1, 2, 3'), isFalse);
    });
  });

  group('isHslColor', () {
    test('accepts hsl and hsla with percentages in range', () {
      expect(isHslColor('hsl(210, 50%, 40%)'), isTrue);
      expect(isHslColor('hsla(0, 0%, 100%, 0.25)'), isTrue);
      expect(isHslColor('hsl(-90, 12.5%, 7%)'), isTrue);
    });

    test('rejects percentages above 100 and missing percent signs', () {
      expect(isHslColor('hsl(210, 150%, 40%)'), isFalse);
      expect(isHslColor('hsl(210, 50, 40)'), isFalse);
    });
  });

  group('isPrintable', () {
    test('accepts printable ASCII and common whitespace', () {
      expect(isPrintable('Hello, world!'), isTrue);
      expect(isPrintable('line\nbreak\ttab'), isTrue);
      expect(isPrintable(''), isTrue);
    });

    test('rejects control characters and non-ASCII', () {
      expect(isPrintable('a${String.fromCharCode(0)}b'), isFalse);
      expect(isPrintable('bell${String.fromCharCode(7)}'), isFalse);
      expect(isPrintable('héllo'), isFalse);
    });
  });

  group('hasWhitespace', () {
    test('detects any whitespace character', () {
      expect(hasWhitespace('a b'), isTrue);
      expect(hasWhitespace('a\tb'), isTrue);
      expect(hasWhitespace('  '), isTrue);
    });

    test('is false when there is none', () {
      expect(hasWhitespace('abc'), isFalse);
      expect(hasWhitespace(''), isFalse);
    });
  });

  group('startsWithIgnoreCase and endsWithIgnoreCase', () {
    test('compare without regard to case', () {
      expect(startsWithIgnoreCase('HelloWorld', 'hello'), isTrue);
      expect(endsWithIgnoreCase('HelloWorld', 'WORLD'), isTrue);
    });

    test('still respect the actual characters', () {
      expect(startsWithIgnoreCase('HelloWorld', 'world'), isFalse);
      expect(endsWithIgnoreCase('HelloWorld', 'hello'), isFalse);
    });

    test('an empty affix always matches', () {
      expect(startsWithIgnoreCase('abc', ''), isTrue);
      expect(endsWithIgnoreCase('abc', ''), isTrue);
    });
  });

  group('isAnagram', () {
    test('ignores case and punctuation by default', () {
      expect(isAnagram('Listen', 'Silent'), isTrue);
      expect(isAnagram('Dormitory', 'Dirty Room'), isTrue);
    });

    test('rejects different letter multisets', () {
      expect(isAnagram('abc', 'abd'), isFalse);
      expect(isAnagram('aab', 'abb'), isFalse);
      expect(isAnagram('abc', 'abcd'), isFalse);
    });

    test('can be made strict', () {
      expect(isAnagram('Listen', 'Silent', ignoreCase: false), isFalse);
      expect(
        isAnagram('dirty room', 'dormitory', ignoreNonAlphanumeric: false),
        isFalse,
      );
    });

    test('strings that reduce to nothing are not anagrams', () {
      expect(isAnagram('!!!', '???'), isFalse);
      expect(isAnagram('', ''), isFalse);
    });
  });

  group('isDecimal', () {
    test('without places it accepts any float', () {
      expect(isDecimal('12'), isTrue);
      expect(isDecimal('12.5'), isTrue);
      expect(isDecimal('-0.75'), isTrue);
      expect(isDecimal('abc'), isFalse);
    });

    test('with places it demands exactly that many digits', () {
      expect(isDecimal('12.50', places: 2), isTrue);
      expect(isDecimal('12.5', places: 2), isFalse);
      expect(isDecimal('12.500', places: 2), isFalse);
    });

    test('places of zero means no decimal point at all', () {
      expect(isDecimal('12', places: 0), isTrue);
      expect(isDecimal('12.0', places: 0), isFalse);
    });

    test('an integer fails a non-zero places requirement', () {
      expect(isDecimal('12', places: 2), isFalse);
    });
  });

  group('geographic coordinates', () {
    test('isLatitude spans -90 to 90 inclusive', () {
      expect(isLatitude('0'), isTrue);
      expect(isLatitude('-90'), isTrue);
      expect(isLatitude('90'), isTrue);
      expect(isLatitude('90.1'), isFalse);
      expect(isLatitude('abc'), isFalse);
    });

    test('isLongitude spans -180 to 180 inclusive', () {
      expect(isLongitude('180'), isTrue);
      expect(isLongitude('-180'), isTrue);
      expect(isLongitude('180.1'), isFalse);
    });

    test('isLatLong needs exactly two valid halves', () {
      expect(isLatLong('11.55,104.91'), isTrue);
      expect(isLatLong(' 11.55 , 104.91 '), isTrue);
      expect(isLatLong('91,104'), isFalse);
      expect(isLatLong('11.55'), isFalse);
      expect(isLatLong('1,2,3'), isFalse);
    });
  });

  group('isStrongPassword', () {
    test('accepts a password meeting every default rule', () {
      expect(isStrongPassword(r'Tr0ub4dor&3'), isTrue);
    });

    test('names each default rule it can fail', () {
      expect(isStrongPassword(r'Sh0rt!'), isFalse, reason: 'too short');
      expect(isStrongPassword(r'nouppercase1!'), isFalse);
      expect(isStrongPassword(r'NOLOWERCASE1!'), isFalse);
      expect(isStrongPassword(r'NoDigitsHere!'), isFalse);
      expect(isStrongPassword(r'NoSpecials123'), isFalse);
    });

    test('rejects whitespace unless allowed', () {
      expect(isStrongPassword(r'Has Space1!'), isFalse);
      expect(isStrongPassword(r'Has Space1!', allowWhitespace: true), isTrue);
    });

    test('honours maxLength', () {
      expect(isStrongPassword(r'Tr0ub4dor&3', maxLength: 8), isFalse);
      expect(isStrongPassword(r'Tr0ub4dor&3', maxLength: 32), isTrue);
    });

    test('with every rule disabled it is only a length check', () {
      bool check(String value) => isStrongPassword(
        value,
        minLength: 4,
        requireUppercase: false,
        requireLowercase: false,
        requireDigit: false,
        requireSpecial: false,
      );

      expect(check('abcd'), isTrue);
      expect(check('abc'), isFalse);
    });
  });

  group('fluent extensions for the new string predicates', () {
    test('mirror the top-level functions', () {
      expect('FOO_BAR'.isScreamingSnakeCase, isTrue);
      expect('Foo Bar'.isTitleCase, isTrue);
      expect('0110'.isBinary, isTrue);
      expect('0755'.isOctal, isTrue);
      expect('MZXW6YTB'.isBase32, isTrue);
      expect('rgb(1,2,3)'.isRgbColor, isTrue);
      expect('hsl(1, 2%, 3%)'.isHslColor, isTrue);
      expect('plain'.isPrintable, isTrue);
      expect('a b'.hasWhitespace, isTrue);
      expect('11.55'.isLatitude, isTrue);
      expect('104.91'.isLongitude, isTrue);
      expect('11.55,104.91'.isLatLong, isTrue);
      expect('Listen'.isAnagram('Silent'), isTrue);
      expect('12.50'.isDecimal(places: 2), isTrue);
      expect(r'Tr0ub4dor&3'.isStrongPassword(), isTrue);
    });

    test('expose the previously function-only experimental predicates', () {
      expect('Ａ'.isFullWidth, isTrue);
      expect('A'.isHalfWidth, isTrue);
      expect('héllo'.isMultiByte, isTrue);
      expect('𝄞'.isSurrogatePair, isTrue);
      expect('Aａ'.isVariableWidth, isTrue);
    });
  });
}
