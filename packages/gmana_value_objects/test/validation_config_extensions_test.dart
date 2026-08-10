import 'package:gmana_value_objects/gmana_value_objects.dart';
import 'package:test/test.dart';

void main() {
  group('validation config copyWith extensions', () {
    test('Phone keeps omitted fields and replaces provided fields', () {
      const original = PhoneValidationConfig(
        requirePlusPrefix: true,
        minDigits: 9,
        maxDigits: 14,
      );

      expect(original.copyWith(), original);

      final changed = original.copyWith(minDigits: 10, maxDigits: 12);
      expect(changed.requirePlusPrefix, isTrue);
      expect(changed.minDigits, 10);
      expect(changed.maxDigits, 12);
    });

    test('URL keeps omitted fields and replaces provided fields', () {
      const original = UrlValidationConfig(
        allowedSchemes: {'https', 'wss'},
        requireHost: true,
      );

      expect(original.copyWith(), original);

      final changed = original.copyWith(
        allowedSchemes: const {'file'},
        requireHost: false,
      );
      expect(changed.allowedSchemes, {'file'});
      expect(changed.requireHost, isFalse);
    });

    test('Identifier keeps omitted fields and replaces provided fields', () {
      const original = IdentifierValidationConfig(
        uuidVersion: '4',
        eanVersion: '13',
      );

      final changed = original.copyWith(
        allowEmpty: true,
        trimWhitespace: false,
        requiredType: IdentifierType.nanoId,
        nanoIdLength: 12,
      );
      expect(changed.allowEmpty, isTrue);
      expect(changed.trimWhitespace, isFalse);
      expect(changed.requiredType, IdentifierType.nanoId);
      expect(changed.uuidVersion, '4');
      expect(changed.eanVersion, '13');
      expect(changed.nanoIdLength, 12);
    });

    test('Identifier nullable versions can be explicitly cleared', () {
      const original = IdentifierValidationConfig(
        requiredType: IdentifierType.uuid,
        uuidVersion: '4',
        eanVersion: '13',
      );

      final cleared = original.copyWith(uuidVersion: null, eanVersion: null);
      expect(cleared.requiredType, IdentifierType.uuid);
      expect(cleared.uuidVersion, isNull);
      expect(cleared.eanVersion, isNull);
    });

    test('Network keeps omitted fields and replaces provided fields', () {
      const original = NetworkValidationConfig(
        requiredType: NetworkAddressType.cidr,
        ipVersion: 4,
      );

      final changed = original.copyWith(
        allowEmpty: true,
        trimWhitespace: false,
        requiredType: NetworkAddressType.ip,
      );
      expect(changed.allowEmpty, isTrue);
      expect(changed.trimWhitespace, isFalse);
      expect(changed.requiredType, NetworkAddressType.ip);
      expect(changed.ipVersion, 4);
    });

    test('Network IP version can be explicitly cleared', () {
      const original = NetworkValidationConfig(
        requiredType: NetworkAddressType.cidr,
        ipVersion: 6,
      );

      final cleared = original.copyWith(ipVersion: null);
      expect(cleared.requiredType, NetworkAddressType.cidr);
      expect(cleared.ipVersion, isNull);
    });

    test('all copyWith APIs are exported as named extensions', () {
      expect(
        GmanaPhoneValidationConfigX(
          const PhoneValidationConfig(),
        ).copyWith(minDigits: 8).minDigits,
        8,
      );
      expect(
        GmanaUrlValidationConfigX(
          const UrlValidationConfig(),
        ).copyWith(requireHost: false).requireHost,
        isFalse,
      );
      expect(
        GmanaIdentifierValidationConfigX(
          const IdentifierValidationConfig(uuidVersion: '4'),
        ).copyWith(uuidVersion: null).uuidVersion,
        isNull,
      );
      expect(
        GmanaNetworkValidationConfigX(
          const NetworkValidationConfig(ipVersion: 4),
        ).copyWith(ipVersion: null).ipVersion,
        isNull,
      );
    });
  });
}
