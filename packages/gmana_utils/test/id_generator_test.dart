import 'dart:convert';

import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('IdGenerator', () {
    // -----------------------------------------------------------------------
    // encodeToBase64 / decodeFromBase64
    // -----------------------------------------------------------------------

    group('encodeToBase64', () {
      test('encodes JSON payloads reversibly via dart:convert', () {
        final encoded = IdGenerator.encodeToBase64(['user', 123]);
        final decoded = json.decode(utf8.decode(base64.decode(encoded)));

        expect(decoded, ['user', 123]);
      });

      test('surfaces unsupported JSON values', () {
        expect(
          () => IdGenerator.encodeToBase64([Object()]),
          throwsA(isA<JsonUnsupportedObjectError>()),
        );
      });
    });

    group('decodeFromBase64', () {
      test('round-trips a list produced by encodeToBase64', () {
        final input = ['hello', 42, true, null];
        final encoded = IdGenerator.encodeToBase64(input);
        expect(IdGenerator.decodeFromBase64(encoded), equals(input));
      });

      test('throws FormatException for non-array JSON payload', () {
        // Manually encode a JSON object (not an array).
        final bad = base64.encode(utf8.encode(json.encode({'k': 'v'})));
        expect(
          () => IdGenerator.decodeFromBase64(bad),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws on invalid Base64 input', () {
        expect(
          () => IdGenerator.decodeFromBase64('not-valid-base64!!!'),
          throwsA(anything),
        );
      });
    });

    // -----------------------------------------------------------------------
    // nanoid
    // -----------------------------------------------------------------------

    group('nanoid', () {
      test('default size is 21', () {
        expect(IdGenerator.nanoid(), hasLength(21));
      });

      test('respects a custom size', () {
        expect(IdGenerator.nanoid(size: 10), hasLength(10));
      });

      test('rejects non-positive size', () {
        expect(() => IdGenerator.nanoid(size: 0), throwsArgumentError);
        expect(() => IdGenerator.nanoid(size: -1), throwsArgumentError);
      });

      test('uses a custom alphabet when provided', () {
        const alphabet = 'abc';
        final id = IdGenerator.nanoid(size: 20, alphabet: alphabet);
        expect(id, hasLength(20));
        expect(id.split('').every(alphabet.contains), isTrue);
      });

      test('rejects an empty custom alphabet', () {
        expect(() => IdGenerator.nanoid(alphabet: ''), throwsArgumentError);
      });
    });

    // -----------------------------------------------------------------------
    // randomString
    // -----------------------------------------------------------------------

    group('randomString', () {
      test('respects requested length', () {
        expect(IdGenerator.randomString(length: 12), hasLength(12));
      });

      test('rejects non-positive length', () {
        expect(() => IdGenerator.randomString(length: 0), throwsArgumentError);
      });

      test('rejects all character sets disabled', () {
        expect(
          () => IdGenerator.randomString(
            useLetters: false,
            useNumbers: false,
            useSymbols: false,
          ),
          throwsArgumentError,
        );
      });

      test('letters-only result contains no digits or symbols', () {
        final id = IdGenerator.randomString(
          length: 100,
          useLetters: true,
          useNumbers: false,
          useSymbols: false,
        );
        expect(id, matches(RegExp(r'^[a-zA-Z]+$')));
      });

      test('numbers-only result contains only digits', () {
        final id = IdGenerator.randomString(
          length: 50,
          useLetters: false,
          useNumbers: true,
          useSymbols: false,
        );
        expect(id, matches(RegExp(r'^[0-9]+$')));
      });
    });

    // -----------------------------------------------------------------------
    // shortId
    // -----------------------------------------------------------------------

    group('shortId', () {
      test('default length is 8', () {
        expect(IdGenerator.shortId(), hasLength(8));
      });

      test('respects a custom length', () {
        expect(IdGenerator.shortId(length: 16), hasLength(16));
      });

      test('contains only alphanumeric characters', () {
        final id = IdGenerator.shortId(length: 200);
        expect(id, matches(RegExp(r'^[a-zA-Z0-9]+$')));
      });

      test('rejects non-positive length', () {
        expect(() => IdGenerator.shortId(length: 0), throwsArgumentError);
      });
    });

    // -----------------------------------------------------------------------
    // prefixed
    // -----------------------------------------------------------------------

    group('prefixed', () {
      test('output starts with prefix followed by underscore', () {
        final id = IdGenerator.prefixed('cus');
        expect(id, startsWith('cus_'));
      });

      test('default suffix length is 16 alphanumeric characters', () {
        final id = IdGenerator.prefixed('pay');
        final suffix = id.substring('pay_'.length);
        expect(suffix, hasLength(16));
        expect(suffix, matches(RegExp(r'^[a-zA-Z0-9]+$')));
      });

      test('respects a custom suffix length', () {
        final id = IdGenerator.prefixed('inv', length: 8);
        final suffix = id.substring('inv_'.length);
        expect(suffix, hasLength(8));
      });

      test('rejects empty prefix', () {
        expect(() => IdGenerator.prefixed(''), throwsArgumentError);
      });

      test('rejects non-positive length', () {
        expect(() => IdGenerator.prefixed('x', length: 0), throwsArgumentError);
      });
    });

    // -----------------------------------------------------------------------
    // timestampId
    // -----------------------------------------------------------------------

    group('timestampId', () {
      test('starts with G followed by a decimal timestamp', () {
        final id = IdGenerator.timestampId();
        expect(id, matches(RegExp(r'^G\d+-[0-9a-f]+-[0-9a-f]+$')));
      });

      test('two successive IDs both start with G', () {
        expect(IdGenerator.timestampId(), startsWith('G'));
        expect(IdGenerator.timestampId(), startsWith('G'));
      });
    });

    // -----------------------------------------------------------------------
    // ulid
    // -----------------------------------------------------------------------

    group('ulid', () {
      test('is exactly 26 characters', () {
        expect(IdGenerator.ulid(), hasLength(26));
      });

      test('contains only Crockford Base32 characters', () {
        final id = IdGenerator.ulid();
        expect(id, matches(RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$')));
      });

      test('successive ULIDs within the same millisecond are not equal', () {
        // Extremely unlikely to collide with 80 bits of randomness.
        expect(IdGenerator.ulid(), isNot(equals(IdGenerator.ulid())));
      });

      test('lexicographic order reflects time order across milliseconds', () {
        // Generate with a deliberate gap so timestamps differ.
        final a = IdGenerator.ulid();
        // Busy-wait until the millisecond ticks over (max ~2 ms in practice).
        final start = DateTime.now().millisecondsSinceEpoch;
        while (DateTime.now().millisecondsSinceEpoch == start) {}
        final b = IdGenerator.ulid();

        expect(a.compareTo(b), lessThan(0));
      });
    });

    // -----------------------------------------------------------------------
    // uuidV4Like
    // -----------------------------------------------------------------------

    group('uuidV4Like', () {
      test(
        'matches UUID v4 shape with version nibble 4 and variant bits 8–b',
        () {
          expect(
            IdGenerator.uuidV4Like(),
            matches(
              RegExp(
                r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              ),
            ),
          );
        },
      );
    });

    // -----------------------------------------------------------------------
    // deprecated uuidV1
    // -----------------------------------------------------------------------

    group('uuidV1 (deprecated)', () {
      test('delegates to uuidV4Like', () {
        // ignore: deprecated_member_use
        expect(IdGenerator.uuidV1(), contains('-4'));
      });
    });
  });

  // =========================================================================
  // SecureIdGenerator
  // =========================================================================

  group('SecureIdGenerator', () {
    group('nanoid', () {
      test('produces the correct length', () {
        expect(SecureIdGenerator.nanoid(), hasLength(21));
        expect(SecureIdGenerator.nanoid(size: 10), hasLength(10));
      });

      test('respects a custom alphabet', () {
        const alphabet = 'xyz';
        final id = SecureIdGenerator.nanoid(size: 15, alphabet: alphabet);
        expect(id, hasLength(15));
        expect(id.split('').every(alphabet.contains), isTrue);
      });

      test('rejects non-positive size', () {
        expect(() => SecureIdGenerator.nanoid(size: 0), throwsArgumentError);
      });

      test('rejects empty alphabet', () {
        expect(
          () => SecureIdGenerator.nanoid(alphabet: ''),
          throwsArgumentError,
        );
      });
    });

    group('randomString', () {
      test('produces the correct length', () {
        expect(SecureIdGenerator.randomString(length: 16), hasLength(16));
      });

      test('letters-only contains no digits or symbols', () {
        final id = SecureIdGenerator.randomString(
          length: 100,
          useLetters: true,
          useNumbers: false,
          useSymbols: false,
        );
        expect(id, matches(RegExp(r'^[a-zA-Z]+$')));
      });

      test('rejects non-positive length', () {
        expect(
          () => SecureIdGenerator.randomString(length: 0),
          throwsArgumentError,
        );
      });
    });

    group('shortId', () {
      test('default length is 8 and alphanumeric only', () {
        final id = SecureIdGenerator.shortId();
        expect(id, hasLength(8));
        expect(id, matches(RegExp(r'^[a-zA-Z0-9]+$')));
      });

      test('rejects non-positive length', () {
        expect(() => SecureIdGenerator.shortId(length: 0), throwsArgumentError);
      });
    });

    group('prefixed', () {
      test('output is prefix_suffix with alphanumeric suffix', () {
        final id = SecureIdGenerator.prefixed('sk');
        expect(id, startsWith('sk_'));
        final suffix = id.substring('sk_'.length);
        expect(suffix, hasLength(16));
        expect(suffix, matches(RegExp(r'^[a-zA-Z0-9]+$')));
      });

      test('rejects empty prefix', () {
        expect(() => SecureIdGenerator.prefixed(''), throwsArgumentError);
      });
    });

    group('ulid', () {
      test('is 26 Crockford Base32 characters', () {
        final id = SecureIdGenerator.ulid();
        expect(id, hasLength(26));
        expect(id, matches(RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$')));
      });
    });

    group('uuidV4Like', () {
      test('matches UUID v4 shape', () {
        expect(
          SecureIdGenerator.uuidV4Like(),
          matches(
            RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
            ),
          ),
        );
      });
    });

    // -----------------------------------------------------------------------
    // safeEqual
    // -----------------------------------------------------------------------

    group('safeEqual', () {
      test('returns true for identical strings', () {
        expect(SecureIdGenerator.safeEqual('abc', 'abc'), isTrue);
      });

      test('returns true for empty strings', () {
        expect(SecureIdGenerator.safeEqual('', ''), isTrue);
      });

      test('returns false when strings differ by one character', () {
        expect(SecureIdGenerator.safeEqual('abc', 'axc'), isFalse);
      });

      test('returns false when first string is longer', () {
        expect(SecureIdGenerator.safeEqual('abcd', 'abc'), isFalse);
      });

      test('returns false when second string is longer', () {
        expect(SecureIdGenerator.safeEqual('abc', 'abcd'), isFalse);
      });

      test('returns false for completely different strings', () {
        expect(SecureIdGenerator.safeEqual('hello', 'world'), isFalse);
      });

      test('returns false when one string is empty and the other is not', () {
        expect(SecureIdGenerator.safeEqual('', 'a'), isFalse);
        expect(SecureIdGenerator.safeEqual('a', ''), isFalse);
      });

      test('is case-sensitive', () {
        expect(SecureIdGenerator.safeEqual('Token', 'token'), isFalse);
      });

      test('round-trips a SecureIdGenerator token correctly', () {
        final token = SecureIdGenerator.shortId(length: 32);
        expect(SecureIdGenerator.safeEqual(token, token), isTrue);
        expect(SecureIdGenerator.safeEqual(token, '${token}x'), isFalse);
      });
    });
  });
}
