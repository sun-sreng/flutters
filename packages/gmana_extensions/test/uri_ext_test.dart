import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('UriX accessors', () {
    test('scheme predicates', () {
      expect(Uri.parse('https://a.com').isSecure, isTrue);
      expect(Uri.parse('http://a.com').isSecure, isFalse);
      expect(Uri.parse('http://a.com').isHttp, isTrue);
      expect(Uri.parse('ftp://a.com').isHttp, isFalse);
    });

    test('domain strips a leading www', () {
      expect(Uri.parse('https://www.example.com/a').domain, 'example.com');
      expect(Uri.parse('https://example.com/a').domain, 'example.com');
      expect(Uri.parse('https://wwwx.example.com').domain, 'wwwx.example.com');
    });

    test('fileName returns the last non-empty segment', () {
      expect(Uri.parse('https://x.com/docs/guide.pdf').fileName, 'guide.pdf');
      expect(Uri.parse('https://x.com/docs/').fileName, isNull);
      expect(Uri.parse('https://x.com').fileName, isNull);
    });

    test('fileExtension reads the trailing extension', () {
      expect(Uri.parse('https://x.com/a/report.tar.gz').fileExtension, 'gz');
      expect(Uri.parse('https://x.com/a/report').fileExtension, isNull);
      expect(Uri.parse('https://x.com/a/.env').fileExtension, isNull);
    });

    test('origin drops path, query, and fragment', () {
      expect(
        Uri.parse('https://x.com:8080/a/b?c=1#d').origin.toString(),
        'https://x.com:8080',
      );
    });
  });

  group('UriX builders', () {
    test('withQueryParameters merges and removes', () {
      final uri = Uri.parse('https://x.com/s?q=a');
      final next = uri.withQueryParameters({'page': 2, 'q': null});

      expect(next.toString(), 'https://x.com/s?page=2');
    });

    test('withQueryParameters supports repeated keys', () {
      final uri = Uri.parse('https://x.com/s');
      final next = uri.withQueryParameters({
        'tag': ['a', 'b'],
      });

      expect(next.queryParametersAll['tag'], ['a', 'b']);
    });

    test('withQueryParameters overwrites an existing key', () {
      final uri = Uri.parse('https://x.com/s?page=1');
      expect(
        uri.withQueryParameters({'page': 9}).toString(),
        'https://x.com/s?page=9',
      );
    });

    test('withoutQueryParameters removes the named keys', () {
      final uri = Uri.parse('https://x.com/a?b=1&c=2');
      expect(
        uri.withoutQueryParameters(['b']).toString(),
        'https://x.com/a?c=2',
      );
      expect(
        uri.withoutQueryParameters(['b', 'c']).toString(),
        'https://x.com/a',
      );
    });

    test('withoutQuery keeps everything but the query', () {
      expect(
        Uri.parse('https://x.com/a?b=1#frag').withoutQuery.toString(),
        'https://x.com/a#frag',
      );
    });

    test('appendPath joins segments', () {
      expect(
        Uri.parse('https://api.dev/v1').appendPath(['users', '42']).toString(),
        'https://api.dev/v1/users/42',
      );
    });

    test('appendPath splits embedded slashes and ignores empties', () {
      expect(
        Uri.parse('https://api.dev/').appendPath(['/v1/users/', '']).toString(),
        'https://api.dev/v1/users',
      );
    });
  });

  group('UriNullableX', () {
    test('null-safe helpers', () {
      const Uri? missing = null;
      expect(missing.isNullOrEmpty, isTrue);
      expect(missing.orEmpty, '');
      expect(Uri.parse('https://x.com').orEmpty, 'https://x.com');
    });
  });
}
