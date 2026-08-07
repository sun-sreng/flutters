import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('StringX tokenizing', () {
    test('words splits on separators and camelCase boundaries', () {
      expect('user_firstName'.words, ['user', 'first', 'Name']);
      expect('hello world'.words, ['hello', 'world']);
      expect('  '.words, isEmpty);
    });

    test('lines splits on every line-break style', () {
      expect('a\nb\r\nc\rd'.lines, ['a', 'b', 'c', 'd']);
      expect('single'.lines, ['single']);
    });

    test('initials takes leading capitals', () {
      expect('ada lovelace'.initials(), 'AL');
      expect('Grace Brewster Hopper'.initials(max: 3), 'GBH');
      expect('Grace Brewster Hopper'.initials(), 'GB');
      expect('   spaced   out  '.initials(), 'SO');
      expect(''.initials(), '');
    });

    test('initials rejects a negative max', () {
      expect(() => 'a b'.initials(max: -1), throwsArgumentError);
    });

    test('chunked splits into fixed-width pieces', () {
      expect('4111111111111111'.chunked(4), ['4111', '1111', '1111', '1111']);
      expect('abcde'.chunked(2), ['ab', 'cd', 'e']);
      expect(''.chunked(3), isEmpty);
      expect(() => 'abc'.chunked(0), throwsArgumentError);
    });
  });

  group('StringX case-insensitive comparison', () {
    test('equalsIgnoreCase', () {
      expect('Hello'.equalsIgnoreCase('HELLO'), isTrue);
      expect('Hello'.equalsIgnoreCase('Hell'), isFalse);
    });

    test('containsIgnoreCase', () {
      expect('Hello World'.containsIgnoreCase('LO WO'), isTrue);
      expect('Hello'.containsIgnoreCase('xyz'), isFalse);
    });

    test('startsWithIgnoreCase and endsWithIgnoreCase', () {
      expect('Hello'.startsWithIgnoreCase('HE'), isTrue);
      expect('Hello'.endsWithIgnoreCase('LO'), isTrue);
      expect('Hello'.startsWithIgnoreCase('lo'), isFalse);
    });

    test('swapCase flips every letter', () {
      expect('Hello'.swapCase, 'hELLO');
      expect('a1B'.swapCase, 'A1b');
    });
  });

  group('StringX padding and affixes', () {
    test('ensurePrefix and ensureSuffix are idempotent', () {
      expect('example.com'.ensurePrefix('https://'), 'https://example.com');
      expect(
        'https://example.com'.ensurePrefix('https://'),
        'https://example.com',
      );
      expect('path'.ensureSuffix('/'), 'path/');
      expect('path/'.ensureSuffix('/'), 'path/');
    });

    test('padCenter distributes padding, extra to the right', () {
      expect('ok'.padCenter(6, '-'), '--ok--');
      expect('abc'.padCenter(6), ' abc  ');
      expect('already wide'.padCenter(3), 'already wide');
    });

    test('padCenter validates the pad character', () {
      expect(() => 'a'.padCenter(5, '--'), throwsArgumentError);
    });

    test('indent prefixes every non-empty line', () {
      expect('a\nb'.indent(2), '  a\n  b');
      expect('a\n\nb'.indent(2), '  a\n\n  b');
      expect('a\nb'.indent(0, prefix: '> '), '> a\n> b');
      expect(() => 'a'.indent(-1), throwsArgumentError);
    });

    test('normalizeWhitespace collapses runs and trims', () {
      expect('  a   b \n c '.normalizeWhitespace, 'a b c');
      expect('single'.normalizeWhitespace, 'single');
    });

    test('stripHtmlTags removes markup', () {
      expect('<p>Hi <b>there</b></p>'.stripHtmlTags, 'Hi there');
      expect('no tags'.stripHtmlTags, 'no tags');
    });
  });

  group('StringX safe indexing', () {
    test('charAtOrNull stays in range', () {
      expect('abc'.charAtOrNull(1), 'b');
      expect('abc'.charAtOrNull(3), isNull);
      expect('abc'.charAtOrNull(-1), isNull);
    });

    test('substringSafe clamps instead of throwing', () {
      expect('abc'.substringSafe(1, 99), 'bc');
      expect('abc'.substringSafe(-5), 'abc');
      expect('abc'.substringSafe(5), '');
      expect('abc'.substringSafe(2, 1), '');
      expect(''.substringSafe(0, 5), '');
    });
  });

  group('StringX encoding and parsing', () {
    test('toBase64 round-trips through fromBase64OrNull', () {
      expect('hello'.toBase64, 'aGVsbG8=');
      expect('aGVsbG8='.fromBase64OrNull, 'hello');
      expect('Hello world'.toBase64.fromBase64OrNull, 'Hello world');
    });

    test('toBase64 handles non-ASCII text', () {
      const text = 'ជំរាបសួរ';
      expect(text.toBase64.fromBase64OrNull, text);
    });

    test('fromBase64OrNull returns null on garbage', () {
      expect('not base64!!!'.fromBase64OrNull, isNull);
    });

    test('toBoolOrNull is lenient but explicit', () {
      expect('true'.toBoolOrNull, isTrue);
      expect('YES'.toBoolOrNull, isTrue);
      expect(' On '.toBoolOrNull, isTrue);
      expect('1'.toBoolOrNull, isTrue);
      expect('false'.toBoolOrNull, isFalse);
      expect('n'.toBoolOrNull, isFalse);
      expect('0'.toBoolOrNull, isFalse);
      expect('maybe'.toBoolOrNull, isNull);
      expect(''.toBoolOrNull, isNull);
    });
  });

  group('StringX fuzzy matching', () {
    test('levenshteinDistance counts edits', () {
      expect('kitten'.levenshteinDistance('sitting'), 3);
      expect('same'.levenshteinDistance('same'), 0);
      expect(''.levenshteinDistance('abc'), 3);
      expect('abc'.levenshteinDistance(''), 3);
      expect('colour'.levenshteinDistance('color'), 1);
    });

    test('levenshteinDistance is symmetric', () {
      expect(
        'flaw'.levenshteinDistance('lawn'),
        'lawn'.levenshteinDistance('flaw'),
      );
    });

    test('similarityTo scales to [0, 1]', () {
      expect('colour'.similarityTo('color'), closeTo(0.8333, 0.0001));
      expect('same'.similarityTo('same'), 1.0);
      expect(''.similarityTo(''), 1.0);
      expect('abc'.similarityTo('xyz'), 0.0);
    });
  });

  group('StringNullableX fallbacks', () {
    test('ifBlank treats whitespace as missing', () {
      const String? missing = null;
      expect(missing.ifBlank('Anonymous'), 'Anonymous');
      expect('   '.ifBlank('Anonymous'), 'Anonymous');
      expect('Ada'.ifBlank('Anonymous'), 'Ada');
    });

    test('ifEmpty keeps whitespace', () {
      const String? missing = null;
      expect(missing.ifEmpty('fallback'), 'fallback');
      expect(''.ifEmpty('fallback'), 'fallback');
      expect('   '.ifEmpty('fallback'), '   ');
    });
  });
}
