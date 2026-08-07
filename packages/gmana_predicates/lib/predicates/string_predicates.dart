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


