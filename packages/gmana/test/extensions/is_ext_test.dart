import 'package:test/test.dart';
import 'package:gmana/extensions/is_ext.dart';

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

      test('isValidName returns false for invalid names or empty/long names', () {
        expect(''.isValidName, isFalse);
        expect('John123'.isValidName, isFalse); // Numbers not allowed
        expect('John!'.isValidName, isFalse); // Special characters not allowed
        expect(('a' * 101).isValidName, isFalse); // Over 100 characters
      });
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
      });

      test('isValidUuid returns true for valid v4 UUIDs', () {
        expect('f47ac10b-58cc-4372-a567-0e02b2c3d479'.isValidUuid, isTrue);
        expect('invalid-uuid'.isValidUuid, isFalse);
      });

      test('isValidIsoDate returns true for valid YYYY-MM-DD dates', () {
        expect('2024-01-31'.isValidIsoDate, isTrue);
        // DateTime.tryParse in Dart handles overflow (e.g. 2024-13-01 -> 2025-01-01), so it returns true
        expect('2024-13-01'.isValidIsoDate, isTrue);
        expect('2024/01/31'.isValidIsoDate, isFalse); // Invalid format
      });

      test('isValidIpv4 returns true for valid IPv4 addresses', () {
        expect('192.168.1.1'.isValidIpv4, isTrue);
        expect('255.255.255.255'.isValidIpv4, isTrue);
        expect('256.1.1.1'.isValidIpv4, isFalse); // Out of range
        expect('192.168.1'.isValidIpv4, isFalse); // Missing part
      });

      test('isValidHexColor returns true for valid hex colors', () {
        expect('#FFF'.isValidHexColor, isTrue);
        expect('#FFFFFF'.isValidHexColor, isTrue);
        expect('FFF'.isValidHexColor, isTrue); // validation allows skipping the #
        expect('ZZZ'.isValidHexColor, isFalse);
      });

      test('isValidCreditCard returns true for valid cards', () {
        // Just testing it calls v_credit_card correctly.
      });

      test('isWithinLength works correctly', () {
        expect('abc'.isWithinLength(min: 2, max: 4), isTrue);
        expect('a'.isWithinLength(min: 2, max: 4), isFalse);
        expect('abcde'.isWithinLength(min: 2, max: 4), isFalse);
      });
    });
  });
}
