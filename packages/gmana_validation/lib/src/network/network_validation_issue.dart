import '../core/validation_issue.dart';

/// Default English messages for network validation issues.
String resolveNetworkValidationIssue(NetworkValidationIssue issue) {
  return issue.defaultMessage;
}

/// Base type for network validation failures.
sealed class NetworkValidationIssue extends ValidationIssue {
  /// Creates a network validation issue.
  const NetworkValidationIssue();

  /// Default English message.
  String get defaultMessage;
}

/// Network input is empty.
final class NetworkEmptyIssue extends NetworkValidationIssue {
  /// Creates an empty network issue.
  const NetworkEmptyIssue();

  @override
  String get code => 'network.empty';

  @override
  String get defaultMessage => 'Network address is required';
}

/// Invalid IP address.
final class NetworkInvalidIpIssue extends NetworkValidationIssue {
  /// Version checked (4, 6, or null).
  final int? version;

  /// Creates an invalid IP issue.
  const NetworkInvalidIpIssue([this.version]);

  @override
  String get code => 'network.invalidIp';

  @override
  String get defaultMessage =>
      version != null ? 'Invalid IPv$version address' : 'Invalid IP address';
}

/// Invalid CIDR notation.
final class NetworkInvalidCidrIssue extends NetworkValidationIssue {
  /// Version checked.
  final int? version;

  /// Creates an invalid CIDR issue.
  const NetworkInvalidCidrIssue([this.version]);

  @override
  String get code => 'network.invalidCidr';

  @override
  String get defaultMessage =>
      version != null ? 'Invalid IPv$version CIDR block' : 'Invalid CIDR block';
}

/// Invalid MAC address.
final class NetworkInvalidMacIssue extends NetworkValidationIssue {
  /// Creates an invalid MAC issue.
  const NetworkInvalidMacIssue();

  @override
  String get code => 'network.invalidMac';

  @override
  String get defaultMessage => 'Invalid MAC address';
}

/// Invalid network port number.
final class NetworkInvalidPortIssue extends NetworkValidationIssue {
  /// Creates an invalid port issue.
  const NetworkInvalidPortIssue();

  @override
  String get code => 'network.invalidPort';

  @override
  String get defaultMessage => 'Invalid port number (must be 1–65535)';
}

/// Invalid Data URI scheme.
final class NetworkInvalidDataUriIssue extends NetworkValidationIssue {
  /// Creates an invalid Data URI issue.
  const NetworkInvalidDataUriIssue();

  @override
  String get code => 'network.invalidDataUri';

  @override
  String get defaultMessage => 'Invalid Data URI format';
}

/// Invalid Magnet URI.
final class NetworkInvalidMagnetUriIssue extends NetworkValidationIssue {
  /// Creates an invalid Magnet URI issue.
  const NetworkInvalidMagnetUriIssue();

  @override
  String get code => 'network.invalidMagnetUri';

  @override
  String get defaultMessage => 'Invalid Magnet URI format';
}
