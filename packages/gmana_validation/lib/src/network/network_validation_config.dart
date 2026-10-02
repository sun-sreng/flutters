import 'package:meta/meta.dart';

import '../core/set_equality.dart';

/// Required network address type.
enum NetworkAddressType {
  /// Accepts any valid IP, IPv4, IPv6, CIDR, MAC, Port, Data URI, or Magnet URI based on flags.
  any,

  /// Validates IPv4 address only.
  ipv4,

  /// Validates IPv6 address only.
  ipv6,

  /// Validates IPv4 or IPv6 address.
  ip,

  /// Validates CIDR notation.
  cidr,

  /// Validates MAC address.
  macAddress,

  /// Validates network Port (1-65535).
  port,

  /// Validates RFC 2397 Data URI.
  dataUri,

  /// Validates Magnet URI.
  magnetUri,
}

/// Configuration options for network address validation.
@immutable
final class NetworkValidationConfig {
  /// Whether an empty string is considered valid.
  final bool allowEmpty;

  /// Whether whitespace around the input should be trimmed before validation.
  final bool trimWhitespace;

  /// Required network address type.
  final NetworkAddressType requiredType;

  /// Expected IP version for CIDR or IP checks (4, 6, or null for any).
  final int? ipVersion;

  /// Creates a [NetworkValidationConfig].
  const NetworkValidationConfig({
    this.allowEmpty = false,
    this.trimWhitespace = true,
    this.requiredType = NetworkAddressType.any,
    this.ipVersion,
  });

  /// Returns a copy with the supplied fields replaced.
  ///
  /// Pass `null` explicitly to clear [ipVersion]. Omitted fields retain their
  /// current values.
  NetworkValidationConfig copyWith({
    bool? allowEmpty,
    bool? trimWhitespace,
    NetworkAddressType? requiredType,
    Object? ipVersion = unsetConfigValue,
  }) {
    return NetworkValidationConfig(
      allowEmpty: allowEmpty ?? this.allowEmpty,
      trimWhitespace: trimWhitespace ?? this.trimWhitespace,
      requiredType: requiredType ?? this.requiredType,
      ipVersion:
          identical(ipVersion, unsetConfigValue)
              ? this.ipVersion
              : ipVersion as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkValidationConfig &&
          other.allowEmpty == allowEmpty &&
          other.trimWhitespace == trimWhitespace &&
          other.requiredType == requiredType &&
          other.ipVersion == ipVersion;

  @override
  int get hashCode =>
      Object.hash(allowEmpty, trimWhitespace, requiredType, ipVersion);
}
