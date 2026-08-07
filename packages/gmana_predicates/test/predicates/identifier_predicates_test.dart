import 'package:gmana_predicates/gmana_predicates.dart';
import 'package:test/test.dart';

void main() {
  group('identifier_predicates', () {
    test('isUuid validates UUID v4 and other versions', () {
      expect(isUuid('f47ac10b-58cc-4372-a567-0e02b2c3d479'), isTrue);
      expect(isUuid('invalid-uuid'), isFalse);
      expect(isUuid(null), isFalse);
    });

    test('isSemVer validates semantic versions', () {
      expect(isSemVer('1.0.0'), isTrue);
      expect(isSemVer('2.1.0-alpha.1'), isTrue);
      expect(isSemVer('3.0.0+build.12'), isTrue);
      expect(isSemVer('1.0'), isFalse);
      expect(isSemVer('v1.0.0'), isFalse);
    });

    test('isPhoneNumber validates phone digits', () {
      expect(isPhoneNumber('+1 (415) 555-2671'), isTrue);
      expect(isPhoneNumber('14155552671'), isTrue);
      expect(isPhoneNumber('14155552671', requirePlusPrefix: true), isFalse);
      expect(isPhoneNumber('123'), isFalse);
    });

    test('isLuhnValid validates Luhn algorithm', () {
      expect(isLuhnValid('79927398713'), isTrue);
      expect(isLuhnValid('79927398714'), isFalse);
    });

    test('isIMEI validates 15-digit IMEI with Luhn', () {
      expect(isIMEI('490154203237518'), isTrue);
      expect(isIMEI('490154203237519'), isFalse);
      expect(isIMEI('12345'), isFalse);
    });

    test('isEAN validates EAN-8 and EAN-13 barcodes', () {
      expect(isEAN('90311017', '8'), isTrue);
      expect(isEAN('90311018', '8'), isFalse);

      expect(isEAN('4006381333931', '13'), isTrue);
      expect(isEAN('4006381333932', '13'), isFalse);
      expect(isEAN('4006381333931'), isTrue);
    });

    test('isULID validates 26-character Crockford Base32 ULID', () {
      expect(isULID('01ARZ3NDEKTSV4RRFFQ69G5FAV'), isTrue);
      expect(isULID('01arz3ndektsv4rrffq69g5fav'), isTrue);
      expect(isULID('INVALIDULIDSTRING'), isFalse);
    });

    test('isNanoId validates Nano ID format and length', () {
      expect(isNanoId('V1StGXR8_Z5jdHi6B-myT'), isTrue);
      expect(isNanoId('short', 5), isTrue);
      expect(isNanoId('invalid!char!', 12), isFalse);
    });
  });
}
