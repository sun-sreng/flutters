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
      expect(
        isPhoneNumber('14155552671', requirePlusPrefix: true),
        isFalse,
      );
      expect(isPhoneNumber('123'), isFalse);
    });
  });
}
