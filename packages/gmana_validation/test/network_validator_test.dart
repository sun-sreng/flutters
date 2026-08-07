import 'package:gmana_validation/gmana_validation.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkValidator', () {
    test('validates IPv4 and IPv6 addresses', () {
      const v4 = NetworkValidator(
        NetworkValidationConfig(requiredType: NetworkAddressType.ipv4),
      );

      final valid = v4.validate('192.168.1.1');
      final invalid = v4.validate('256.0.0.1');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<NetworkInvalidIpIssue>());
    });

    test('validates CIDR block notation', () {
      const cidr = NetworkValidator(
        NetworkValidationConfig(requiredType: NetworkAddressType.cidr),
      );

      final valid = cidr.validate('192.168.1.0/24');
      final invalid = cidr.validate('192.168.1.0/35');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<NetworkInvalidCidrIssue>());
    });

    test('validates network Port numbers', () {
      const port = NetworkValidator(
        NetworkValidationConfig(requiredType: NetworkAddressType.port),
      );

      final valid = port.validate('8080');
      final invalid = port.validate('70000');

      expect(valid.isRight(), isTrue);
      expect(invalid.isLeft(), isTrue);
      expect(invalid.leftOrNull(), isA<NetworkInvalidPortIssue>());
    });

  });
}
