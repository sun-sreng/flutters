import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

void main() {
  group('isIban', () {
    test('accepts published example IBANs', () {
      expect(isIban('GB82WEST12345698765432'), isTrue);
      expect(isIban('DE89370400440532013000'), isTrue);
      expect(isIban('FR1420041010050500013M02606'), isTrue);
      expect(isIban('NL91ABNA0417164300'), isTrue);
    });

    test('accepts the grouped print form and lowercase', () {
      expect(isIban('GB82 WEST 1234 5698 7654 32'), isTrue);
      expect(isIban('gb82 west 1234 5698 7654 32'), isTrue);
    });

    test('rejects a wrong check digit', () {
      expect(isIban('GB83WEST12345698765432'), isFalse);
      expect(isIban('DE88370400440532013000'), isFalse);
    });

    test('rejects a transposed digit', () {
      expect(isIban('GB82WEST12345698765423'), isFalse);
    });

    test('rejects structurally invalid input', () {
      expect(isIban(''), isFalse);
      expect(isIban('GB82'), isFalse);
      expect(isIban('1282WEST12345698765432'), isFalse);
      expect(isIban('GB82WEST123456987654321234567890123'), isFalse);
    });
  });

  group('isBic', () {
    test('accepts the 8- and 11-character forms', () {
      expect(isBic('DEUTDEFF'), isTrue);
      expect(isBic('DEUTDEFF500'), isTrue);
      expect(isBic('NEDSZAJJXXX'), isTrue);
    });

    test('normalises case and spacing', () {
      expect(isBic('deutdeff'), isTrue);
      expect(isBic('DEUT DEFF'), isTrue);
    });

    test('rejects the wrong length or digits in the bank code', () {
      expect(isBic('DEUTDEF'), isFalse);
      expect(isBic('DEUTDEFF5'), isFalse);
      expect(isBic('DEUTDEFF5000'), isFalse);
      expect(isBic('DEUT1EFF'), isFalse);
    });
  });

  group('isUuid with the versions added alongside 3, 4 and 5', () {
    test('matches a v7 UUID', () {
      const v7 = '018f7b1a-9c2e-7d3f-8a4b-5c6d7e8f9a0b';

      expect(isUuid(v7, '7'), isTrue);
      expect(isUuid(v7), isTrue);
      expect(isUuid(v7, '4'), isFalse);
    });

    test('matches v1 and v6 UUIDs', () {
      expect(isUuid('c232ab00-9414-11ec-b3c8-9f6bdeced846', '1'), isTrue);
      expect(isUuid('1ec9414c-232a-6b00-b3c8-9f6bdeced846', '6'), isTrue);
    });

    test('still matches v4 and rejects an unknown version key', () {
      const v4 = '550e8400-e29b-41d4-a716-446655440000';

      expect(isUuid(v4, '4'), isTrue);
      expect(isUuid(v4, '9'), isFalse);
    });
  });

  group('isPrivateIpv4', () {
    test('accepts each RFC 1918 block', () {
      expect(isPrivateIpv4('10.0.0.1'), isTrue);
      expect(isPrivateIpv4('172.16.0.1'), isTrue);
      expect(isPrivateIpv4('172.31.255.254'), isTrue);
      expect(isPrivateIpv4('192.168.1.1'), isTrue);
    });

    test('rejects the addresses just outside the 172.16/12 block', () {
      expect(isPrivateIpv4('172.15.0.1'), isFalse);
      expect(isPrivateIpv4('172.32.0.1'), isFalse);
    });

    test('rejects public addresses, loopback, and non-IPs', () {
      expect(isPrivateIpv4('8.8.8.8'), isFalse);
      expect(isPrivateIpv4('127.0.0.1'), isFalse);
      expect(isPrivateIpv4('192.169.1.1'), isFalse);
      expect(isPrivateIpv4('not an ip'), isFalse);
    });
  });

  group('isLoopbackIpv4', () {
    test('accepts the whole 127/8 block', () {
      expect(isLoopbackIpv4('127.0.0.1'), isTrue);
      expect(isLoopbackIpv4('127.255.255.254'), isTrue);
    });

    test('rejects anything else', () {
      expect(isLoopbackIpv4('128.0.0.1'), isFalse);
      expect(isLoopbackIpv4('10.0.0.1'), isFalse);
    });
  });

  group('isPublicIpv4', () {
    test('accepts routable addresses', () {
      expect(isPublicIpv4('8.8.8.8'), isTrue);
      expect(isPublicIpv4('1.1.1.1'), isTrue);
      expect(isPublicIpv4('203.0.113.5'), isTrue);
    });

    test('rejects private, loopback and link-local space', () {
      expect(isPublicIpv4('10.0.0.1'), isFalse);
      expect(isPublicIpv4('192.168.1.1'), isFalse);
      expect(isPublicIpv4('127.0.0.1'), isFalse);
      expect(isPublicIpv4('169.254.1.1'), isFalse);
    });

    test('rejects the 0/8 block and multicast upwards', () {
      expect(isPublicIpv4('0.0.0.0'), isFalse);
      expect(isPublicIpv4('224.0.0.1'), isFalse);
      expect(isPublicIpv4('255.255.255.255'), isFalse);
    });

    test(
      'is the complement of private and loopback for ordinary addresses',
      () {
        const addresses = ['8.8.8.8', '10.0.0.1', '127.0.0.1', '192.168.0.1'];

        for (final address in addresses) {
          final classified =
              isPublicIpv4(address) ||
              isPrivateIpv4(address) ||
              isLoopbackIpv4(address);
          expect(classified, isTrue, reason: '$address should be classified');
        }
      },
    );
  });

  group('isHostname', () {
    test('accepts single labels and dotted names', () {
      expect(isHostname('localhost'), isTrue);
      expect(isHostname('example.com'), isTrue);
      expect(isHostname('sub.domain.example.com'), isTrue);
      expect(isHostname('example.com.'), isTrue);
      expect(isHostname('a1-b2.example'), isTrue);
    });

    test('does not require a TLD, unlike isFQDN', () {
      expect(isHostname('localhost'), isTrue);
      expect(isFQDN('localhost'), isFalse);
    });

    test('rejects empty labels and hyphen placement', () {
      expect(isHostname(''), isFalse);
      expect(isHostname('.'), isFalse);
      expect(isHostname('a..b'), isFalse);
      expect(isHostname('-example.com'), isFalse);
      expect(isHostname('example-.com'), isFalse);
    });

    test('rejects a name that is too long', () {
      final tooLong = List.filled(64, 'a').join();

      expect(isHostname('$tooLong.com'), isFalse);
    });
  });

  group('fluent extensions for the new identifier and network predicates', () {
    test('mirror the top-level functions', () {
      expect('GB82 WEST 1234 5698 7654 32'.isIban, isTrue);
      expect('DEUTDEFF'.isBic, isTrue);
      expect('10.0.0.1'.isPrivateIpv4, isTrue);
      expect('127.0.0.1'.isLoopbackIpv4, isTrue);
      expect('8.8.8.8'.isPublicIpv4, isTrue);
      expect('localhost'.isHostname, isTrue);
    });
  });
}
