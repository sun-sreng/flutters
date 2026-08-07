import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_predicates/gmana_predicates.dart' as predicates;

import '../core/validation_issue.dart';
import 'network_validation_config.dart';
import 'network_validation_issue.dart';

/// Canonical validator for network input formats.
final class NetworkValidator {
  /// Rules used during validation.
  final NetworkValidationConfig config;

  /// Creates a network validator.
  const NetworkValidator([this.config = const NetworkValidationConfig()]);

  /// Validates and normalizes [input].
  ValidationResult<NetworkValidationIssue, String> validate(String input) {
    final value = config.trimWhitespace ? input.trim() : input;

    if (value.isEmpty) {
      return config.allowEmpty ? Right(value) : const Left(NetworkEmptyIssue());
    }

    return switch (config.requiredType) {
      NetworkAddressType.any => Right(value),
      NetworkAddressType.ipv4 =>
        predicates.isIpv4(value)
            ? Right(value)
            : const Left(NetworkInvalidIpIssue(4)),
      NetworkAddressType.ipv6 =>
        predicates.isIpv6(value)
            ? Right(value)
            : const Left(NetworkInvalidIpIssue(6)),
      NetworkAddressType.ip =>
        predicates.isIP(value, config.ipVersion)
            ? Right(value)
            : Left(NetworkInvalidIpIssue(config.ipVersion)),
      NetworkAddressType.cidr =>
        predicates.isCidr(value, config.ipVersion)
            ? Right(value)
            : Left(NetworkInvalidCidrIssue(config.ipVersion)),
      NetworkAddressType.macAddress =>
        predicates.isMacAddress(value)
            ? Right(value)
            : const Left(NetworkInvalidMacIssue()),
      NetworkAddressType.port =>
        predicates.isPort(value)
            ? Right(value)
            : const Left(NetworkInvalidPortIssue()),
      NetworkAddressType.dataUri =>
        predicates.isDataURI(value)
            ? Right(value)
            : const Left(NetworkInvalidDataUriIssue()),
      NetworkAddressType.magnetUri =>
        predicates.isMagnetURI(value)
            ? Right(value)
            : const Left(NetworkInvalidMagnetUriIssue()),
    };
  }
}
