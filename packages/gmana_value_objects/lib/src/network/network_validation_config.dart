import 'package:gmana_validation/gmana_validation.dart' show NetworkAddressType;
import 'package:meta/meta.dart';

export 'package:gmana_validation/gmana_validation.dart' show NetworkAddressType;

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
}
