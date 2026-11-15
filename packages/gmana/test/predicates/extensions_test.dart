import 'package:gmana/predicates.dart';
import 'package:test/test.dart';

void main() {
  group('fluent predicate extensions', () {
    test('String? extensions', () {
      String? nullStr;
      String? emptyStr = '';
      String? blankStr = '   ';
      String? textStr = 'user@example.com';

      expect(nullStr.isNullOrEmpty, isTrue);
      expect(nullStr.isBlank, isTrue);
      expect(nullStr.isNotBlank, isFalse);

      expect(emptyStr.isNullOrEmpty, isTrue);
      expect(blankStr.isBlank, isTrue);

      expect(textStr.isNotBlank, isTrue);
      expect(textStr.isEmail, isTrue);
    });

    test('String extensions', () {
      expect('user@example.com'.isEmail, isTrue);
      expect('12345'.isInt, isTrue);
      expect('42'.isEven, isTrue);
      expect('42'.isOdd, isFalse);
      expect('15.5'.isPositive, isTrue);
      expect('7'.isPrimeString, isTrue);
      expect('192.168.1.1'.isIpv4, isTrue);
      expect('192.168.1.0/24'.isCidr(), isTrue);
      expect('racecar'.isPalindrome(), isTrue);
      expect('camelCaseStr'.isCamelCase, isTrue);
      expect('01ARZ3NDEKTSV4RRFFQ69G5FAV'.isULID, isTrue);
      expect('2026-08-07T00:00:00Z'.isDate, isTrue);
    });
  });
}
