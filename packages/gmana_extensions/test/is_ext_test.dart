import 'package:gmana_extensions/gmana_extensions.dart';
import 'package:test/test.dart';

void main() {
  // The extension itself is tested in gmana_validation, where it is declared.
  test('StringValidation is still exported from gmana_extensions', () {
    expect('user@example.com'.isValidEmail, isTrue);
    expect(StringValidation('not an email').isValidEmail, isFalse);
    expect('192.168.0.1'.isValidIpv4, isTrue);
    expect('weak'.passwordStrength, isA<PasswordStrength>());
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

    test('isAlphanumeric returns true for alphanumeric strings', () {
      expect('abc123'.isAlphanumeric, isTrue);
      expect('abc123!'.isAlphanumeric, isFalse);
    });
  });
}
