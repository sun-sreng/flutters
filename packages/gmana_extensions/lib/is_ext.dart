import 'dart:convert';

import 'package:gmana_predicates/predicates/identifier_predicates.dart'
    as id_preds;
import 'package:gmana_predicates/predicates/string_predicates.dart' as preds;
import 'package:gmana_validation/gmana_validation.dart';

export 'package:gmana_validation/gmana_validation.dart'
    show PasswordStrength, PasswordValidationConfig, PasswordValidator;

/// A vast collection of validation utilities mapped as getters on [String].
extension StringValidation on String {
  /// Checks whether the string is valid Base64 or Base64URL text.
  ///
  /// Missing padding is accepted.
  bool get isValidBase64 {
    final s = trim();
    if (s.isEmpty || !RegExp(r'^[A-Za-z0-9+/_-]*={0,2}$').hasMatch(s)) {
      return false;
    }

    try {
      final normalized = base64.normalize(
        s.replaceAll('-', '+').replaceAll('_', '/'),
      );
      base64Decode(normalized);
      return true;
    } on FormatException {
      return false;
    }
  }

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
    final parts = trim().split('.');
    if (parts.length != 4) return false;
    return parts.every((p) {
      final n = int.tryParse(p);
      return n != null && n >= 0 && n <= 255 && p == n.toString();
    });
  }

  /// Checks if the string is a valid IPv6 address.
  bool get isValidIpv6 {
    final s = trim();
    if (!s.contains(':')) return false;

    try {
      Uri.parseIPv6Address(s);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// Checks if the string is a valid IPv4 or IPv6 address.
  bool get isValidIpAddress => isValidIpv4 || isValidIpv6;

  /// ISO 8601 date only: `2024-01-31`
  bool get isValidIsoDate {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(this)) return false;
    final year = int.parse(substring(0, 4));
    final month = int.parse(substring(5, 7));
    final day = int.parse(substring(8, 10));
    final parsed = DateTime.tryParse(this);
    return parsed != null &&
        parsed.year == year &&
        parsed.month == month &&
        parsed.day == day;
  }

  /// Checks if the string looks like a JSON Web Token (`header.payload.signature`).
  ///
  /// This validates structure and Base64URL-encoded header/payload segments. It
  /// does not verify the signature or claims.
  bool get isValidJwt {
    final parts = trim().split('.');
    if (parts.length != 3 || parts.any((part) => part.isEmpty)) return false;
    return parts[0].isValidBase64 &&
        parts[1].isValidBase64 &&
        RegExp(r'^[A-Za-z0-9_-]*$').hasMatch(parts[2]);
  }

  /// Checks if the string is a valid MAC address.
  ///
  /// Accepts colon, hyphen, and dotted Cisco-style notation.
  bool get isValidMacAddress {
    final s = trim();
    return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$').hasMatch(s) ||
        RegExp(r'^[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}\.[0-9A-Fa-f]{4}$').hasMatch(s);
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

  /// Checks if the string is a URL-safe slug.
  ///
  /// Accepts lowercase letters, numbers, and single hyphens between tokens.
  bool get isValidSlug =>
      RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(trim());

  /// Valid URL (http/https). Intentionally simple — use `Uri.tryParse`
  /// for structural checks; this validates the common displayed format.
  bool get isValidUrl {
    final uri = Uri.tryParse(trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  /// Checks if the string is a valid UUID (v4).
  bool get isValidUuid => id_preds.isUuid(this, '4');

  /// Checks if the string is any valid UUID version 1 through 5.
  bool get isValidUuidAny => RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  ).hasMatch(trim());

  /// Returns which password requirements are unmet — useful for live UI feedback.
  PasswordStrength get passwordStrength =>
      PasswordStrength.fromConfig(this, const PasswordValidationConfig());

  /// Length bounded — prevents silent acceptance of huge inputs.
  bool isWithinLength({required int min, required int max}) {
    if (min < 0) {
      throw ArgumentError.value(min, 'min', 'must not be negative');
    }
    if (max < min) {
      throw ArgumentError.value(
        max,
        'max',
        'must be greater than or equal to min',
      );
    }

    return length >= min && length <= max;
  }

  /// Checks if the string is a conventional username.
  ///
  /// Allows letters, numbers, underscores, and dots. The first and last
  /// character must be alphanumeric.
  bool isValidUsername({int min = 3, int max = 32}) {
    if (min < 1) {
      throw ArgumentError.value(min, 'min', 'must be greater than zero');
    }
    if (max < min) {
      throw ArgumentError.value(
        max,
        'max',
        'must be greater than or equal to min',
      );
    }

    final s = trim();
    if (s.length < min || s.length > max) return false;
    return RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9._]*[A-Za-z0-9])?$').hasMatch(s);
  }
}
