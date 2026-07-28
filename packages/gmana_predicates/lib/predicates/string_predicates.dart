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

