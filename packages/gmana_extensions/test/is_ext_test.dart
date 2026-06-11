import 'package:test/test.dart';
import 'package:gmana_extensions/gmana_extensions.dart';

void main() {
  group('StringValidation Extension', () {
    group('Email Validation', () {
      test('isValidEmail returns true for valid emails', () {
        expect('test@example.com'.isValidEmail, isTrue);
        expect('user.name+tag@sub.example.com'.isValidEmail, isTrue);
        expect(' valid@email.com '.isValidEmail, isTrue); // Trims
      });

      test('isValidEmail returns false for invalid emails', () {
        expect('invalid-email'.isValidEmail, isFalse);
        expect('@example.com'.isValidEmail, isFalse);
        expect('test@.com'.isValidEmail, isFalse);
      });
    });

    group('Name Validation', () {
      test('isValidName returns true for valid names', () {
        expect('John Doe'.isValidName, isTrue);
        expect('O\'Brian'.isValidName, isTrue);
        expect('Jane-Doe'.isValidName, isTrue);
        expect('Sr. Maria'.isValidName, isTrue);
        expect('José'.isValidName, isTrue);
      });

      test(
        'isValidName returns false for invalid names or empty/long names',
        () {
          expect(''.isValidName, isFalse);
          expect('John123'.isValidName, isFalse); // Numbers not allowed
          expect(
            'John!'.isValidName,
            isFalse,
          ); // Special characters not allowed
          expect(('a' * 101).isValidName, isFalse); // Over 100 characters
          expect('...'.isValidName, isFalse);
          expect(' - '.isValidName, isFalse);
        },
      );
    });

    group('Password Validation', () {
      test('isValidPassword returns true when all rules are met', () {
        expect('StrongP@ssw0rd'.isValidPassword, isTrue);
      });

      test('isValidPassword returns false if rules are unmet', () {
        expect('weak'.isValidPassword, isFalse); // Too short
        expect('alllowercase1#'.isValidPassword, isFalse); // No uppercase
        expect('ALLUPPERCASE1#'.isValidPassword, isFalse); // No lowercase
        expect('NoDigitsHere!'.isValidPassword, isFalse); // No digit
        expect('NoSpecialChar123'.isValidPassword, isFalse); // No special char
      });

      test('passwordStrength returns correct PasswordStrength', () {
        final strength = 'Str0ng!'.passwordStrength; // length 7 (not 8)
        expect(strength.hasMinLength, isFalse);
        expect(strength.hasUppercase, isTrue);
        expect(strength.hasLowercase, isTrue);
        expect(strength.hasDigit, isTrue);
        expect(strength.hasSpecial, isTrue);
        expect(strength.isStrong, isFalse);
        expect(strength.score, 4);
        expect(strength.unmetRequirements, contains('At least 8 characters'));
      });

      test('passwordStrength reports a strong password', () {
        final strength = 'Str0ngPass!'.passwordStrength;

        expect(strength.hasMinLength, isTrue);
        expect(strength.hasUppercase, isTrue);
        expect(strength.hasLowercase, isTrue);
        expect(strength.hasDigit, isTrue);
        expect(strength.hasSpecial, isTrue);
        expect(strength.isStrong, isTrue);
        expect(strength.score, 5);
        expect(strength.unmetRequirements, isEmpty);
      });
    });

    group('Phone Validation', () {
      test('isValidPhone returns true for valid phone formats', () {
        expect('1234567'.isValidPhone, isTrue);
        expect('123-456-7890'.isValidPhone, isTrue);
        expect('+1 (123) 456-7890'.isValidPhone, isTrue);
      });

      test('isValidPhone returns false for invalid phone formats', () {
        expect('123'.isValidPhone, isFalse); // Too short
        expect('1234567890123456'.isValidPhone, isFalse); // Too long
        expect('phone1234567'.isValidPhone, isFalse); // Letters
        expect('123/4567'.isValidPhone, isFalse);
      });

      test('isValidE164Phone returns true for valid E.164 formats', () {
        expect('+1234567890'.isValidE164Phone, isTrue);
      });

      test('isValidE164Phone returns false for invalid E.164 formats', () {
        expect('1234567890'.isValidE164Phone, isFalse); // Missing +
        expect('+1 (234) 567'.isValidE164Phone, isFalse); // Spaces
        expect('+123'.isValidE164Phone, isFalse); // Too short
      });
    });

    group('General Purpose Validations', () {
      test('isValidBase64 returns true for Base64 and Base64URL strings', () {
        expect('aGVsbG8='.isValidBase64, isTrue);
        expect('aGVsbG8'.isValidBase64, isTrue);
        expect('eyJhbGciOiJIUzI1NiJ9'.isValidBase64, isTrue);
        expect('not base64!'.isValidBase64, isFalse);
        expect(''.isValidBase64, isFalse);
      });

      test('isBlank returns true for empty or whitespace strings', () {
        expect(''.isBlank, isTrue);
        expect('   '.isBlank, isTrue);
        expect(' a '.isBlank, isFalse);
      });

      test('isNotBlank returns true for non-whitespace strings', () {
        expect('a'.isNotBlank, isTrue);
        expect(' a '.isNotBlank, isTrue);
        expect('   '.isNotBlank, isFalse);
      });

      test('isNumeric returns true for numeric strings', () {
        expect('12345'.isNumeric, isTrue);
        expect('123a'.isNumeric, isFalse);
      });

      test('isAlpha returns true for alphabetic strings', () {
        expect('abc'.isAlpha, isTrue);
        expect('abc1'.isAlpha, isFalse);
      });

      test('isAlphanumeric returns true for alphanumeric strings', () {
        expect('abc123'.isAlphanumeric, isTrue);
        expect('abc123!'.isAlphanumeric, isFalse);
      });

      test('isValidUrl returns true for valid HTTP/HTTPS URLs', () {
        expect('http://example.com'.isValidUrl, isTrue);
        expect('https://example.com/path?query=1'.isValidUrl, isTrue);
        expect('ftp://example.com'.isValidUrl, isFalse);
        expect('https://'.isValidUrl, isFalse);
        expect('example.com'.isValidUrl, isFalse);
      });

      test('isValidUuid returns true for valid v4 UUIDs', () {
        expect('f47ac10b-58cc-4372-a567-0e02b2c3d479'.isValidUuid, isTrue);
        expect('invalid-uuid'.isValidUuid, isFalse);
        expect('550e8400-e29b-11d4-a716-446655440000'.isValidUuid, isFalse);
      });

      test('isValidIsoDate returns true for valid YYYY-MM-DD dates', () {
        expect('2024-01-31'.isValidIsoDate, isTrue);
        expect('2024-02-29'.isValidIsoDate, isTrue);
        expect('2024-13-01'.isValidIsoDate, isFalse);
        expect('2024-02-31'.isValidIsoDate, isFalse);
        expect('2023-02-29'.isValidIsoDate, isFalse);
        expect('2024/01/31'.isValidIsoDate, isFalse); // Invalid format
      });

      test('isValidIpv4 returns true for valid IPv4 addresses', () {
        expect('192.168.1.1'.isValidIpv4, isTrue);
        expect('255.255.255.255'.isValidIpv4, isTrue);
        expect(' 192.168.1.1 '.isValidIpv4, isTrue);
        expect('256.1.1.1'.isValidIpv4, isFalse); // Out of range
        expect('192.168.1'.isValidIpv4, isFalse); // Missing part
        expect('192.168.001.1'.isValidIpv4, isFalse); // Leading zero
        expect('192..1.1'.isValidIpv4, isFalse); // Empty part
      });

      test('isValidIpv6 and isValidIpAddress validate IP addresses', () {
        expect('2001:db8::1'.isValidIpv6, isTrue);
        expect('::1'.isValidIpv6, isTrue);
        expect('2001:db8:::1'.isValidIpv6, isFalse);
        expect('192.168.1.1'.isValidIpAddress, isTrue);
        expect('2001:db8::1'.isValidIpAddress, isTrue);
        expect('not-an-ip'.isValidIpAddress, isFalse);
      });

      test('isValidJwt validates JWT shape', () {
        const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMifQ.signature';
        expect(jwt.isValidJwt, isTrue);
        expect('header.payload'.isValidJwt, isFalse);
        expect('bad!.payload.signature'.isValidJwt, isFalse);
        expect('eyJhbGciOiJIUzI1NiJ9..signature'.isValidJwt, isFalse);
      });

      test('isValidMacAddress validates common MAC address formats', () {
        expect('AA:BB:CC:DD:EE:FF'.isValidMacAddress, isTrue);
        expect('aa-bb-cc-dd-ee-ff'.isValidMacAddress, isTrue);
        expect('aabb.ccdd.eeff'.isValidMacAddress, isTrue);
        expect('AA:BB:CC:DD:EE'.isValidMacAddress, isFalse);
        expect('GG:BB:CC:DD:EE:FF'.isValidMacAddress, isFalse);
      });

      test('isValidHexColor returns true for valid hex colors', () {
        expect('#FFF'.isValidHexColor, isTrue);
        expect('#FFFFFF'.isValidHexColor, isTrue);
        expect(
          'FFF'.isValidHexColor,
          isTrue,
        ); // validation allows skipping the #
        expect('ZZZ'.isValidHexColor, isFalse);
      });

      test('isValidCreditCard returns true for valid cards', () {
        expect('4111 1111 1111 1111'.isValidCreditCard, isTrue);
        expect('5555-5555-5555-4444'.isValidCreditCard, isTrue);
        expect('4111 1111 1111 1112'.isValidCreditCard, isFalse);
        expect('not-a-card'.isValidCreditCard, isFalse);
      });

      test('isValidSlug validates URL-safe slugs', () {
        expect('hello-world-2026'.isValidSlug, isTrue);
        expect('hello'.isValidSlug, isTrue);
        expect('Hello-World'.isValidSlug, isFalse);
        expect('-hello'.isValidSlug, isFalse);
        expect('hello--world'.isValidSlug, isFalse);
      });

      test('isValidUuidAny accepts UUID versions 1 through 5', () {
        expect('550e8400-e29b-41d4-a716-446655440000'.isValidUuidAny, isTrue);
        expect('f47ac10b-58cc-4372-a567-0e02b2c3d479'.isValidUuidAny, isTrue);
        expect('550e8400-e29b-61d4-a716-446655440000'.isValidUuidAny, isFalse);
        expect('invalid-uuid'.isValidUuidAny, isFalse);
      });

      test('isWithinLength works correctly', () {
        expect('abc'.isWithinLength(min: 2, max: 4), isTrue);
        expect('a'.isWithinLength(min: 2, max: 4), isFalse);
        expect('abcde'.isWithinLength(min: 2, max: 4), isFalse);
        expect(
          () => 'abc'.isWithinLength(min: -1, max: 4),
          throwsArgumentError,
        );
        expect(() => 'abc'.isWithinLength(min: 4, max: 2), throwsArgumentError);
      });

      test('isValidUsername validates conventional usernames', () {
        expect('sreng.sun'.isValidUsername(), isTrue);
        expect('user_123'.isValidUsername(), isTrue);
        expect('ab'.isValidUsername(), isFalse);
        expect('_user'.isValidUsername(), isFalse);
        expect('user_'.isValidUsername(), isFalse);
        expect('user-name'.isValidUsername(), isFalse);
        expect('ab'.isValidUsername(min: 2), isTrue);
        expect(() => 'abc'.isValidUsername(min: 0), throwsArgumentError);
        expect(
          () => 'abc'.isValidUsername(min: 4, max: 3),
          throwsArgumentError,
        );
      });
    });
  });
}
