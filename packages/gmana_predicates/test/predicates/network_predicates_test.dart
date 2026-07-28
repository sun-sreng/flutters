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
  });
}
