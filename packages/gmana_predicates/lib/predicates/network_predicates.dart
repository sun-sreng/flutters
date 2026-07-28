import '../src/regex/identifier_patterns.dart';
import '../src/regex/network_patterns.dart';

/// Returns `true` if [str] is a valid IPv4 address.
bool isIpv4(String str) {
  if (!ipv4Maybe.hasMatch(str)) return false;
  final parts = str.split('.');
  for (final part in parts) {
    final n = int.tryParse(part);
    if (n == null || n < 0 || n > 255) return false;
  }
  return true;
}

/// Returns `true` if [str] is a valid IPv6 address.
bool isIpv6(String str) => ipv6.hasMatch(str);

/// Returns `true` if [text] is a valid postal code for [locale].
///
/// Returns `false` if [text] is `null`.
/// Throws [FormatException] if [locale] is not supported and no [orElse] is provided.
bool isPostalCode(String? text, String locale, {bool Function()? orElse}) {
  if (text == null) return false;
  final pattern = postalCodePatterns[locale];
  return pattern != null
      ? pattern.hasMatch(text)
      : orElse != null
      ? orElse()
      : throw FormatException('No postal code pattern for locale: $locale');
}

/// Returns `true` if [str] is a valid URL.
bool isUrl(
  String str, {
  Set<String>? allowedSchemes,
  bool requireHost = true,
}) {
  final trimmed = str.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme) return false;

  final scheme = uri.scheme.toLowerCase();
  if (allowedSchemes != null && !allowedSchemes.contains(scheme)) {
    return false;
  }

  if (requireHost && uri.host.isEmpty) return false;

  return true;
}

/// Returns `true` if [str] is a valid MAC address (e.g. `00:1A:2B:3C:4D:5E` or `00-1A-2B-3C-4D-5E`).
bool isMacAddress(String str) {
  final macRegex = RegExp(
    r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
  );
  return macRegex.hasMatch(str);
}

/// Returns `true` if [str] is a valid network port number (1–65535).
bool isPort(String str) {
  final port = int.tryParse(str);
  return port != null && port >= 1 && port <= 65535;
}
