import 'dart:convert';

import '../annotations.dart';
import '../src/regex/string_patterns.dart';

/// Returns `true` if [str] contains only ASCII alphabetic characters (a–z, A–Z).
bool isAlpha(String str) => alphaReg.hasMatch(str);

/// Returns `true` if [str] contains only ASCII alphanumeric characters (a–z, A–Z, 0–9).
bool isAlphaNumeric(String str) => alphaNumericReg.hasMatch(str);

/// Returns `true` if [str] contains only printable ASCII characters (U+0000–U+007F).
bool isAscii(String str) => asciiReg.hasMatch(str);

/// Returns `true` if [str] is a valid Base64-encoded string.
bool isBase64(String str) => base64Reg.hasMatch(str);

/// Returns `true` if [str] matches the RFC 5322 email format heuristic.
bool isEmail(String str) => emailReg.hasMatch(str.toLowerCase());

/// Returns `true` if [str] represents a floating-point number.
bool isFloat(String str) => floatReg.hasMatch(str);

/// Returns `true` if [str] contains full-width Unicode characters.
@experimental
bool isFullWidth(String str) => fullWidthReg.hasMatch(str);

/// Returns `true` if [str] contains half-width Unicode characters.
@experimental
bool isHalfWidth(String str) => halfWidthReg.hasMatch(str);

/// Returns `true` if [str] is a valid hexadecimal string.
bool isHexadecimal(String str) => hexadecimalReg.hasMatch(str);

/// Returns `true` if [str] is a valid hex color (e.g. `#FFF` or `#FFFFFF`).
bool isHexColor(String str) => hexColorReg.hasMatch(str);

/// Returns `true` if [str] represents an integer.
bool isInt(String str) => intReg.hasMatch(str);

/// Returns `true` if [str] is valid JSON.
bool isJson(String str) {
  try {
    jsonDecode(str);
    return true;
  } catch (_) {
    return false;
  }
}

/// Returns `true` if [str] is entirely lowercase (or has no cased characters).
bool isLowerCase(String str) => str == str.toLowerCase();

/// Returns `true` if [str] contains multi-byte (non-ASCII) characters.
@experimental
bool isMultiByte(String str) => multiByteReg.hasMatch(str);

/// Returns `true` if [str] contains only numeric digits (optionally negative).
bool isNumeric(String str) => numericReg.hasMatch(str);

/// Returns `true` if [str] is `null` or empty.
///
/// Deprecated: prefer `str == null || str.isEmpty` or the `isBlank` extension.
@Deprecated('Use str == null || str.isEmpty instead.')
bool isNull(String? str) => str == null || str.isEmpty;

/// Returns `true` if [str] is `null` or empty.
bool isNullOrEmpty(String? str) => str == null || str.isEmpty;

/// Returns `true` if [str] is entirely uppercase (or has no cased characters).
bool isUpperCase(String str) => str == str.toUpperCase();

/// Returns `true` if [str] contains surrogate pairs.
@experimental
bool isSurrogatePair(String str) => surrogatePairsReg.hasMatch(str);

/// Returns `true` if [str] contains both full-width and half-width characters.
@experimental
bool isVariableWidth(String str) => isFullWidth(str) && isHalfWidth(str);

/// Returns `true` if [str] byte-length is within [`min`, `max`].
///
/// Uses `String.length` as a proxy for byte length.
bool isByteLength(String str, int min, [int? max]) {
  return str.length >= min && (max == null || str.length <= max);
}

/// Returns `true` if the display-length of [str] is within [`min`, `max`],
/// counting surrogate pairs as single characters.
bool isLength(String str, int min, [int? max]) {
  final pairs = surrogatePairsReg.allMatches(str).length;
  final len = str.length - pairs;
  return len >= min && (max == null || len <= max);
}

/// Returns `true` if [str] contains [seed].
bool contains(String str, String seed) => str.contains(seed);

/// Returns `true` if [str] contains [seed], ignoring case.
bool containsIgnoreCase(String str, String seed) =>
    str.toLowerCase().contains(seed.toLowerCase());

/// Returns `true` if [str] equals [comparison].
bool equals(String? str, String comparison) => str == comparison;

