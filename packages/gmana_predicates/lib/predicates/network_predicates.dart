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
bool isUrl(String str, {Set<String>? allowedSchemes, bool requireHost = true}) {
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
  final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
  return macRegex.hasMatch(str);
}

/// Returns `true` if [str] is a valid network port number (1–65535).
bool isPort(String str) {
  final port = int.tryParse(str);
  return port != null && port >= 1 && port <= 65535;
}

/// Returns `true` if [str] is a valid IP address.
///
/// Pass [version] as `4` or `6` to specify IP version.
bool isIP(String str, [int? version]) {
  if (version == 4) return isIpv4(str);
  if (version == 6) return isIpv6(str);
  return isIpv4(str) || isIpv6(str);
}

/// Returns `true` if [str] is a valid CIDR notation.
///
/// Pass [version] as `4` or `6` to check a specific IP version block.
bool isCidr(String str, [int? version]) {
  if (version == 4) {
    return _isCidrV4(str);
  } else if (version == 6) {
    return cidrV6Maybe.hasMatch(str);
  } else if (version == null) {
    return _isCidrV4(str) || cidrV6Maybe.hasMatch(str);
  }
  return false;
}

bool _isCidrV4(String str) {
  if (!cidrV4Maybe.hasMatch(str)) return false;
  final parts = str.split('/');
  return isIpv4(parts[0]);
}

/// Returns `true` if [str] is an IPv4 address in a private range (RFC 1918).
///
/// Covers `10.0.0.0/8`, `172.16.0.0/12`, and `192.168.0.0/16`. Loopback is
/// *not* private — see [isLoopbackIpv4].
bool isPrivateIpv4(String str) {
  if (!isIpv4(str)) return false;
  final octets = str.split('.').map(int.parse).toList();
  if (octets[0] == 10) return true;
  if (octets[0] == 172 && octets[1] >= 16 && octets[1] <= 31) return true;
  if (octets[0] == 192 && octets[1] == 168) return true;
  return false;
}

/// Returns `true` if [str] is an IPv4 loopback address (`127.0.0.0/8`).
bool isLoopbackIpv4(String str) {
  if (!isIpv4(str)) return false;
  return int.parse(str.split('.').first) == 127;
}

/// Returns `true` if [str] is an IPv4 address that is routable on the public
/// internet.
///
/// Excludes private ranges, loopback, link-local (`169.254.0.0/16`),
/// multicast and reserved space (`224.0.0.0/4` and above), and `0.0.0.0/8`.
bool isPublicIpv4(String str) {
  if (!isIpv4(str)) return false;
  if (isPrivateIpv4(str) || isLoopbackIpv4(str)) return false;
  final octets = str.split('.').map(int.parse).toList();
  if (octets[0] == 0) return false;
  if (octets[0] == 169 && octets[1] == 254) return false;
  if (octets[0] >= 224) return false;
  return true;
}

/// Returns `true` if [str] is a valid hostname label sequence (RFC 1123).
///
/// Unlike `isFQDN` a top-level domain is not required, so a single label such
/// as `localhost` passes.
bool isHostname(String str) {
  if (str.isEmpty || str.length > 253) return false;
  final withoutTrailingDot =
      str.endsWith('.') ? str.substring(0, str.length - 1) : str;
  if (withoutTrailingDot.isEmpty) return false;
  final label = RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$');
  return withoutTrailingDot.split('.').every(label.hasMatch);
}

/// Returns `true` if [str] is a valid Data URI scheme (RFC 2397).
bool isDataURI(String str) => dataUriReg.hasMatch(str.trim());

/// Returns `true` if [str] is a valid BitTorrent Magnet URI.
bool isMagnetURI(String str) => magnetUriReg.hasMatch(str.trim());
