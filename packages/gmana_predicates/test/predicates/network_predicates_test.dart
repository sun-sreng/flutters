import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

void main() {
  group('network_predicates', () {
    test('isIpv4 and isIpv6 validate IP addresses', () {
      expect(isIpv4('192.168.1.1'), isTrue);
      expect(isIpv4('256.0.0.1'), isFalse);

      expect(isIpv6('2001:0db8:85a3:0000:0000:8a2e:0370:7334'), isTrue);
      expect(isIpv6('invalid-ipv6'), isFalse);
    });

    test('isUrl validates HTTP/HTTPS URLs', () {
      expect(isUrl('https://example.com/api'), isTrue);
      expect(isUrl('http://localhost:8080'), isTrue);
      expect(isUrl('ftp://server.com', allowedSchemes: {'https'}), isFalse);
      expect(isUrl('not-a-url'), isFalse);
    });

    test('isMacAddress validates MAC format', () {
      expect(isMacAddress('00:1A:2B:3C:4D:5E'), isTrue);
      expect(isMacAddress('00-1A-2B-3C-4D-5E'), isTrue);
      expect(isMacAddress('001A2B3C4D5E'), isFalse);
    });

    test('isPort validates network port range', () {
      expect(isPort('80'), isTrue);
      expect(isPort('8080'), isTrue);
      expect(isPort('65535'), isTrue);
      expect(isPort('0'), isFalse);
      expect(isPort('70000'), isFalse);
    });

    test('isIP validates IPv4 and IPv6 addresses', () {
      expect(isIP('192.168.1.1'), isTrue);
      expect(isIP('2001:0db8:85a3:0000:0000:8a2e:0370:7334'), isTrue);
      expect(isIP('192.168.1.1', 4), isTrue);
      expect(isIP('192.168.1.1', 6), isFalse);
      expect(isIP('invalid'), isFalse);
    });

    test('isCidr validates CIDR block notation', () {
      expect(isCidr('192.168.1.0/24'), isTrue);
      expect(isCidr('10.0.0.0/8'), isTrue);
      expect(isCidr('192.168.1.0/33'), isFalse);

      expect(isCidr('2001:db8::/32'), isTrue);
      expect(isCidr('192.168.1.0/24', 4), isTrue);
      expect(isCidr('192.168.1.0/24', 6), isFalse);
    });

    test('isDataURI validates RFC 2397 Data URIs', () {
      expect(
        isDataURI(
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        ),
        isTrue,
      );
      expect(isDataURI('data:text/plain;charset=utf-8,Hello%20World'), isTrue);
      expect(isDataURI('http://example.com'), isFalse);
    });

    test('isMagnetURI validates BitTorrent magnet URLs', () {
      expect(
        isMagnetURI(
          'magnet:?xt=urn:btih:d247454ee63b1553772edd4037a2b93f7451369e&dn=Ubuntu',
        ),
        isTrue,
      );
      expect(isMagnetURI('https://example.com'), isFalse);
    });
  });
}