/// Returns `true` if [str] matches the regex [pattern].
bool matches(String str, String pattern) => RegExp(pattern).hasMatch(str);

/// Returns `true` if [str] is a valid URL slug (lowercase alphanumeric words separated by hyphens).
bool isSlug(String str) {
  return RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(str);
}

/// Returns `true` if [str] is `null`, empty, or consists only of whitespace.
bool isBlank(String? str) => str == null || str.trim().isEmpty;

/// Returns `true` if [str] is not `null` and contains non-whitespace characters.
bool isNotBlank(String? str) => str != null && str.trim().isNotEmpty;

/// Returns `true` if [str] reads the same forwards and backwards.
bool isPalindrome(
  String str, {
  bool ignoreCase = true,
  bool ignoreNonAlphanumeric = true,
}) {
  var processed = str;
  if (ignoreNonAlphanumeric) {
    processed = processed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }
  if (ignoreCase) {
    processed = processed.toLowerCase();
  }
  if (processed.isEmpty) return false;
  final reversed = processed.split('').reversed.join('');
  return processed == reversed;
}

/// Returns `true` if [str] starts with an uppercase letter.
bool isCapitalized(String str) {
  if (str.isEmpty) return false;
  final first = str[0];
  return first == first.toUpperCase() && first != first.toLowerCase();
}

/// Returns `true` if [str] is in camelCase format (e.g. `fooBar`).
bool isCamelCase(String str) => camelCaseReg.hasMatch(str);

/// Returns `true` if [str] is in PascalCase format (e.g. `FooBar`).
bool isPascalCase(String str) => pascalCaseReg.hasMatch(str);

/// Returns `true` if [str] is in snake_case format (e.g. `foo_bar`).
bool isSnakeCase(String str) => snakeCaseReg.hasMatch(str);

/// Returns `true` if [str] is in kebab-case format (e.g. `foo-bar`).
bool isKebabCase(String str) => kebabCaseReg.hasMatch(str);

/// Returns `true` if [str] matches JSON Web Token (JWT) format structure.
bool isJwt(String str) => jwtReg.hasMatch(str);

/// Returns `true` if [str] is a valid MIME type format (e.g. `application/json`).
bool isMimeType(String str) => mimeTypeReg.hasMatch(str);

/// Returns `true` if [str] is a valid hash string for [algorithm] (e.g. `'md5'`, `'sha1'`, `'sha256'`, `'sha512'`).
bool isHash(String str, String algorithm) {
  final reg = hashReg[algorithm.toLowerCase()];
  return reg != null && reg.hasMatch(str);
}

/// Returns `true` if [str] is in SCREAMING_SNAKE_CASE (e.g. `FOO_BAR`).
bool isScreamingSnakeCase(String str) => screamingSnakeCaseReg.hasMatch(str);

/// Returns `true` if [str] is in Title Case (e.g. `Foo Bar Baz`).
///
/// Every space-separated word must start with an uppercase letter and continue
/// in lowercase, so `Foo BAR` is rejected.
bool isTitleCase(String str) => titleCaseReg.hasMatch(str);

/// Returns `true` if [str] contains only binary digits (`0` and `1`).
bool isBinary(String str) => binaryReg.hasMatch(str);

/// Returns `true` if [str] contains only octal digits (`0`–`7`).
bool isOctal(String str) => octalReg.hasMatch(str);

/// Returns `true` if [str] is a valid Base32-encoded string (RFC 4648).
///
/// Expects the standard uppercase alphabet; pass an upper-cased string for
/// lowercase input.
bool isBase32(String str) => str.isNotEmpty && base32Reg.hasMatch(str);

/// Returns `true` if [str] is a CSS `rgb()` or `rgba()` color with every
/// channel in 0–255.
bool isRgbColor(String str) {
  final match = rgbColorReg.firstMatch(str.trim());
  if (match == null) return false;
  for (var group = 1; group <= 3; group++) {
    final channel = int.parse(match.group(group)!);
    if (channel > 255) return false;
  }
  return true;
}

