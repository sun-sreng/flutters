import 'package:gmana/is/is_alpha.dart' as v_alpha;
import 'package:gmana/is/is_alpha_numeric.dart' as v_alphanumeric;
import 'package:gmana/is/is_credit_card.dart' as v_credit_card;
import 'package:gmana/is/is_email.dart' as v_email;
import 'package:gmana/is/is_hex_color.dart' as v_hex_color;
import 'package:gmana/is/is_numeric.dart' as v_numeric;
import 'package:gmana/is/is_uuid.dart' as v_uuid;

/// Represents the strength grading of a given password.
class PasswordStrength {
  /// Whether the password meets the minimum length requirement.
  final bool hasMinLength;

  /// Whether the password contains at least one uppercase letter.
  final bool hasUppercase;

  /// Whether the password contains at least one lowercase letter.
  final bool hasLowercase;

  /// Whether the password contains at least one digit.
  final bool hasDigit;

  /// Whether the password contains at least one special character.
  final bool hasSpecial;

  /// Constructs a [PasswordStrength] instance.
  const PasswordStrength({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecial,
  });

  /// Returns true if all password strength criterion are satisfied.
  bool get isStrong =>
      hasMinLength && hasUppercase && hasLowercase && hasDigit && hasSpecial;

  /// 0–5 score, useful for a strength indicator bar.
  int get score =>
      [
        hasMinLength,
        hasUppercase,
        hasLowercase,
        hasDigit,
        hasSpecial,
      ].where((v) => v).length;

  /// Returns a list of strings detailing which requirements have not yet been met.
  List<String> get unmetRequirements => [
    if (!hasMinLength) 'At least 8 characters',
    if (!hasUppercase) 'One uppercase letter',
    if (!hasLowercase) 'One lowercase letter',
    if (!hasDigit) 'One number',
    if (!hasSpecial) 'One special character',
  ];
}

// ─── Supporting type ──────────────────────────────────────────────────────────

/// A vast collection of validation utilities mapped as getters on [String].
extension StringValidation on String {
  // ─── Email ────────────────────────────────────────────────────────────────

  /// Checks if the string contains only alphabetic characters.
  bool get isAlpha => v_alpha.isAlpha(this);

  // ─── Name ─────────────────────────────────────────────────────────────────

  /// Checks if the string contains only alphanumeric characters.
  bool get isAlphanumeric => v_alphanumeric.isAlphaNumeric(this);

  // ─── Password ─────────────────────────────────────────────────────────────

  /// Checks if the string is empty or contains only whitespace.
  bool get isBlank => trim().isEmpty;

  /// Checks if the string contains at least one non-whitespace character.
  bool get isNotBlank => trim().isNotEmpty;

  // ─── Phone ────────────────────────────────────────────────────────────────

  /// Checks if the string contains only numeric digits.
  bool get isNumeric => v_numeric.isNumeric(this);

  /// Checks if the string is a valid credit card number using the Luhn algorithm.
  bool get isValidCreditCard => v_credit_card.isCreditCard(this);

  // ─── General purpose ──────────────────────────────────────────────────────

  /// Validates against E.164 format: `+` followed by 7–15 digits, no spaces.
  bool get isValidE164Phone {
    return RegExp(r'^\+\d{7,15}$').hasMatch(this);
  }

  /// RFC-5321-aligned. Handles subdomains, hyphens, multi-part TLDs.
  /// Still a heuristic — true validation requires sending a mail.
  bool get isValidEmail => v_email.isEmail(trim());

  /// Checks if the string is a valid hexadecimal color mapping (e.g. #FFF or #FFFFFF).
  bool get isValidHexColor => v_hex_color.isHexColor(this);

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
    return DateTime.tryParse(this) != null;
  }

  /// Accepts Unicode letters, spaces, hyphens, apostrophes, periods.
  /// Single names (mononyms) are valid. Max 100 chars guards against abuse.
  bool get isValidName {
    final s = trim();
    if (s.isEmpty || s.length > 100) return false;
    // Unicode letter categories + common name punctuation
    final re = RegExp(r"^[\p{L}\p{M}' .\-]+$", unicode: true);
    return re.hasMatch(s);
  }

  /// At least 8 chars, one uppercase, one lowercase, one digit,
  /// one non-alphanumeric character (any — not a fixed whitelist).
  bool get isValidPassword {
    if (length < 8) return false;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(this);
    final hasLower = RegExp(r'[a-z]').hasMatch(this);
    final hasDigit = RegExp(r'\d').hasMatch(this);
    final hasSpecial = RegExp(r'[^A-Za-z\d]').hasMatch(this);
    return hasUpper && hasLower && hasDigit && hasSpecial;
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
    return RegExp(
      r'^https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&'
      "'()*+,;=%]+\$",
    ).hasMatch(trim());
  }

  /// Checks if the string is a valid UUID (v4).
  bool get isValidUuid => v_uuid.isUuid(this, '4');

  /// Returns which password requirements are unmet — useful for live UI feedback.
  PasswordStrength get passwordStrength {
    return PasswordStrength(
      hasMinLength: length >= 8,
      hasUppercase: RegExp(r'[A-Z]').hasMatch(this),
      hasLowercase: RegExp(r'[a-z]').hasMatch(this),
      hasDigit: RegExp(r'\d').hasMatch(this),
      hasSpecial: RegExp(r'[^A-Za-z\d]').hasMatch(this),
    );
  }

  /// Length bounded — prevents silent acceptance of huge inputs.
  bool isWithinLength({required int min, required int max}) =>
      length >= min && length <= max;
}
