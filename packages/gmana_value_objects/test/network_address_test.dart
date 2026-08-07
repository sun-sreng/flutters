import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('NetworkAddressValue', () {
    test('parses valid IPv4 address', () {
      const config = NetworkValidationConfig(requiredType: NetworkAddressType.ipv4);
      final result = NetworkAddressValue.tryParse('192.168.1.1', config: config);

      expect(result.isRight(), isTrue);
      expect(result.rightOrNull()?.value, equals('192.168.1.1'));
    });

    test('rejects invalid IP address', () {
      const config = NetworkValidationConfig(requiredType: NetworkAddressType.ipv4);
      final result = NetworkAddressValue.tryParse('256.0.0.1', config: config);

      expect(result.isLeft(), isTrue);
      expect(result.leftOrNull(), isA<NetworkAddressInvalidIp>());
    });

    test('constructor throws ValueObjectException on invalid port', () {
      expect(
        () => NetworkAddressValue('70000', config: const NetworkValidationConfig(requiredType: NetworkAddressType.port)),
        throwsA(isA<ValueObjectException>()),
      );
    });
  });
}
