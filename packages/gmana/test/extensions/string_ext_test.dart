import 'package:gmana/extensions/string_ext.dart';
import 'package:test/test.dart';

void main() {
  group('StringX Parsing', () {
    test('toDoubleOrNull', () {
      expect('1.5'.toDoubleOrNull, equals(1.5));
      expect('abc'.toDoubleOrNull, isNull);
    });

    test('toDoubleOrZero', () {
      expect('1.5'.toDoubleOrZero, equals(1.5));
      expect('abc'.toDoubleOrZero, equals(0.0));
    });

    test('toIntOrNull', () {
      expect('15'.toIntOrNull, equals(15));
      expect('1.5'.toIntOrNull, isNull);
      expect('abc'.toIntOrNull, isNull);
    });

    test('toIntOrZero', () {
      expect('15'.toIntOrZero, equals(15));
      expect('1.5'.toIntOrZero, equals(0));
      expect('abc'.toIntOrZero, equals(0));
    });

    test('toBool', () {
      expect('true'.toBool, isTrue);
      expect(' TRUE '.toBool, isTrue);
      expect('false'.toBool, isFalse);
      expect('abc'.toBool, isFalse);
    });

    test('toUriOrNull', () {
      expect(
        'https://google.com'.toUriOrNull,
        equals(Uri.parse('https://google.com')),
      );
      expect('http://[::1]'.toUriOrNull, equals(Uri.parse('http://[::1]')));
    });

    test('jsonDecodeOrNull', () {
      expect('{"a": 1}'.jsonDecodeOrNull, equals({'a': 1}));
      expect('invalid json'.jsonDecodeOrNull, isNull);
    });
  });

  group('StringX Duration', () {
    test('toDuration', () {
      expect('45'.toDuration(), equals(const Duration(seconds: 45)));
      expect(
        '05:09'.toDuration(),
        equals(const Duration(minutes: 5, seconds: 9)),
      );
      expect(
        '02:30:45'.toDuration(),
        equals(const Duration(hours: 2, minutes: 30, seconds: 45)),
      );
      expect(() => '70'.toDuration(), throwsFormatException);
      expect(() => '05:70'.toDuration(), throwsFormatException);
      expect(() => 'abc'.toDuration(), throwsFormatException);
    });

    test('toDurationOrNull', () {
      expect(
        '05:09'.toDurationOrNull,
        equals(const Duration(minutes: 5, seconds: 9)),
      );
      expect('abc'.toDurationOrNull, isNull);
      expect('70'.toDurationOrNull, isNull);
    });
  });

  group('StringX Case Formatting', () {
    test('toSentenceCase', () {
      expect('hello'.toSentenceCase, equals('Hello'));
      expect('Hello'.toSentenceCase, equals('Hello'));
      expect(''.toSentenceCase, equals(''));
    });

    test('toTitleCase', () {
      expect('hello world'.toTitleCase, equals('Hello World'));
      expect(' hello  world '.toTitleCase, equals('Hello World'));
    });

    test('toCamelCase', () {
      expect('Hello World'.toCamelCase, equals('helloWorld'));
      expect('hello_world'.toCamelCase, equals('helloWorld'));
      expect('hello-world'.toCamelCase, equals('helloWorld'));
    });

    test('toSnakeCase', () {
      expect('Hello World'.toSnakeCase, equals('hello_world'));
      expect('helloWorld'.toSnakeCase, equals('hello_world'));
    });

    test('toKebabCase', () {
      expect('Hello World'.toKebabCase, equals('hello-world'));
      expect('helloWorld'.toKebabCase, equals('hello-world'));
    });

    test('toScreamingSnakeCase', () {
      expect('hello world'.toScreamingSnakeCase, equals('HELLO_WORLD'));
      expect('helloWorld'.toScreamingSnakeCase, equals('HELLO_WORLD'));
    });
  });

  group('StringX Slug', () {
    test('toSlug', () {
      expect('Hello World! 2024'.toSlug, equals('hello-world-2024'));
      expect('  Some   Text--Here  '.toSlug, equals('-some-text-here-'));
    });
  });

  group('StringX Truncation', () {
    test('truncate', () {
      expect('Hello World'.truncate(7), equals('Hell...'));
      expect('Hello'.truncate(10), equals('Hello'));
    });

    test('truncateWords', () {
      expect(
        'Hello World Everyone'.truncateWords(15),
        equals('Hello World...'),
      );
      expect('HelloWorldEveryone'.truncateWords(15), equals('HelloWorldEv...'));
      expect('Hello'.truncateWords(10), equals('Hello'));
    });
  });

  group('StringX Validation', () {
    test('isEmail', () {
      expect('test@example.com'.isEmail, isTrue);
      expect('invalid-email'.isEmail, isFalse);
    });

    test('isUrl', () {
      expect('https://google.com/'.isUrl, isTrue);
      expect('http://localhost/'.isUrl, isTrue);
      expect('https://google.com'.isUrl, isFalse);
    });

    test('isNumeric', () {
      expect('123'.isNumeric, isTrue);
      expect('12.3'.isNumeric, isTrue);
      expect('-12.3'.isNumeric, isTrue);
      expect('abc'.isNumeric, isFalse);
    });

    test('isAlpha', () {
      expect('abcABC'.isAlpha, isTrue);
      expect('abc123'.isAlpha, isFalse);
      expect('abc-def'.isAlpha, isFalse);
    });

    test('isAlphanumeric', () {
      expect('abc123'.isAlphanumeric, isTrue);
      expect('abc-123'.isAlphanumeric, isFalse);
    });

    test('hasLengthBetween', () {
      expect('abc'.hasLengthBetween(2, 4), isTrue);
      expect('abc'.hasLengthBetween(4, 5), isFalse);
      expect(' abc '.hasLengthBetween(1, 3), isTrue);
    });
  });

  group('StringX Whitespace / Blank', () {
    test('isBlank', () {
      expect(''.isBlank, isTrue);
      expect('   '.isBlank, isTrue);
      expect('a'.isBlank, isFalse);
    });

    test('isNotBlank', () {
      expect(''.isNotBlank, isFalse);
      expect('   '.isNotBlank, isFalse);
      expect('a'.isNotBlank, isTrue);
    });

    test('blankToNull', () {
      expect('   '.blankToNull, isNull);
      expect('a'.blankToNull, equals('a'));
    });
  });

  group('StringX Reading Time', () {
    test('readingTimeMinutes', () {
      expect(''.readingTimeMinutes, equals(0));
      expect('word '.repeat(225).readingTimeMinutes, equals(1));
      expect('word '.repeat(400).readingTimeMinutes, equals(2));
    });
  });

  group('StringX Misc', () {
    test('repeat', () {
      expect('-'.repeat(10), equals('----------'));
    });

    test('reversed', () {
      expect('hello'.reversed, equals('olleh'));
      expect('😎🚀'.reversed, equals('🚀😎'));
    });

    test('removeWhitespace', () {
      expect(' a b  c '.removeWhitespace, equals('abc'));
      expect('\n a \t b \r'.removeWhitespace, equals('ab'));
    });

    test('countOccurrences', () {
      expect('hello world hello'.countOccurrences('hello'), equals(2));
      expect('aaaa'.countOccurrences('aa'), equals(2));
      expect('abc'.countOccurrences(''), equals(0));
    });

    test('wrap', () {
      expect('world'.wrap('**'), equals('**world**'));
      expect('note'.wrap('<', '>'), equals('<note>'));
    });
  });

  group('StringNullableX', () {
    test('orEmpty', () {
      expect((null as String?).orEmpty, equals(''));
      expect('a'.orEmpty, equals('a'));
    });

    test('isNullOrEmpty', () {
      expect((null as String?).isNullOrEmpty, isTrue);
      expect(''.isNullOrEmpty, isTrue);
      expect('a'.isNullOrEmpty, isFalse);
      expect(' '.isNullOrEmpty, isFalse);
    });

    test('isNullOrBlank', () {
      expect((null as String?).isNullOrBlank, isTrue);
      expect(''.isNullOrBlank, isTrue);
      expect(' '.isNullOrBlank, isTrue);
      expect('a'.isNullOrBlank, isFalse);
    });

    test('orNull', () {
      expect((null as String?).orNull, isNull);
      expect(''.orNull, isNull);
      expect(' '.orNull, isNull);
      expect('a'.orNull, equals('a'));
    });

    test('mapNotBlank', () {
      expect((null as String?).mapNotBlank((s) => s.toUpperCase()), isNull);
      expect('  '.mapNotBlank((s) => s.toUpperCase()), isNull);
      expect('a'.mapNotBlank((s) => '${s}b'), equals('ab'));
    });
  });
}
