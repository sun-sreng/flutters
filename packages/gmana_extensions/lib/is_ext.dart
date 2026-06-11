import 'package:gmana_predicates/predicates/identifier_predicates.dart' as id_preds;
import 'package:gmana_predicates/predicates/string_predicates.dart' as preds;
import 'package:gmana_validation/gmana_validation.dart';

export 'package:gmana_validation/gmana_validation.dart'
    show PasswordStrength, PasswordValidationConfig, PasswordValidator;

/// A vast collection of validation utilities mapped as getters on [String].
extension StringValidation on String {
  /// Checks if the string is a valid credit card number using the Luhn algorithm.
  bool get isValidCreditCard => id_preds.isCreditCard(this);

  /// Validates against E.164 format: `+` followed by 7–15 digits, no spaces.
  bool get isValidE164Phone {
    return RegExp(r'^\+\d{7,15}$').hasMatch(this);
  }

  /// RFC-5321-aligned. Handles subdomains, hyphens, multi-part TLDs.
  /// Still a heuristic — true validation requires sending a mail.
  bool get isValidEmail => const EmailValidator().validate(this).isRight();

  /// Checks if the string is a valid hexadecimal color (e.g. #FFF or #FFFFFF).
  bool get isValidHexColor => preds.isHexColor(this);

  /// Checks if the string is a valid IPv4 address.
  bool get isValidIpv4 {
    final parts = split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255 && p == n.toString();
    });
  }

  /// ISO 8601 date only: `2024-01-31`
  bool get isValidIsoDate {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(this)) return false;
    final year = int.parse(substring(0, 4));
    final month = int.parse(substring(5, 7));
    final day = int.parse(substring(8, 10));
    final parsed = DateTime.tryParse(this);
    return parsed != null && parsed.year == year && parsed.month == month && parsed.day == day;
  }

  /// Accepts Unicode letters, spaces, hyphens, apostrophes, periods.
  /// Single names (mononyms) are valid. Max 100 chars guards against abuse.
  bool get isValidName {
    final s = trim();
    if (s.isEmpty || s.length > 100) return false;
    final re = RegExp(r"^[\p{L}\p{M}' .\-]+$", unicode: true);
    final hasLetter = RegExp(r'\p{L}', unicode: true).hasMatch(s);
    return hasLetter && re.hasMatch(s);
  }

  /// At least 8 chars, one uppercase, one lowercase, one digit,
  /// one non-alphanumeric character (any — not a fixed whitelist).
  bool get isValidPassword {
    return const PasswordValidator().validate(this).isRight();
  }

  /// Strips formatting then checks for 7–15 digits (ITU-T E.164 range).
  /// Does NOT enforce country-specific formats — use a package like
  /// `phone_numbers_parser` when you need locale validation.
  bool get isValidPhone {
    final digits = replaceAll(RegExp(r'[\s\-().+]'), '');
    if (digits.isEmpty) return false;
    return RegExp(r'^\d{7,15}$').hasMatch(digits);
  }

  /// Valid URL (http/https). Intentionally simple — use `Uri.tryParse`
  /// for structural checks; this validates the common displayed format.
  bool get isValidUrl {
    final uri = Uri.tryParse(trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  /// Checks if the string is a valid UUID (v4).
  bool get isValidUuid => id_preds.isUuid(this, '4');

  /// Returns which password requirements are unmet — useful for live UI feedback.
  PasswordStrength get passwordStrength => PasswordStrength.fromConfig(this, const PasswordValidationConfig());

  /// Length bounded — prevents silent acceptance of huge inputs.
  bool isWithinLength({required int min, required int max}) => length >= min && length <= max;
}