/// Returns `true` if [str] is a CSS `hsl()` or `hsla()` color with saturation
/// and lightness in 0–100%.
bool isHslColor(String str) {
  final match = hslColorReg.firstMatch(str.trim());
  if (match == null) return false;
  for (var group = 2; group <= 3; group++) {
    final percent = double.parse(match.group(group)!);
    if (percent > 100) return false;
  }
  return true;
}

/// Returns `true` if [str] contains only printable ASCII, tab, newline
/// or carriage return.
///
/// Unlike [isAscii], control characters such as `\x00` are rejected, and the
/// empty string passes.
bool isPrintable(String str) => printableReg.hasMatch(str);

/// Returns `true` if [str] contains at least one whitespace character.
bool hasWhitespace(String str) => whitespaceReg.hasMatch(str);

/// Returns `true` if [str] starts with [prefix], ignoring case.
bool startsWithIgnoreCase(String str, String prefix) =>
    str.toLowerCase().startsWith(prefix.toLowerCase());

/// Returns `true` if [str] ends with [suffix], ignoring case.
bool endsWithIgnoreCase(String str, String suffix) =>
    str.toLowerCase().endsWith(suffix.toLowerCase());

/// Returns `true` if [str] and [other] are anagrams of one another.
///
/// Case and non-alphanumeric characters are ignored by default, matching
/// [isPalindrome]. Two strings that reduce to nothing are not anagrams.
bool isAnagram(
  String str,
  String other, {
  bool ignoreCase = true,
  bool ignoreNonAlphanumeric = true,
}) {
  List<String> normalize(String value) {
    var processed = value;
    if (ignoreNonAlphanumeric) {
      processed = processed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    }
    if (ignoreCase) {
      processed = processed.toLowerCase();
    }
    return processed.split('')..sort();
  }

  final a = normalize(str);
  if (a.isEmpty) return false;
  final b = normalize(other);
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Returns `true` if [str] is a decimal number, optionally with exactly
/// [places] digits after the point.
///
/// ```dart
/// isDecimal('12.50', places: 2);  // true
/// isDecimal('12.5', places: 2);   // false — one place, not two
/// isDecimal('12', places: 2);     // false — a point is required
/// ```
bool isDecimal(String str, {int? places}) {
  if (!floatReg.hasMatch(str)) return false;
  if (places == null) return true;
  final dot = str.indexOf('.');
  if (dot == -1) return places == 0;
  return str.length - dot - 1 == places;
}

/// Returns `true` if [str] is a latitude in the range -90 to 90.
bool isLatitude(String str) {
  final value = double.tryParse(str.trim());
  return value != null && value >= -90 && value <= 90;
}

/// Returns `true` if [str] is a longitude in the range -180 to 180.
bool isLongitude(String str) {
  final value = double.tryParse(str.trim());
  return value != null && value >= -180 && value <= 180;
}

/// Returns `true` if [str] is a `latitude,longitude` pair (e.g. `11.55,104.91`).
bool isLatLong(String str) {
  final parts = str.split(',');
  if (parts.length != 2) return false;
  return isLatitude(parts[0]) && isLongitude(parts[1]);
}

/// Returns `true` if [str] meets every enabled password-strength requirement.
///
/// Each rule can be turned off individually; with all of them off this reduces
/// to a length check.
///
/// ```dart
/// isStrongPassword('Tr0ub4dor&3');            // true
/// isStrongPassword('password', minLength: 8); // false — no digit, no symbol
/// ```
bool isStrongPassword(
  String str, {
  int minLength = 8,
  int? maxLength,
  bool requireUppercase = true,
  bool requireLowercase = true,
  bool requireDigit = true,
  bool requireSpecial = true,
  bool allowWhitespace = false,
}) {
  if (str.length < minLength) return false;
  if (maxLength != null && str.length > maxLength) return false;
  if (!allowWhitespace && hasWhitespace(str)) return false;
  if (requireUppercase && !RegExp('[A-Z]').hasMatch(str)) return false;
  if (requireLowercase && !RegExp('[a-z]').hasMatch(str)) return false;
  if (requireDigit && !RegExp('[0-9]').hasMatch(str)) return false;
  if (requireSpecial && !RegExp(r'[^A-Za-z0-9]').hasMatch(str)) return false;
  return true;
}
