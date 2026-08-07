import '../annotations.dart';
import '../src/regex/identifier_patterns.dart';
import 'string_predicates.dart';

/// Returns `true` if [str] is a valid UUID (any version by default).
///
/// Pass [version] as `'3'`, `'4'`, or `'5'` to match a specific version.
/// Returns `false` if [str] is `null`.
bool isUuid(String? str, [String? version]) {
  if (str == null) return false;
  final v = version ?? 'all';
  final pat = uuidReg[v];
  return pat != null && pat.hasMatch(str.toUpperCase());
}

/// Returns `true` if [str] is a valid credit card number (Luhn check).
bool isCreditCard(String str) {
  final sanitized = str.replaceAll(RegExp('[^0-9]+'), '');
  if (!creditCardReg.hasMatch(sanitized)) return false;

  var sum = 0;
  var shouldDouble = false;

  for (var i = sanitized.length - 1; i >= 0; i--) {
    var tmpNum = int.parse(sanitized[i]);

    if (shouldDouble) {
      tmpNum *= 2;
      if (tmpNum >= 10) {
        sum += (tmpNum % 10) + 1;
      } else {
        sum += tmpNum;
      }
    } else {
      sum += tmpNum;
    }
    shouldDouble = !shouldDouble;
  }

  return sum % 10 == 0;
}

/// Returns `true` if [str] is a valid ISBN-10 or ISBN-13.
///
/// Pass [version] as `'10'` or `'13'` to check a specific standard.
/// Returns `false` if [str] is `null`.
@experimental
bool isISBN(String? str, [String? version]) {
  if (str == null) return false;
  if (version == null) return isISBN(str, '10') || isISBN(str, '13');

  final sanitized = str.replaceAll(RegExp(r'[\s-]+'), '');
  var checksum = 0;

  if (version == '10') {
    if (!isbn10MaybeReg.hasMatch(sanitized)) return false;
    for (var i = 0; i < 9; i++) {
      checksum += (i + 1) * int.parse(sanitized[i]);
    }
    checksum += sanitized[9] == 'X' ? 100 : 10 * int.parse(sanitized[9]);
    return checksum % 11 == 0;
  } else if (version == '13') {
    if (!isbn13MaybeReg.hasMatch(sanitized)) return false;
    const factor = [1, 3];
    for (var i = 0; i < 12; i++) {
      checksum += factor[i % 2] * int.parse(sanitized[i]);
    }
    return int.parse(sanitized[12]) - ((10 - (checksum % 10)) % 10) == 0;
  }

  return false;
}

/// Returns `true` if [str] is a valid 24-character MongoDB ObjectId (hex).
@experimental
bool isMongoId(String str) => isHexadecimal(str) && str.length == 24;

/// Returns `true` if [str] is a valid fully-qualified domain name.
@experimental
bool isFQDN(
  String str, {
  bool requireTld = true,
  bool allowUnderscores = false,
}) {
  final parts = str.split('.');

  if (requireTld) {
    final tld = parts.removeLast();
    if (parts.isEmpty || !fqdnTldReg.hasMatch(tld)) return false;
  }

  for (final part in parts) {
    if (allowUnderscores && part.contains('__')) return false;
    if (!fqdnLabelReg.hasMatch(part)) return false;
    if (part.startsWith('-') || part.endsWith('-') || part.contains('---')) {
      return false;
    }
  }

  return true;
}

/// Returns `true` if [str] is a valid Semantic Versioning string (e.g. `1.0.0`, `2.1.0-alpha.1`, `3.0.0+build.1`).
bool isSemVer(String str) {
  final semVerRegExp = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
  );
  return semVerRegExp.hasMatch(str);
}

/// Returns `true` if [str] is a valid phone number.
bool isPhoneNumber(String str, {bool requirePlusPrefix = false}) {
  final trimmed = str.trim();
  if (trimmed.isEmpty) return false;
  if (requirePlusPrefix && !trimmed.startsWith('+')) return false;

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 7 && digits.length <= 15;
}

/// Returns `true` if [str] passes the Luhn checksum algorithm.
bool isLuhnValid(String str) {
  final sanitized = str.replaceAll(RegExp(r'\D'), '');
  if (sanitized.isEmpty) return false;

  var sum = 0;
  var shouldDouble = false;

  for (var i = sanitized.length - 1; i >= 0; i--) {
    var digit = int.parse(sanitized[i]);
    if (shouldDouble) {
      digit *= 2;
      if (digit >= 10) digit -= 9;
    }
    sum += digit;
    shouldDouble = !shouldDouble;
  }
  return sum % 10 == 0;
}

/// Returns `true` if [str] is a valid 15-digit International Mobile Equipment Identity (IMEI) number.
bool isIMEI(String str) {
  final sanitized = str.replaceAll(RegExp(r'[\s-]+'), '');
  if (!imeiMaybeReg.hasMatch(sanitized)) return false;
  return isLuhnValid(sanitized);
}

/// Returns `true` if [str] is a valid EAN-8 or EAN-13 barcode number with valid checksum.
///
/// Pass [version] as `'8'` or `'13'` to check a specific length standard.
bool isEAN(String str, [String? version]) {
  final sanitized = str.replaceAll(RegExp(r'[\s-]+'), '');
  if (version == '8') {
    if (!ean8MaybeReg.hasMatch(sanitized)) return false;
    return _validateEanChecksum(sanitized);
  } else if (version == '13') {
    if (!ean13MaybeReg.hasMatch(sanitized)) return false;
    return _validateEanChecksum(sanitized);
  } else if (version == null) {
    return isEAN(str, '8') || isEAN(str, '13');
  }
  return false;
}

bool _validateEanChecksum(String ean) {
  var sum = 0;
  final length = ean.length;
  for (var i = 0; i < length - 1; i++) {
    final digit = int.parse(ean[i]);
    final weight = (length - 1 - i) % 2 == 1 ? 3 : 1;
    sum += digit * weight;
  }
  final checkDigit = (10 - (sum % 10)) % 10;
  return checkDigit == int.parse(ean[length - 1]);
}

/// Returns `true` if [str] is a valid 26-character Universally Unique Lexicographically Sortable Identifier (ULID).
bool isULID(String str) => ulidReg.hasMatch(str);

/// Returns `true` if [str] matches a Nano ID format of length [expectedLength] (default: 21).
bool isNanoId(String str, [int expectedLength = 21]) {
  if (str.length != expectedLength) return false;
  return RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(str);
}

