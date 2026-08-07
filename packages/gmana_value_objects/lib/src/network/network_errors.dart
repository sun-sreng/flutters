import '../core/validation_error.dart';

/// Base class for all network address validation errors.
sealed class NetworkAddressError extends ValidationError {
  /// Internal constructor for [NetworkAddressError].
  const NetworkAddressError();
}

/// Error indicating that the network address string is empty.
final class NetworkAddressEmpty extends NetworkAddressError {
  /// Creates a [NetworkAddressEmpty] error.
  const NetworkAddressEmpty();
}

/// Error indicating that the input is not a valid IP address.
final class NetworkAddressInvalidIp extends NetworkAddressError {
  /// Specified IP version checked.
  final int? version;

  /// Creates a [NetworkAddressInvalidIp] error.
  const NetworkAddressInvalidIp([this.version]);
}

/// Error indicating that the input is not a valid CIDR notation.
final class NetworkAddressInvalidCidr extends NetworkAddressError {
  /// Specified IP version checked.
  final int? version;

  /// Creates a [NetworkAddressInvalidCidr] error.
  const NetworkAddressInvalidCidr([this.version]);
}

/// Error indicating that the input is not a valid MAC address.
final class NetworkAddressInvalidMac extends NetworkAddressError {
  /// Creates a [NetworkAddressInvalidMac] error.
  const NetworkAddressInvalidMac();
}

/// Error indicating that the input is not a valid Port number.
final class NetworkAddressInvalidPort extends NetworkAddressError {
  /// Creates a [NetworkAddressInvalidPort] error.
  const NetworkAddressInvalidPort();
}
