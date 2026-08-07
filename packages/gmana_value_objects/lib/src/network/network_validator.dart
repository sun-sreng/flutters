import 'package:gmana_functional/gmana_functional.dart';

import 'network_errors.dart';
import 'network_validation_config.dart';

/// Validator for network address inputs.
final class NetworkValidator {
  /// Configuration used during validation.
  final NetworkValidationConfig config;

  /// Creates a [NetworkValidator].
  const NetworkValidator([this.config = const NetworkValidationConfig()]);

  /// Validates [input] returning `Either<NetworkAddressError, String>`.
  Either<NetworkAddressError, String> validate(String input) {
    final value = config.trimWhitespace ? input.trim() : input;

    if (value.isEmpty) {
      return config.allowEmpty
          ? Right(value)
          : const Left(NetworkAddressEmpty());
    }

    return switch (config.requiredType) {
      NetworkAddressType.any => Right(value),
      NetworkAddressType.ipv4 =>
        _isIpv4(value)
            ? Right(value)
            : const Left(NetworkAddressInvalidIp(4)),
      NetworkAddressType.ipv6 =>
        _isIpv6(value)
            ? Right(value)
            : const Left(NetworkAddressInvalidIp(6)),
      NetworkAddressType.ip =>
        _isIp(value, config.ipVersion)
            ? Right(value)
            : Left(NetworkAddressInvalidIp(config.ipVersion)),
      NetworkAddressType.cidr =>
        _isCidr(value, config.ipVersion)
            ? Right(value)
            : Left(NetworkAddressInvalidCidr(config.ipVersion)),
      NetworkAddressType.macAddress =>
        _isMac(value)
            ? Right(value)
            : const Left(NetworkAddressInvalidMac()),
      NetworkAddressType.port =>
        _isPort(value)
            ? Right(value)
            : const Left(NetworkAddressInvalidPort()),
    };
  }

  static bool _isIpv4(String str) {
    final parts = str.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  static bool _isIpv6(String str) {
    return RegExp(r'^::|^::1|^([a-fA-F0-9]{1,4}::?){1,7}([a-fA-F0-9]{1,4})$').hasMatch(str);
  }

  static bool _isIp(String str, int? version) {
    if (version == 4) return _isIpv4(str);
    if (version == 6) return _isIpv6(str);
    return _isIpv4(str) || _isIpv6(str);
  }

  static bool _isCidr(String str, int? version) {
    final parts = str.split('/');
    if (parts.length != 2) return false;
    final prefix = int.tryParse(parts[1]);
    if (prefix == null) return false;

    if (version == 4 || (version == null && _isIpv4(parts[0]))) {
      return _isIpv4(parts[0]) && prefix >= 0 && prefix <= 32;
    } else if (version == 6 || (version == null && _isIpv6(parts[0]))) {
      return _isIpv6(parts[0]) && prefix >= 0 && prefix <= 128;
    }
    return false;
  }

  static bool _isMac(String str) {
    return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$').hasMatch(str);
  }

  static bool _isPort(String str) {
    final port = int.tryParse(str);
    return port != null && port >= 1 && port <= 65535;
  }
}
